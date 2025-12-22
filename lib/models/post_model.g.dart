// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostModelAdapter extends TypeAdapter<PostModel> {
  @override
  final int typeId = 6;

  @override
  PostModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostModel(
      id: fields[0] as String,
      content: fields[1] as String,
      imageUrls: (fields[2] as List).cast<String>(),
      platforms: (fields[3] as List).cast<String>(),
      createdAt: fields[4] as DateTime,
      publishedAt: fields[5] as DateTime?,
      status: fields[6] as PostStatus,
      analytics: (fields[7] as Map?)?.cast<String, dynamic>(),
      hashtags: (fields[8] as List).cast<String>(),
      isScheduled: fields[9] as bool,
      scheduledTime: fields[10] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PostModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.imageUrls)
      ..writeByte(3)
      ..write(obj.platforms)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.publishedAt)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.analytics)
      ..writeByte(8)
      ..write(obj.hashtags)
      ..writeByte(9)
      ..write(obj.isScheduled)
      ..writeByte(10)
      ..write(obj.scheduledTime);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PostStatusAdapter extends TypeAdapter<PostStatus> {
  @override
  final int typeId = 7;

  @override
  PostStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PostStatus.draft;
      case 1:
        return PostStatus.scheduled;
      case 2:
        return PostStatus.published;
      case 3:
        return PostStatus.failed;
      default:
        return PostStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, PostStatus obj) {
    switch (obj) {
      case PostStatus.draft:
        writer.writeByte(0);
        break;
      case PostStatus.scheduled:
        writer.writeByte(1);
        break;
      case PostStatus.published:
        writer.writeByte(2);
        break;
      case PostStatus.failed:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
