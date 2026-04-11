import '../entities/character.dart';
import '../repositories/character_repository.dart';

class ToggleFavoriteUseCase {
  final CharacterRepository repository;

  ToggleFavoriteUseCase(this.repository);

  Future<void> call(Character character) {
    return repository.toggleFavorite(character);
  }
}
