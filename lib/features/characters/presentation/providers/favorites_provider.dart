import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/get_favorites_usecase.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/toggle_favorite_usecase.dart';

enum FavoritesStatus { initial, loading, loaded, empty, error }

class FavoritesProvider extends ChangeNotifier {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesProvider({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  });

  List<Character> _favorites = [];
  FavoritesStatus _status = FavoritesStatus.initial;
  String _errorMessage = '';

  List<Character> get favorites => _favorites;
  FavoritesStatus get status => _status;
  String get errorMessage => _errorMessage;

  Future<void> loadFavorites() async {
    _status = FavoritesStatus.loading;
    notifyListeners();
    try {
      _favorites = await getFavoritesUseCase();
      _status =
          _favorites.isEmpty ? FavoritesStatus.empty : FavoritesStatus.loaded;
    } catch (e) {
      _errorMessage = 'Failed to load favorites. Please try again.';
      _status = FavoritesStatus.error;
    }
    notifyListeners();
  }

  /// Called when a favorite is toggled from another tab to keep both providers
  /// in sync without a disk round-trip.
  void syncFavoriteToggle(Character character, {required bool isNowFavorite}) {
    if (_status == FavoritesStatus.initial ||
        _status == FavoritesStatus.loading) {
      return; // not yet loaded — next loadFavorites() will catch up
    }
    if (isNowFavorite) {
      if (!_favorites.any((f) => f.id == character.id)) {
        _favorites.add(character);
      }
    } else {
      _favorites.removeWhere((f) => f.id == character.id);
    }
    _status =
        _favorites.isEmpty ? FavoritesStatus.empty : FavoritesStatus.loaded;
    notifyListeners();
  }

  Future<void> removeFromFavorites(Character character) async {
    await toggleFavoriteUseCase(character);
    _favorites.removeWhere((f) => f.id == character.id);
    _status =
        _favorites.isEmpty ? FavoritesStatus.empty : FavoritesStatus.loaded;
    notifyListeners();
  }
}
