import 'package:hive/hive.dart';
import 'offline_manager.dart';

/// Hive Adapter للعمليات المعلقة
class PendingOperationAdapter extends TypeAdapter<PendingOperation> {
  @override
  final int typeId = 100;

  @override
  PendingOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return PendingOperation(
      id: fields[0] as String,
      type: fields[1] as OperationType,
      data: Map<String, dynamic>.from(fields[2] as Map),
      createdAt: fields[3] as DateTime,
      retries: fields[4] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, PendingOperation obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.retries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

/// Hive Adapter لأنواع العمليات
class OperationTypeAdapter extends TypeAdapter<OperationType> {
  @override
  final int typeId = 101;

  @override
  OperationType read(BinaryReader reader) {
    final index = reader.readByte();
    return OperationType.values[index];
  }

  @override
  void write(BinaryWriter writer, OperationType obj) {
    writer.writeByte(obj.index);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
