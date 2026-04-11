import 'package:dio/dio.dart';
import 'package:rick_and_morty/core/constants.dart';
import 'package:rick_and_morty/core/error/exceptions.dart';
import 'package:rick_and_morty/features/characters/data/models/characters_response.dart';

abstract class CharactersRemoteDatasource {
  Future<CharactersResponse> getCharacters({required int page});
}

class CharactersRemoteDatasourceImpl implements CharactersRemoteDatasource {
  final Dio dio;

  CharactersRemoteDatasourceImpl(this.dio);

  @override
  Future<CharactersResponse> getCharacters({required int page}) async {
    try {
      final response = await dio.get(
        ApiConstants.charactersEndpoint,
        queryParameters: {'page': page},
      );
      return CharactersResponse.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Server error occurred');
    }
  }
}
