// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'clinical_note_template.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ClinicalNoteTemplate _$ClinicalNoteTemplateFromJson(Map<String, dynamic> json) {
  return _ClinicalNoteTemplate.fromJson(json);
}

/// @nodoc
mixin _$ClinicalNoteTemplate {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get appliesTo =>
      throw _privateConstructorUsedError; // e.g., "Male Dogs", "Female Dogs", "All"
  String get author => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get lastUpdated => throw _privateConstructorUsedError;
  List<TemplateItem> get problems => throw _privateConstructorUsedError;
  List<TemplateItem> get procedures => throw _privateConstructorUsedError;
  List<TemplateItem> get treatments => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;

  /// Serializes this ClinicalNoteTemplate to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ClinicalNoteTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ClinicalNoteTemplateCopyWith<ClinicalNoteTemplate> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ClinicalNoteTemplateCopyWith<$Res> {
  factory $ClinicalNoteTemplateCopyWith(ClinicalNoteTemplate value,
          $Res Function(ClinicalNoteTemplate) then) =
      _$ClinicalNoteTemplateCopyWithImpl<$Res, ClinicalNoteTemplate>;
  @useResult
  $Res call(
      {String id,
      String name,
      String appliesTo,
      String author,
      DateTime createdAt,
      DateTime lastUpdated,
      List<TemplateItem> problems,
      List<TemplateItem> procedures,
      List<TemplateItem> treatments,
      String? description});
}

/// @nodoc
class _$ClinicalNoteTemplateCopyWithImpl<$Res,
        $Val extends ClinicalNoteTemplate>
    implements $ClinicalNoteTemplateCopyWith<$Res> {
  _$ClinicalNoteTemplateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ClinicalNoteTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? appliesTo = null,
    Object? author = null,
    Object? createdAt = null,
    Object? lastUpdated = null,
    Object? problems = null,
    Object? procedures = null,
    Object? treatments = null,
    Object? description = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      appliesTo: null == appliesTo
          ? _value.appliesTo
          : appliesTo // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      problems: null == problems
          ? _value.problems
          : problems // ignore: cast_nullable_to_non_nullable
              as List<TemplateItem>,
      procedures: null == procedures
          ? _value.procedures
          : procedures // ignore: cast_nullable_to_non_nullable
              as List<TemplateItem>,
      treatments: null == treatments
          ? _value.treatments
          : treatments // ignore: cast_nullable_to_non_nullable
              as List<TemplateItem>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ClinicalNoteTemplateImplCopyWith<$Res>
    implements $ClinicalNoteTemplateCopyWith<$Res> {
  factory _$$ClinicalNoteTemplateImplCopyWith(_$ClinicalNoteTemplateImpl value,
          $Res Function(_$ClinicalNoteTemplateImpl) then) =
      __$$ClinicalNoteTemplateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String appliesTo,
      String author,
      DateTime createdAt,
      DateTime lastUpdated,
      List<TemplateItem> problems,
      List<TemplateItem> procedures,
      List<TemplateItem> treatments,
      String? description});
}

/// @nodoc
class __$$ClinicalNoteTemplateImplCopyWithImpl<$Res>
    extends _$ClinicalNoteTemplateCopyWithImpl<$Res, _$ClinicalNoteTemplateImpl>
    implements _$$ClinicalNoteTemplateImplCopyWith<$Res> {
  __$$ClinicalNoteTemplateImplCopyWithImpl(_$ClinicalNoteTemplateImpl _value,
      $Res Function(_$ClinicalNoteTemplateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ClinicalNoteTemplate
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? appliesTo = null,
    Object? author = null,
    Object? createdAt = null,
    Object? lastUpdated = null,
    Object? problems = null,
    Object? procedures = null,
    Object? treatments = null,
    Object? description = freezed,
  }) {
    return _then(_$ClinicalNoteTemplateImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      appliesTo: null == appliesTo
          ? _value.appliesTo
          : appliesTo // ignore: cast_nullable_to_non_nullable
              as String,
      author: null == author
          ? _value.author
          : author // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      lastUpdated: null == lastUpdated
          ? _value.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      problems: null == problems
          ? _value._problems
          : problems // ignore: cast_nullable_to_non_nullable
              as List<TemplateItem>,
      procedures: null == procedures
          ? _value._procedures
          : procedures // ignore: cast_nullable_to_non_nullable
              as List<TemplateItem>,
      treatments: null == treatments
          ? _value._treatments
          : treatments // ignore: cast_nullable_to_non_nullable
              as List<TemplateItem>,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ClinicalNoteTemplateImpl implements _ClinicalNoteTemplate {
  const _$ClinicalNoteTemplateImpl(
      {required this.id,
      required this.name,
      required this.appliesTo,
      required this.author,
      required this.createdAt,
      required this.lastUpdated,
      final List<TemplateItem> problems = const [],
      final List<TemplateItem> procedures = const [],
      final List<TemplateItem> treatments = const [],
      this.description})
      : _problems = problems,
        _procedures = procedures,
        _treatments = treatments;

  factory _$ClinicalNoteTemplateImpl.fromJson(Map<String, dynamic> json) =>
      _$$ClinicalNoteTemplateImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String appliesTo;
// e.g., "Male Dogs", "Female Dogs", "All"
  @override
  final String author;
  @override
  final DateTime createdAt;
  @override
  final DateTime lastUpdated;
  final List<TemplateItem> _problems;
  @override
  @JsonKey()
  List<TemplateItem> get problems {
    if (_problems is EqualUnmodifiableListView) return _problems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_problems);
  }

  final List<TemplateItem> _procedures;
  @override
  @JsonKey()
  List<TemplateItem> get procedures {
    if (_procedures is EqualUnmodifiableListView) return _procedures;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_procedures);
  }

  final List<TemplateItem> _treatments;
  @override
  @JsonKey()
  List<TemplateItem> get treatments {
    if (_treatments is EqualUnmodifiableListView) return _treatments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_treatments);
  }

  @override
  final String? description;

  @override
  String toString() {
    return 'ClinicalNoteTemplate(id: $id, name: $name, appliesTo: $appliesTo, author: $author, createdAt: $createdAt, lastUpdated: $lastUpdated, problems: $problems, procedures: $procedures, treatments: $treatments, description: $description)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ClinicalNoteTemplateImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.appliesTo, appliesTo) ||
                other.appliesTo == appliesTo) &&
            (identical(other.author, author) || other.author == author) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            const DeepCollectionEquality().equals(other._problems, _problems) &&
            const DeepCollectionEquality()
                .equals(other._procedures, _procedures) &&
            const DeepCollectionEquality()
                .equals(other._treatments, _treatments) &&
            (identical(other.description, description) ||
                other.description == description));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      appliesTo,
      author,
      createdAt,
      lastUpdated,
      const DeepCollectionEquality().hash(_problems),
      const DeepCollectionEquality().hash(_procedures),
      const DeepCollectionEquality().hash(_treatments),
      description);

  /// Create a copy of ClinicalNoteTemplate
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ClinicalNoteTemplateImplCopyWith<_$ClinicalNoteTemplateImpl>
      get copyWith =>
          __$$ClinicalNoteTemplateImplCopyWithImpl<_$ClinicalNoteTemplateImpl>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ClinicalNoteTemplateImplToJson(
      this,
    );
  }
}

abstract class _ClinicalNoteTemplate implements ClinicalNoteTemplate {
  const factory _ClinicalNoteTemplate(
      {required final String id,
      required final String name,
      required final String appliesTo,
      required final String author,
      required final DateTime createdAt,
      required final DateTime lastUpdated,
      final List<TemplateItem> problems,
      final List<TemplateItem> procedures,
      final List<TemplateItem> treatments,
      final String? description}) = _$ClinicalNoteTemplateImpl;

  factory _ClinicalNoteTemplate.fromJson(Map<String, dynamic> json) =
      _$ClinicalNoteTemplateImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get appliesTo; // e.g., "Male Dogs", "Female Dogs", "All"
  @override
  String get author;
  @override
  DateTime get createdAt;
  @override
  DateTime get lastUpdated;
  @override
  List<TemplateItem> get problems;
  @override
  List<TemplateItem> get procedures;
  @override
  List<TemplateItem> get treatments;
  @override
  String? get description;

  /// Create a copy of ClinicalNoteTemplate
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ClinicalNoteTemplateImplCopyWith<_$ClinicalNoteTemplateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

TemplateItem _$TemplateItemFromJson(Map<String, dynamic> json) {
  return _TemplateItem.fromJson(json);
}

/// @nodoc
mixin _$TemplateItem {
  String get category => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  String get notes => throw _privateConstructorUsedError;

  /// Serializes this TemplateItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TemplateItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TemplateItemCopyWith<TemplateItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TemplateItemCopyWith<$Res> {
  factory $TemplateItemCopyWith(
          TemplateItem value, $Res Function(TemplateItem) then) =
      _$TemplateItemCopyWithImpl<$Res, TemplateItem>;
  @useResult
  $Res call({String category, String value, String notes});
}

/// @nodoc
class _$TemplateItemCopyWithImpl<$Res, $Val extends TemplateItem>
    implements $TemplateItemCopyWith<$Res> {
  _$TemplateItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TemplateItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? value = null,
    Object? notes = null,
  }) {
    return _then(_value.copyWith(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TemplateItemImplCopyWith<$Res>
    implements $TemplateItemCopyWith<$Res> {
  factory _$$TemplateItemImplCopyWith(
          _$TemplateItemImpl value, $Res Function(_$TemplateItemImpl) then) =
      __$$TemplateItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String category, String value, String notes});
}

/// @nodoc
class __$$TemplateItemImplCopyWithImpl<$Res>
    extends _$TemplateItemCopyWithImpl<$Res, _$TemplateItemImpl>
    implements _$$TemplateItemImplCopyWith<$Res> {
  __$$TemplateItemImplCopyWithImpl(
      _$TemplateItemImpl _value, $Res Function(_$TemplateItemImpl) _then)
      : super(_value, _then);

  /// Create a copy of TemplateItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? category = null,
    Object? value = null,
    Object? notes = null,
  }) {
    return _then(_$TemplateItemImpl(
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as String,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      notes: null == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TemplateItemImpl implements _TemplateItem {
  const _$TemplateItemImpl(
      {required this.category, required this.value, this.notes = ''});

  factory _$TemplateItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$TemplateItemImplFromJson(json);

  @override
  final String category;
  @override
  final String value;
  @override
  @JsonKey()
  final String notes;

  @override
  String toString() {
    return 'TemplateItem(category: $category, value: $value, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TemplateItemImpl &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, category, value, notes);

  /// Create a copy of TemplateItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TemplateItemImplCopyWith<_$TemplateItemImpl> get copyWith =>
      __$$TemplateItemImplCopyWithImpl<_$TemplateItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TemplateItemImplToJson(
      this,
    );
  }
}

abstract class _TemplateItem implements TemplateItem {
  const factory _TemplateItem(
      {required final String category,
      required final String value,
      final String notes}) = _$TemplateItemImpl;

  factory _TemplateItem.fromJson(Map<String, dynamic> json) =
      _$TemplateItemImpl.fromJson;

  @override
  String get category;
  @override
  String get value;
  @override
  String get notes;

  /// Create a copy of TemplateItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TemplateItemImplCopyWith<_$TemplateItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
