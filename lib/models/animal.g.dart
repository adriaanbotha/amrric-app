// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnimalImpl _$$AnimalImplFromJson(Map<String, dynamic> json) => _$AnimalImpl(
      id: json['id'] as String,
      name: json['name'] as String?,
      species: json['species'] as String,
      breed: json['breed'] as String?,
      color: json['color'] as String?,
      sex: json['sex'] as String,
      estimatedAge: _parseEstimatedAge(json['estimatedAge']),
      weight: _parseWeight(json['weight']),
      microchipNumber: json['microchipNumber'] as String?,
      registrationDate: DateTime.parse(json['registrationDate'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      isActive: json['isActive'] as bool,
      houseId: json['houseId'] as String,
      locationId: json['locationId'] as String,
      councilId: json['councilId'] as String,
      ownerId: json['ownerId'] as String?,
      photoUrls:
          (json['photoUrls'] as List<dynamic>).map((e) => e as String).toList(),
      medicalHistory: json['medicalHistory'] as Map<String, dynamic>?,
      censusData: json['censusData'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AnimalImplToJson(_$AnimalImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'species': instance.species,
      'breed': instance.breed,
      'color': instance.color,
      'sex': instance.sex,
      'estimatedAge': instance.estimatedAge,
      'weight': instance.weight,
      'microchipNumber': instance.microchipNumber,
      'registrationDate': instance.registrationDate.toIso8601String(),
      'lastUpdated': instance.lastUpdated.toIso8601String(),
      'isActive': instance.isActive,
      'houseId': instance.houseId,
      'locationId': instance.locationId,
      'councilId': instance.councilId,
      'ownerId': instance.ownerId,
      'photoUrls': instance.photoUrls,
      'medicalHistory': instance.medicalHistory,
      'censusData': instance.censusData,
      'metadata': instance.metadata,
    };
