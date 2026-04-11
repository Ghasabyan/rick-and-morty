import '../entities/character.dart';
import '../repositories/character_repository.dart';

class GetCharactersUseCase {
  final CharacterRepository repository;

  GetCharactersUseCase(this.repository);

  Future<({List<Character> characters, int totalPages})> call({
    required int page,
  }) {
    return repository.getCharacters(page: page);
  }
}
