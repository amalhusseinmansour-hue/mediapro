// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LoginHistoryModelAdapter extends TypeAdapter<LoginHistoryModel> {
  @override
  final int typeId = 30;

  @override
  LoginHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LoginHistoryModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      loginTime: fields[2] as DateTime,
      deviceInfo: fields[3] as String?,
      ipAddress: fields[4] as String?,
      location: fields[5] as String?,
      loginMethod: fields[6] as String,
      isSuccessful: fields[7] as bool,
      failureReason: fields[8] as String?,
      logoutTime: fields[9] as DateTime?,
      sessionDuration: fields[10] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, LoginHistoryModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.loginTime)
      ..writeByte(3)
      ..write(obj.deviceInfo)
      ..writeByte(4)
      ..write(obj.ipAddress)
      ..writeByte(5)
      ..write(obj.location)
      ..writeByte(6)
      ..write(obj.loginMethod)
      ..writeByte(7)
      ..write(obj.isSuccessful)
      ..writeByte(8)
      ..write(obj.failureReason)
      ..writeByte(9)
      ..write(obj.logoutTime)
      ..writeByte(10)
      ..write(obj.sessionDuration);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
