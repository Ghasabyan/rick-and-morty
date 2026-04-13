import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rick_and_morty/core/constants.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';
import 'package:rick_and_morty/features/characters/data/models/characters_response.dart';

abstract class CharactersLocalDatasource {
  Future<CharactersResponse?> getCachedCharacters({required int page});
  Future<void> cacheCharacters({
    required int page,
    required CharactersResponse response,
  });
  Future<List<CharacterModel>> getFavorites();
  Future<void> saveFavorites(List<CharacterModel> characters);
  /// Atomically toggles a favorite in the in-memory cache and persists async.
  Future<void> toggleFavorite(CharacterModel character);
}

class CharactersLocalDatasourceImpl implements CharactersLocalDatasource {
  final SharedPreferences sharedPreferences;

  CharactersLocalDatasourceImpl(this.sharedPreferences);

  // ── In-memory favorites cache ─────────────────────────────────────────────
  // Using a single Future so concurrent callers all await the same load.
  Future<void>? _initFuture;
  final List<CharacterModel> _favoritesCache = [];

  Future<void> _ensureFavoritesLoaded() {
    _initFuture ??= _loadFavoritesFromPrefs();
    return _initFuture!;
  }

  Future<void> _loadFavoritesFromPrefs() async {
    final jsonStr = sharedPreferences.getString(CacheKeys.favorites);
    if (jsonStr == null) return;
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _favoritesCache.addAll(
        list.map((e) => CharacterModel.fromJson(e as Map<String, dynamic>)),
      );
    } catch (_) {
      // Corrupted data — start with empty list.
    }
  }

  void _persistFavorites() {
    final json = _favoritesCache.map((c) => c.toJson()).toList();
    // Fire-and-forget; SharedPreferences writes are queued internally.
    sharedPreferences.setString(CacheKeys.favorites, jsonEncode(json));
  }
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Future<CharactersResponse?> getCachedCharacters({required int page}) async {
    final key = '${CacheKeys.charactersPage}$page';
    final jsonStr = sharedPreferences.getString(key);
    if (jsonStr == null) return null;
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return CharactersResponse.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> cacheCharacters({
    required int page,
    required CharactersResponse response,
  }) async {
    final key = '${CacheKeys.charactersPage}$page';
    await sharedPreferences.setString(key, jsonEncode(response.toJson()));
  }

  @override
  Future<List<CharacterModel>> getFavorites() async {
    await _ensureFavoritesLoaded();
    return List<CharacterModel>.from(_favoritesCache);
  }

  @override
  Future<void> saveFavorites(List<CharacterModel> characters) async {
    _favoritesCache
      ..clear()
      ..addAll(characters);
    _persistFavorites();
  }

  @override
  Future<void> toggleFavorite(CharacterModel character) async {
    await _ensureFavoritesLoaded();
    // After _ensureFavoritesLoaded() there are no more awaits before the
    // mutation, so this read-modify-write is atomic within Dart's event loop.
    final idx = _favoritesCache.indexWhere((f) => f.id == character.id);
    if (idx >= 0) {
      _favoritesCache.removeAt(idx);
    } else {
      _favoritesCache.add(character);
    }
    _persistFavorites();
  }
}
