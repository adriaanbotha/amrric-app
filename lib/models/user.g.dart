// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 1;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
      role: fields[3] as UserRole,
      municipalityId: fields[4] as String?,
      councilId: fields[5] as String?,
      locationId: fields[6] as String?,
      lastLogin: fields[7] as DateTime?,
      isActive: fields[8] as bool,
      loginAttempts: fields[9] as int,
      activityLog: (fields[10] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      createdAt: fields[11] as DateTime?,
      updatedAt: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.municipalityId)
      ..writeByte(5)
      ..write(obj.councilId)
      ..writeByte(6)
      ..write(obj.locationId)
      ..writeByte(7)
      ..write(obj.lastLogin)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.loginAttempts)
      ..writeByte(10)
      ..write(obj.activityLog)
      ..writeByte(11)
      ..write(obj.createdAt)
      ..writeByte(12)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserRoleAdapter extends TypeAdapter<UserRole> {
  @override
  final int typeId = 0;

  @override
  UserRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return UserRole.systemAdmin;
      case 1:
        return UserRole.municipalityAdmin;
      case 2:
        return UserRole.veterinaryUser;
      case 3:
        return UserRole.censusUser;
      default:
        return UserRole.systemAdmin;
    }
  }

  @override
  void write(BinaryWriter writer, UserRole obj) {
    switch (obj) {
      case UserRole.systemAdmin:
        writer.writeByte(0);
        break;
      case UserRole.municipalityAdmin:
        writer.writeByte(1);
        break;
      case UserRole.veterinaryUser:
        writer.writeByte(2);
        break;
      case UserRole.censusUser:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
