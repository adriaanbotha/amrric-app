// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'animal_image.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AnimalImageImpl _$$AnimalImageImplFromJson(Map<String, dynamic> json) =>
    _$AnimalImageImpl(
      id: json['id'] as String,
      url: json['url'] as String,
      caption: json['caption'] as String?,
      takenAt: json['takenAt'] == null
          ? null
          : DateTime.parse(json['takenAt'] as String),
      location: json['location'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$$AnimalImageImplToJson(_$AnimalImageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'caption': instance.caption,
      'takenAt': instance.takenAt?.toIso8601String(),
      'location': instance.location,
      'metadata': instance.metadata,
    };
