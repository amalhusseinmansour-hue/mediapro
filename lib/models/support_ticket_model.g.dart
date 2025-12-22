// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'support_ticket_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupportTicketModelAdapter extends TypeAdapter<SupportTicketModel> {
  @override
  final int typeId = 60;

  @override
  SupportTicketModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupportTicketModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      subject: fields[2] as String,
      description: fields[3] as String,
      category: fields[4] as TicketCategory,
      priority: fields[5] as TicketPriority,
      status: fields[6] as TicketStatus,
      createdAt: fields[7] as DateTime,
      updatedAt: fields[8] as DateTime?,
      resolvedAt: fields[9] as DateTime?,
      response: fields[10] as String?,
      adminNote: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SupportTicketModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.subject)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.category)
      ..writeByte(5)
      ..write(obj.priority)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.resolvedAt)
      ..writeByte(10)
      ..write(obj.response)
      ..writeByte(11)
      ..write(obj.adminNote);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupportTicketModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TicketStatusAdapter extends TypeAdapter<TicketStatus> {
  @override
  final int typeId = 7;

  @override
  TicketStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TicketStatus.open;
      case 1:
        return TicketStatus.inProgress;
      case 2:
        return TicketStatus.resolved;
      case 3:
        return TicketStatus.closed;
      default:
        return TicketStatus.open;
    }
  }

  @override
  void write(BinaryWriter writer, TicketStatus obj) {
    switch (obj) {
      case TicketStatus.open:
        writer.writeByte(0);
        break;
      case TicketStatus.inProgress:
        writer.writeByte(1);
        break;
      case TicketStatus.resolved:
        writer.writeByte(2);
        break;
      case TicketStatus.closed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TicketPriorityAdapter extends TypeAdapter<TicketPriority> {
  @override
  final int typeId = 8;

  @override
  TicketPriority read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TicketPriority.low;
      case 1:
        return TicketPriority.medium;
      case 2:
        return TicketPriority.high;
      case 3:
        return TicketPriority.urgent;
      default:
        return TicketPriority.low;
    }
  }

  @override
  void write(BinaryWriter writer, TicketPriority obj) {
    switch (obj) {
      case TicketPriority.low:
        writer.writeByte(0);
        break;
      case TicketPriority.medium:
        writer.writeByte(1);
        break;
      case TicketPriority.high:
        writer.writeByte(2);
        break;
      case TicketPriority.urgent:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketPriorityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TicketCategoryAdapter extends TypeAdapter<TicketCategory> {
  @override
  final int typeId = 9;

  @override
  TicketCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TicketCategory.technical;
      case 1:
        return TicketCategory.billing;
      case 2:
        return TicketCategory.feature;
      case 3:
        return TicketCategory.bug;
      case 4:
        return TicketCategory.account;
      case 5:
        return TicketCategory.other;
      default:
        return TicketCategory.technical;
    }
  }

  @override
  void write(BinaryWriter writer, TicketCategory obj) {
    switch (obj) {
      case TicketCategory.technical:
        writer.writeByte(0);
        break;
      case TicketCategory.billing:
        writer.writeByte(1);
        break;
      case TicketCategory.feature:
        writer.writeByte(2);
        break;
      case TicketCategory.bug:
        writer.writeByte(3);
        break;
      case TicketCategory.account:
        writer.writeByte(4);
        break;
      case TicketCategory.other:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TicketCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
