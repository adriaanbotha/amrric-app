// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'animal.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Animal _$AnimalFromJson(Map<String, dynamic> json) {
  return _Animal.fromJson(json);
}

/// @nodoc
mixin _$Animal {
  String get id => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;
  String get species => throw _privateConstructorUsedError;
  String? get breed => throw _privateConstructorUsedError;
  String? get color => throw _privateConstructorUsedError;
  String get sex => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseEstimatedAge)
  int? get estimatedAge => throw _privateConstructorUsedError;
  @JsonKey(fromJson: _parseWeight)
  double? get weight => throw _privateConstructorUsedError;
  String? get microchipNumber => throw _privateConstructorUsedError;
  DateTime get registrationDate => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  String get houseId => throw _privateConstructorUsedError;
  String get locationId => throw _privateConstructorUsedError;
  String get councilId => throw _privateConstructorUsedError;
  String? get ownerId => throw _privateConstructorUsedError;
  List<String> get photoUrls => throw _privateConstructorUsedError;
  Map<String, dynamic>? get medicalHistory =>
      throw _privateConstructorUsedError;
  Map<String, dynamic>? get censusData => throw _privateConstructorUsedError;
  Map<String, dynamic>? get metadata => throw _privateConstructorUsedError;

  /// Serializes this Animal to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Animal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AnimalCopyWith<Animal> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AnimalCopyWith<$Res> {
  factory $AnimalCopyWith(Animal value, $Res Function(Animal) then) =
      _$AnimalCopyWithImpl<$Res, Animal>;
  @useResult
  $Res call(
      {String id,
      String? name,
      String species,
      String? breed,
      String? color,
      String sex,
      @JsonKey(fromJson: _parseEstimatedAge) int? estimatedAge,
      @JsonKey(fromJson: _parseWeight) double? weight,
      String? microchipNumber,
      DateTime registrationDate,
      DateTime lastUpdated,
      bool isActive,
      String houseId,
      String locationId,
      String councilId,
      String? ownerId,
      List<String> photoUrls,
      Map<String, dynamic>? medicalHistory,
      Map<String, dynamic>? censusData,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$AnimalCopyWithImpl<$Res, $Val extends Animal>
    implements $AnimalCopyWith<$Res> {
  _$AnimalCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Animal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? species = null,
    Object? breed = freezed,
    Object? color = freezed,
    Object? sex = null,
    Object? estimatedAge = freezed,
    Object? weight = freezed,
    Object? microchipNumber = freezed,
    Object? registrationDate = null,
    Object? lastUpdated = null,
    Object? isActive = null,
    Object? houseId = null,
    Object? locationId = null,
    Object? councilId = null,
    Object? ownerId = freezed,
    Object? photoUrls = null,
    Object? medicalHistory = freezed,
    Object? censusData = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      species: null == species
          ? _value.species
          : species // ignore: cast_nullable_to_non_nullable
              as String,
      breed: freezed == breed
          ? _value.breed
          : breed // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      sex: null == sex
          ? _value.sex
          : sex // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedAge: freezed == estimatedAge
          ? _value.estimatedAge
          : estimatedAge // ignore: cast_nullable_to_non_nullable
              as int?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      microchipNumber: freezed == microchipNumber
          ? _value.microchipNumber
          : microchipNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      registrationDate: null == registrationDate
          ? _value.registrationDate
          : registrationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      houseId: null == houseId
          ? _value.houseId
          : houseId // ignore: cast_nullable_to_non_nullable
              as String,
      locationId: null == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as String,
      councilId: null == councilId
          ? _value.councilId
          : councilId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: freezed == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrls: null == photoUrls
          ? _value.photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      medicalHistory: freezed == medicalHistory
          ? _value.medicalHistory
          : medicalHistory // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      censusData: freezed == censusData
          ? _value.censusData
          : censusData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      metadata: freezed == metadata
          ? _value.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AnimalImplCopyWith<$Res> implements $AnimalCopyWith<$Res> {
  factory _$$AnimalImplCopyWith(
          _$AnimalImpl value, $Res Function(_$AnimalImpl) then) =
      __$$AnimalImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String? name,
      String species,
      String? breed,
      String? color,
      String sex,
      @JsonKey(fromJson: _parseEstimatedAge) int? estimatedAge,
      @JsonKey(fromJson: _parseWeight) double? weight,
      String? microchipNumber,
      DateTime registrationDate,
      DateTime lastUpdated,
      bool isActive,
      String houseId,
      String locationId,
      String councilId,
      String? ownerId,
      List<String> photoUrls,
      Map<String, dynamic>? medicalHistory,
      Map<String, dynamic>? censusData,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$$AnimalImplCopyWithImpl<$Res>
    extends _$AnimalCopyWithImpl<$Res, _$AnimalImpl>
    implements _$$AnimalImplCopyWith<$Res> {
  __$$AnimalImplCopyWithImpl(
      _$AnimalImpl _value, $Res Function(_$AnimalImpl) _then)
      : super(_value, _then);

  /// Create a copy of Animal
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = freezed,
    Object? species = null,
    Object? breed = freezed,
    Object? color = freezed,
    Object? sex = null,
    Object? estimatedAge = freezed,
    Object? weight = freezed,
    Object? microchipNumber = freezed,
    Object? registrationDate = null,
    Object? lastUpdated = null,
    Object? isActive = null,
    Object? houseId = null,
    Object? locationId = null,
    Object? councilId = null,
    Object? ownerId = freezed,
    Object? photoUrls = null,
    Object? medicalHistory = freezed,
    Object? censusData = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_$AnimalImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      species: null == species
          ? _value.species
          : species // ignore: cast_nullable_to_non_nullable
              as String,
      breed: freezed == breed
          ? _value.breed
          : breed // ignore: cast_nullable_to_non_nullable
              as String?,
      color: freezed == color
          ? _value.color
          : color // ignore: cast_nullable_to_non_nullable
              as String?,
      sex: null == sex
          ? _value.sex
          : sex // ignore: cast_nullable_to_non_nullable
              as String,
      estimatedAge: freezed == estimatedAge
          ? _value.estimatedAge
          : estimatedAge // ignore: cast_nullable_to_non_nullable
              as int?,
      weight: freezed == weight
          ? _value.weight
          : weight // ignore: cast_nullable_to_non_nullable
              as double?,
      microchipNumber: freezed == microchipNumber
          ? _value.microchipNumber
          : microchipNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      registrationDate: null == registrationDate
          ? _value.registrationDate
          : registrationDate // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      houseId: null == houseId
          ? _value.houseId
          : houseId // ignore: cast_nullable_to_non_nullable
              as String,
      locationId: null == locationId
          ? _value.locationId
          : locationId // ignore: cast_nullable_to_non_nullable
              as String,
      councilId: null == councilId
          ? _value.councilId
          : councilId // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: freezed == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String?,
      photoUrls: null == photoUrls
          ? _value._photoUrls
          : photoUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      medicalHistory: freezed == medicalHistory
          ? _value._medicalHistory
          : medicalHistory // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      censusData: freezed == censusData
          ? _value._censusData
          : censusData // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      metadata: freezed == metadata
          ? _value._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AnimalImpl with DiagnosticableTreeMixin implements _Animal {
  const _$AnimalImpl(
      {required this.id,
      this.name,
      required this.species,
      this.breed,
      this.color,
      required this.sex,
      @JsonKey(fromJson: _parseEstimatedAge) this.estimatedAge,
      @JsonKey(fromJson: _parseWeight) this.weight,
      this.microchipNumber,
      required this.registrationDate,
      required this.lastUpdated,
      required this.isActive,
      required this.houseId,
      required this.locationId,
      required this.councilId,
      this.ownerId,
      required final List<String> photoUrls,
      final Map<String, dynamic>? medicalHistory,
      final Map<String, dynamic>? censusData,
      final Map<String, dynamic>? metadata})
      : _photoUrls = photoUrls,
        _medicalHistory = medicalHistory,
        _censusData = censusData,
        _metadata = metadata;

  factory _$AnimalImpl.fromJson(Map<String, dynamic> json) =>
      _$$AnimalImplFromJson(json);

  @override
  final String id;
  @override
  final String? name;
  @override
  final String species;
  @override
  final String? breed;
  @override
  final String? color;
  @override
  final String sex;
  @override
  @JsonKey(fromJson: _parseEstimatedAge)
  final int? estimatedAge;
  @override
  @JsonKey(fromJson: _parseWeight)
  final double? weight;
  @override
  final String? microchipNumber;
  @override
  final DateTime registrationDate;
  @override
  final DateTime lastUpdated;
  @override
  final bool isActive;
  @override
  final String houseId;
  @override
  final String locationId;
  @override
  final String councilId;
  @override
  final String? ownerId;
  final List<String> _photoUrls;
  @override
  List<String> get photoUrls {
    if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_photoUrls);
  }

  final Map<String, dynamic>? _medicalHistory;
  @override
  Map<String, dynamic>? get medicalHistory {
    final value = _medicalHistory;
    if (value == null) return null;
    if (_medicalHistory is EqualUnmodifiableMapView) return _medicalHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, dynamic>? _censusData;
  @override
  Map<String, dynamic>? get censusData {
    final value = _censusData;
    if (value == null) return null;
    if (_censusData is EqualUnmodifiableMapView) return _censusData;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

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
    return 'Animal(id: $id, name: $name, species: $species, breed: $breed, color: $color, sex: $sex, estimatedAge: $estimatedAge, weight: $weight, microchipNumber: $microchipNumber, registrationDate: $registrationDate, lastUpdated: $lastUpdated, isActive: $isActive, houseId: $houseId, locationId: $locationId, councilId: $councilId, ownerId: $ownerId, photoUrls: $photoUrls, medicalHistory: $medicalHistory, censusData: $censusData, metadata: $metadata)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Animal'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('species', species))
      ..add(DiagnosticsProperty('breed', breed))
      ..add(DiagnosticsProperty('color', color))
      ..add(DiagnosticsProperty('sex', sex))
      ..add(DiagnosticsProperty('estimatedAge', estimatedAge))
      ..add(DiagnosticsProperty('weight', weight))
      ..add(DiagnosticsProperty('microchipNumber', microchipNumber))
      ..add(DiagnosticsProperty('registrationDate', registrationDate))
      ..add(DiagnosticsProperty('lastUpdated', lastUpdated))
      ..add(DiagnosticsProperty('isActive', isActive))
      ..add(DiagnosticsProperty('houseId', houseId))
      ..add(DiagnosticsProperty('locationId', locationId))
      ..add(DiagnosticsProperty('councilId', councilId))
      ..add(DiagnosticsProperty('ownerId', ownerId))
      ..add(DiagnosticsProperty('photoUrls', photoUrls))
      ..add(DiagnosticsProperty('medicalHistory', medicalHistory))
      ..add(DiagnosticsProperty('censusData', censusData))
      ..add(DiagnosticsProperty('metadata', metadata));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AnimalImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.species, species) || other.species == species) &&
            (identical(other.breed, breed) || other.breed == breed) &&
            (identical(other.color, color) || other.color == color) &&
            (identical(other.sex, sex) || other.sex == sex) &&
            (identical(other.estimatedAge, estimatedAge) ||
                other.estimatedAge == estimatedAge) &&
            (identical(other.weight, weight) || other.weight == weight) &&
            (identical(other.microchipNumber, microchipNumber) ||
                other.microchipNumber == microchipNumber) &&
            (identical(other.registrationDate, registrationDate) ||
                other.registrationDate == registrationDate) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.houseId, houseId) || other.houseId == houseId) &&
            (identical(other.locationId, locationId) ||
                other.locationId == locationId) &&
            (identical(other.councilId, councilId) ||
                other.councilId == councilId) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            const DeepCollectionEquality()
                .equals(other._photoUrls, _photoUrls) &&
            const DeepCollectionEquality()
                .equals(other._medicalHistory, _medicalHistory) &&
            const DeepCollectionEquality()
                .equals(other._censusData, _censusData) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        species,
        breed,
        color,
        sex,
        estimatedAge,
        weight,
        microchipNumber,
        registrationDate,
        lastUpdated,
        isActive,
        houseId,
        locationId,
        councilId,
        ownerId,
        const DeepCollectionEquality().hash(_photoUrls),
        const DeepCollectionEquality().hash(_medicalHistory),
        const DeepCollectionEquality().hash(_censusData),
        const DeepCollectionEquality().hash(_metadata)
      ]);

  /// Create a copy of Animal
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AnimalImplCopyWith<_$AnimalImpl> get copyWith =>
      __$$AnimalImplCopyWithImpl<_$AnimalImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AnimalImplToJson(
      this,
    );
  }
}

abstract class _Animal implements Animal {
  const factory _Animal(
      {required final String id,
      final String? name,
      required final String species,
      final String? breed,
      final String? color,
      required final String sex,
      @JsonKey(fromJson: _parseEstimatedAge) final int? estimatedAge,
      @JsonKey(fromJson: _parseWeight) final double? weight,
      final String? microchipNumber,
      required final DateTime registrationDate,
      required final DateTime lastUpdated,
      required final bool isActive,
      required final String houseId,
      required final String locationId,
      required final String councilId,
      final String? ownerId,
      required final List<String> photoUrls,
      final Map<String, dynamic>? medicalHistory,
      final Map<String, dynamic>? censusData,
      final Map<String, dynamic>? metadata}) = _$AnimalImpl;

  factory _Animal.fromJson(Map<String, dynamic> json) = _$AnimalImpl.fromJson;

  @override
  String get id;
  @override
  String? get name;
  @override
  String get species;
  @override
  String? get breed;
  @override
  String? get color;
  @override
  String get sex;
  @override
  @JsonKey(fromJson: _parseEstimatedAge)
  int? get estimatedAge;
  @override
  @JsonKey(fromJson: _parseWeight)
  double? get weight;
  @override
  String? get microchipNumber;
  @override
  DateTime get registrationDate;
  @override
  DateTime get lastUpdated;
  @override
  bool get isActive;
  @override
  String get houseId;
  @override
  String get locationId;
  @override
  String get councilId;
  @override
  String? get ownerId;
  @override
  List<String> get photoUrls;
  @override
  Map<String, dynamic>? get medicalHistory;
  @override
  Map<String, dynamic>? get censusData;
  @override
  Map<String, dynamic>? get metadata;

  /// Create a copy of Animal
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AnimalImplCopyWith<_$AnimalImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
