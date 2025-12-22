// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotificationModelAdapter extends TypeAdapter<NotificationModel> {
  @override
  final int typeId = 1;

  @override
  NotificationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NotificationModel(
      id: fields[0] as String,
      title: fields[1] as String,
      body: fields[2] as String,
      type: fields[3] as NotificationType,
      timestamp: fields[4] as DateTime,
      isRead: fields[5] as bool,
      imageUrl: fields[6] as String?,
      data: (fields[7] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, NotificationModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.body)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.isRead)
      ..writeByte(6)
      ..write(obj.imageUrl)
      ..writeByte(7)
      ..write(obj.data);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NotificationTypeAdapter extends TypeAdapter<NotificationType> {
  @override
  final int typeId = 2;

  @override
  NotificationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NotificationType.general;
      case 1:
        return NotificationType.post;
      case 2:
        return NotificationType.scheduled;
      case 3:
        return NotificationType.analytics;
      case 4:
        return NotificationType.account;
      case 5:
        return NotificationType.system;
      case 6:
        return NotificationType.success;
      case 7:
        return NotificationType.error;
      case 8:
        return NotificationType.warning;
      default:
        return NotificationType.general;
    }
  }

  @override
  void write(BinaryWriter writer, NotificationType obj) {
    switch (obj) {
      case NotificationType.general:
        writer.writeByte(0);
        break;
      case NotificationType.post:
        writer.writeByte(1);
        break;
      case NotificationType.scheduled:
        writer.writeByte(2);
        break;
      case NotificationType.analytics:
        writer.writeByte(3);
        break;
      case NotificationType.account:
        writer.writeByte(4);
        break;
      case NotificationType.system:
        writer.writeByte(5);
        break;
      case NotificationType.success:
        writer.writeByte(6);
        break;
      case NotificationType.error:
        writer.writeByte(7);
        break;
      case NotificationType.warning:
        writer.writeByte(8);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotificationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
