import 'character_model.dart';
import 'info_model.dart';

class CharactersResponse {
  final InfoModel info;
  final List<CharacterModel> results;

  const CharactersResponse({
    required this.info,
    required this.results,
  });

  factory CharactersResponse.fromJson(Map<String, dynamic> json) {
    return CharactersResponse(
      info: InfoModel.fromJson(json['info'] as Map<String, dynamic>),
      results: (json['results'] as List<dynamic>)
          .map((e) => CharacterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'info': info.toJson(),
      'results': results.map((c) => c.toJson()).toList(),
    };
  }
}
