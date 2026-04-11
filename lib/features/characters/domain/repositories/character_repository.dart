import '../entities/character.dart';

abstract class CharacterRepository {
  Future<({List<Character> characters, int totalPages})> getCharacters({
    required int page,
  });

  Future<List<Character>> getFavorites();

  Future<void> toggleFavorite(Character character);

  Future<bool> isFavorite(int characterId);
}
