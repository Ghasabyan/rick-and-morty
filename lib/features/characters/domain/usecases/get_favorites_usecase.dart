import '../entities/character.dart';
import '../repositories/character_repository.dart';

class GetFavoritesUseCase {
  final CharacterRepository repository;

  GetFavoritesUseCase(this.repository);

  Future<List<Character>> call() {
    return repository.getFavorites();
  }
}
