import 'package:flutter/material.dart';
import 'package:rick_and_morty/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/get_favorites_usecase.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/toggle_favorite_usecase.dart';

enum FavoritesStatus { initial, loading, loaded, empty }

class FavoritesProvider extends ChangeNotifier {
  final GetFavoritesUseCase getFavoritesUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  FavoritesProvider({
    required this.getFavoritesUseCase,
    required this.toggleFavoriteUseCase,
  });

  List<Character> _favorites = [];
  FavoritesStatus _status = FavoritesStatus.initial;

  List<Character> get favorites => _favorites;
  FavoritesStatus get status => _status;

  Future<void> loadFavorites() async {
    _status = FavoritesStatus.loading;
    notifyListeners();
    _favorites = await getFavoritesUseCase();
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
