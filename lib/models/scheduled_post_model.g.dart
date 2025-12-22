// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scheduled_post_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScheduledPostAdapter extends TypeAdapter<ScheduledPost> {
  @override
  final int typeId = 50;

  @override
  ScheduledPost read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScheduledPost(
      id: fields[0] as String,
      userId: fields[1] as String,
      content: fields[2] as String,
      platforms: (fields[3] as List).cast<String>(),
      scheduledTime: fields[4] as DateTime,
      status: fields[5] as String,
      mediaUrls: (fields[6] as List?)?.cast<String>(),
      platformSettings: (fields[7] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[8] as DateTime,
      publishedAt: fields[9] as DateTime?,
      errorMessage: fields[10] as String?,
      platformPostIds: (fields[11] as Map?)?.cast<String, String>(),
      useN8n: fields[12] as bool,
      n8nWorkflowId: fields[13] as String?,
      n8nExecutionId: fields[14] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ScheduledPost obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.platforms)
      ..writeByte(4)
      ..write(obj.scheduledTime)
      ..writeByte(5)
      ..write(obj.status)
      ..writeByte(6)
      ..write(obj.mediaUrls)
      ..writeByte(7)
      ..write(obj.platformSettings)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.publishedAt)
      ..writeByte(10)
      ..write(obj.errorMessage)
      ..writeByte(11)
      ..write(obj.platformPostIds)
      ..writeByte(12)
      ..write(obj.useN8n)
      ..writeByte(13)
      ..write(obj.n8nWorkflowId)
      ..writeByte(14)
      ..write(obj.n8nExecutionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScheduledPostAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
