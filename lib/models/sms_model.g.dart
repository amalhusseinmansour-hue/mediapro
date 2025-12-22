// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sms_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SmsMessageAdapter extends TypeAdapter<SmsMessage> {
  @override
  final int typeId = 22;

  @override
  SmsMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmsMessage(
      id: fields[0] as String,
      recipient: fields[1] as String,
      message: fields[2] as String,
      status: fields[3] as SmsStatus,
      purpose: fields[4] as SmsPurpose,
      parts: fields[5] as int,
      cost: fields[6] as double,
      sentAt: fields[7] as DateTime,
      deliveredAt: fields[8] as DateTime?,
      errorMessage: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SmsMessage obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.recipient)
      ..writeByte(2)
      ..write(obj.message)
      ..writeByte(3)
      ..write(obj.status)
      ..writeByte(4)
      ..write(obj.purpose)
      ..writeByte(5)
      ..write(obj.parts)
      ..writeByte(6)
      ..write(obj.cost)
      ..writeByte(7)
      ..write(obj.sentAt)
      ..writeByte(8)
      ..write(obj.deliveredAt)
      ..writeByte(9)
      ..write(obj.errorMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmsMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SmsSettingsAdapter extends TypeAdapter<SmsSettings> {
  @override
  final int typeId = 23;

  @override
  SmsSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SmsSettings(
      apiKey: fields[0] as String?,
      senderId: fields[1] as String?,
      isEnabled: fields[2] as bool,
      costPerMessage: fields[3] as double,
      apiUrl: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SmsSettings obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.apiKey)
      ..writeByte(1)
      ..write(obj.senderId)
      ..writeByte(2)
      ..write(obj.isEnabled)
      ..writeByte(3)
      ..write(obj.costPerMessage)
      ..writeByte(4)
      ..write(obj.apiUrl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmsSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SmsStatusAdapter extends TypeAdapter<SmsStatus> {
  @override
  final int typeId = 20;

  @override
  SmsStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SmsStatus.pending;
      case 1:
        return SmsStatus.sent;
      case 2:
        return SmsStatus.delivered;
      case 3:
        return SmsStatus.failed;
      default:
        return SmsStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, SmsStatus obj) {
    switch (obj) {
      case SmsStatus.pending:
        writer.writeByte(0);
        break;
      case SmsStatus.sent:
        writer.writeByte(1);
        break;
      case SmsStatus.delivered:
        writer.writeByte(2);
        break;
      case SmsStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmsStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SmsPurposeAdapter extends TypeAdapter<SmsPurpose> {
  @override
  final int typeId = 21;

  @override
  SmsPurpose read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SmsPurpose.verification;
      case 1:
        return SmsPurpose.notification;
      case 2:
        return SmsPurpose.marketing;
      case 3:
        return SmsPurpose.other;
      default:
        return SmsPurpose.verification;
    }
  }

  @override
  void write(BinaryWriter writer, SmsPurpose obj) {
    switch (obj) {
      case SmsPurpose.verification:
        writer.writeByte(0);
        break;
      case SmsPurpose.notification:
        writer.writeByte(1);
        break;
      case SmsPurpose.marketing:
        writer.writeByte(2);
        break;
      case SmsPurpose.other:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SmsPurposeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
