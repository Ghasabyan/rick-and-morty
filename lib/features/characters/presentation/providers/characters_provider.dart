import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rick_and_morty/core/error/exceptions.dart';
import 'package:rick_and_morty/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/get_characters_usecase.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/get_favorites_usecase.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/toggle_favorite_usecase.dart';

enum CharactersStatus { initial, loading, loadingMore, loaded, error }

enum SortOption { none, nameAsc, nameDesc, statusAlive, statusDead }

class CharactersProvider extends ChangeNotifier {
  final GetCharactersUseCase getCharactersUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;
  final GetFavoritesUseCase getFavoritesUseCase;

  CharactersProvider({
    required this.getCharactersUseCase,
    required this.toggleFavoriteUseCase,
    required this.getFavoritesUseCase,
  }) {
    // Load favorite IDs once at construction; updated incrementally via toggleFavorite.
    _loadFavoriteIds();
  }

  List<Character> _characters = [];
  Set<int> _favoriteIds = {};
  CharactersStatus _status = CharactersStatus.initial;
  String _errorMessage = '';
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMore = true;
  SortOption _sortOption = SortOption.none;
  String _searchQuery = '';
  List<Character>? _visibleCharacters; // cache — invalidated on data/filter change
  Timer? _searchDebounce;

  // Fuzzy match: strip spaces, lowercase, check subsequence
  static bool _fuzzyMatch(String name, String query) {
    final n = name.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    final q = query.toLowerCase().replaceAll(RegExp(r'\s+'), '');
    if (q.isEmpty) return true;
    int qi = 0;
    for (int i = 0; i < n.length && qi < q.length; i++) {
      if (n[i] == q[qi]) qi++;
    }
    return qi == q.length;
  }

  List<Character> get characters {
    _visibleCharacters ??= _computeVisibleCharacters();
    return _visibleCharacters!;
  }

  List<Character> _computeVisibleCharacters() {
    List<Character> result = _searchQuery.isEmpty
        ? List<Character>.from(_characters)
        : _characters.where((c) => _fuzzyMatch(c.name, _searchQuery)).toList();
    switch (_sortOption) {
      case SortOption.nameAsc:
        result.sort((a, b) => a.name.compareTo(b.name));
      case SortOption.nameDesc:
        result.sort((a, b) => b.name.compareTo(a.name));
      case SortOption.statusAlive:
        result.sort((a, b) {
          if (a.status == 'Alive' && b.status != 'Alive') return -1;
          if (a.status != 'Alive' && b.status == 'Alive') return 1;
          return 0;
        });
      case SortOption.statusDead:
        result.sort((a, b) {
          if (a.status == 'Dead' && b.status != 'Dead') return -1;
          if (a.status != 'Dead' && b.status == 'Dead') return 1;
          return 0;
        });
      case SortOption.none:
        break;
    }
    return result;
  }

  Set<int> get favoriteIds => _favoriteIds;
  CharactersStatus get status => _status;
  String get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  SortOption get sortOption => _sortOption;
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      _searchQuery = query;
      _visibleCharacters = null;
      notifyListeners();
    });
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _visibleCharacters = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> loadCharacters({bool refresh = false}) async {
    if (refresh) {
      _characters = [];
      _currentPage = 1;
      _hasMore = true;
      _status = CharactersStatus.loading;
      notifyListeners();
    } else if (_status == CharactersStatus.loading ||
        _status == CharactersStatus.loadingMore) {
      return;
    } else if (!_hasMore) {
      return;
    } else {
      _status = CharactersStatus.loadingMore;
      notifyListeners();
    }

    try {
      final result = await getCharactersUseCase(page: _currentPage);
      _totalPages = result.totalPages;
      _characters.addAll(result.characters);
      _hasMore = _currentPage < _totalPages;
      _currentPage++;
      _visibleCharacters = null;
      _status = CharactersStatus.loaded;
    } catch (e) {
      _status = CharactersStatus.error;
      _errorMessage = e is NetworkException
          ? e.message
          : 'Failed to load characters. Please try again.';
    }
    notifyListeners();
  }

  Future<void> _loadFavoriteIds() async {
    final favorites = await getFavoritesUseCase();
    _favoriteIds = favorites.map((f) => f.id).toSet();
  }

  Future<void> refreshFavoriteIds() async {
    await _loadFavoriteIds();
    notifyListeners();
  }

  Future<void> toggleFavorite(Character character) async {
    await toggleFavoriteUseCase(character);
    if (_favoriteIds.contains(character.id)) {
      _favoriteIds.remove(character.id);
    } else {
      _favoriteIds.add(character.id);
    }
    notifyListeners();
  }

  bool isFavorite(int characterId) => _favoriteIds.contains(characterId);
}
