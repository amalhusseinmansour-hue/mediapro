// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserPreferencesModelAdapter extends TypeAdapter<UserPreferencesModel> {
  @override
  final int typeId = 10;

  @override
  UserPreferencesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserPreferencesModel(
      userId: fields[0] as String,
      language: fields[1] as String,
      darkMode: fields[2] as bool,
      notificationsEnabled: fields[3] as bool,
      soundEnabled: fields[4] as bool,
      vibrationEnabled: fields[5] as bool,
      defaultPlatform: fields[6] as String,
      favoritePlatforms: (fields[7] as List).cast<String>(),
      autoSaveDrafts: fields[8] as bool,
      reminderMinutesBefore: fields[9] as int,
      lastBackupDate: fields[10] as DateTime?,
      analyticsEnabled: fields[11] as bool,
      customSettings: (fields[12] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferencesModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.language)
      ..writeByte(2)
      ..write(obj.darkMode)
      ..writeByte(3)
      ..write(obj.notificationsEnabled)
      ..writeByte(4)
      ..write(obj.soundEnabled)
      ..writeByte(5)
      ..write(obj.vibrationEnabled)
      ..writeByte(6)
      ..write(obj.defaultPlatform)
      ..writeByte(7)
      ..write(obj.favoritePlatforms)
      ..writeByte(8)
      ..write(obj.autoSaveDrafts)
      ..writeByte(9)
      ..write(obj.reminderMinutesBefore)
      ..writeByte(10)
      ..write(obj.lastBackupDate)
      ..writeByte(11)
      ..write(obj.analyticsEnabled)
      ..writeByte(12)
      ..write(obj.customSettings);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserPreferencesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
