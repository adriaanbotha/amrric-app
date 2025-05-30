// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal_image.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AnimalImage _$AnimalImageFromJson(Map<String, dynamic> json) {
  return _AnimalImage.fromJson(json);
}

/// @nodoc
mixin _$AnimalImage {
  String get id => throw _privateConstructorUsedError;
  String get url => throw _privateConstructorUsedError;
  String? get caption => throw _privateConstructorUsedError;
  DateTime? get takenAt => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this AnimalImage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AnimalImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimalImageCopyWith<AnimalImage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimalImageCopyWith<$Res> {
  factory $AnimalImageCopyWith(
          AnimalImage value, $Res Function(AnimalImage) then) =
      _$AnimalImageCopyWithImpl<$Res, AnimalImage>;
  @useResult
  $Res call(
      {String id,
      String url,
      String? caption,
      DateTime? takenAt,
      String? location,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AnimalImageCopyWithImpl<$Res, $Val extends AnimalImage>
    implements $AnimalImageCopyWith<$Res> {
  _$AnimalImageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AnimalImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? caption = freezed,
    Object? takenAt = freezed,
    Object? location = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      takenAt: freezed == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnimalImageImplCopyWith<$Res>
    implements $AnimalImageCopyWith<$Res> {
  factory _$$AnimalImageImplCopyWith(
          _$AnimalImageImpl value, $Res Function(_$AnimalImageImpl) then) =
      __$$AnimalImageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String url,
      String? caption,
      DateTime? takenAt,
      String? location,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$AnimalImageImplCopyWithImpl<$Res>
    extends _$AnimalImageCopyWithImpl<$Res, _$AnimalImageImpl>
    implements _$$AnimalImageImplCopyWith<$Res> {
  __$$AnimalImageImplCopyWithImpl(
      _$AnimalImageImpl _value, $Res Function(_$AnimalImageImpl) _then)
      : super(_value, _then);

  /// Create a copy of AnimalImage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? url = null,
    Object? caption = freezed,
    Object? takenAt = freezed,
    Object? location = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$AnimalImageImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      url: null == url
          ? _value.url
          : url // ignore: cast_nullable_to_non_nullable
              as String,
      caption: freezed == caption
          ? _value.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      takenAt: freezed == takenAt
          ? _value.takenAt
          : takenAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnimalImageImpl with DiagnosticableTreeMixin implements _AnimalImage {
  const _$AnimalImageImpl(
      {required this.id,
      required this.url,
      this.caption,
      this.takenAt,
      this.location,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata;

  factory _$AnimalImageImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnimalImageImplFromJson(json);

  @override
  final String id;
  @override
  final String url;
  @override
  final String? caption;
  @override
  final DateTime? takenAt;
  @override
  final String? location;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AnimalImage(id: $id, url: $url, caption: $caption, takenAt: $takenAt, location: $location, metadata: $metadata)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'AnimalImage'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('url', url))
      ..add(DiagnosticsProperty('caption', caption))
      ..add(DiagnosticsProperty('takenAt', takenAt))
      ..add(DiagnosticsProperty('location', location))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimalImageImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.url, url) || other.url == url) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.takenAt, takenAt) || other.takenAt == takenAt) &&
            (identical(other.location, location) ||
                other.location == location) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, url, caption, takenAt,
      location, const DeepCollectionEquality().hash(_metadata));

  /// Create a copy of AnimalImage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimalImageImplCopyWith<_$AnimalImageImpl> get copyWith =>
      __$$AnimalImageImplCopyWithImpl<_$AnimalImageImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnimalImageImplToJson(
      this,
    );
  }
}

abstract class _AnimalImage implements AnimalImage {
  const factory _AnimalImage(
      {required final String id,
      required final String url,
      final String? caption,
      final DateTime? takenAt,
      final String? location,
      final Map<String, dynamic>? metadata}) = _$AnimalImageImpl;

  factory _AnimalImage.fromJson(Map<String, dynamic> json) =
      _$AnimalImageImpl.fromJson;

  @override
  String get id;
  @override
  String get url;
  @override
  String? get caption;
  @override
  DateTime? get takenAt;
  @override
  String? get location;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of AnimalImage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimalImageImplCopyWith<_$AnimalImageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
