import '../../domain/entities/character.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/origin.dart';

class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.name,
    required super.status,
    required super.species,
    required super.type,
    required super.gender,
    required super.origin,
    required super.location,
    required super.image,
    required super.url,
  });

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    final originMap = json['origin'] as Map<String, dynamic>;
    final locationMap = json['location'] as Map<String, dynamic>;
    return CharacterModel(
      id: json['id'] as int,
      name: json['name'] as String,
      status: json['status'] as String,
      species: json['species'] as String,
      type: json['type'] as String? ?? '',
      gender: json['gender'] as String,
      origin: Origin(
        name: originMap['name'] as String,
        url: originMap['url'] as String,
      ),
      location: Location(
        name: locationMap['name'] as String,
        url: locationMap['url'] as String,
      ),
      image: json['image'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'species': species,
      'type': type,
      'gender': gender,
      'origin': {'name': origin.name, 'url': origin.url},
      'location': {'name': location.name, 'url': location.url},
      'image': image,
      'url': url,
    };
  }

  factory CharacterModel.fromEntity(Character character) {
    return CharacterModel(
      id: character.id,
      name: character.name,
      status: character.status,
      species: character.species,
      type: character.type,
      gender: character.gender,
      origin: character.origin,
      location: character.location,
      image: character.image,
      url: character.url,
    );
  }
}
