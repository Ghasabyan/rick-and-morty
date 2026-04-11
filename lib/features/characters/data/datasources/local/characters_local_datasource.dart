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
}

class CharactersLocalDatasourceImpl implements CharactersLocalDatasource {
  final SharedPreferences sharedPreferences;

  CharactersLocalDatasourceImpl(this.sharedPreferences);

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
    final jsonStr = sharedPreferences.getString(CacheKeys.favorites);
    if (jsonStr == null) return [];
    try {
      final list = jsonDecode(jsonStr) as List<dynamic>;
      return list
          .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveFavorites(List<CharacterModel> characters) async {
    final json = characters.map((c) => c.toJson()).toList();
    await sharedPreferences.setString(CacheKeys.favorites, jsonEncode(json));
  }
}
