import 'package:rick_and_morty/core/error/exceptions.dart';
import 'package:rick_and_morty/core/network/network_info.dart';
import 'package:rick_and_morty/features/characters/data/datasources/local/characters_local_datasource.dart';
import 'package:rick_and_morty/features/characters/data/datasources/remote/characters_remote_datasource.dart';
import 'package:rick_and_morty/features/characters/data/models/character_model.dart';
import 'package:rick_and_morty/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty/features/characters/domain/repositories/character_repository.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  final CharactersRemoteDatasource remoteDataSource;
  final CharactersLocalDatasource localDataSource;
  final NetworkInfo networkInfo;

  CharacterRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<({List<Character> characters, int totalPages})> getCharacters({
    required int page,
  }) async {
    final isConnected = await networkInfo.isConnected;
    if (isConnected) {
      final response = await remoteDataSource.getCharacters(page: page);
      await localDataSource.cacheCharacters(page: page, response: response);
      return (
        characters: List<Character>.from(response.results),
        totalPages: response.info.pages,
      );
    } else {
      final cached = await localDataSource.getCachedCharacters(page: page);
      if (cached != null) {
        return (
          characters: List<Character>.from(cached.results),
          totalPages: cached.info.pages,
        );
      }
      throw const NetworkException(
          'No internet connection and no cached data available');
    }
  }

  @override
  Future<List<Character>> getFavorites() {
    return localDataSource.getFavorites();
  }

  @override
  Future<void> toggleFavorite(Character character) {
    return localDataSource.toggleFavorite(CharacterModel.fromEntity(character));
  }

  @override
  Future<bool> isFavorite(int characterId) async {
    final favorites = await localDataSource.getFavorites();
    return favorites.any((f) => f.id == characterId);
  }
}
