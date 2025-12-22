// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analytics_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AnalyticsHistoryModelAdapter extends TypeAdapter<AnalyticsHistoryModel> {
  @override
  final int typeId = 90;

  @override
  AnalyticsHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AnalyticsHistoryModel(
      date: fields[0] as DateTime,
      totalFollowers: fields[1] as int,
      totalPosts: fields[2] as int,
      avgEngagementRate: fields[3] as double,
      followersByPlatform: (fields[4] as Map).cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, AnalyticsHistoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.totalFollowers)
      ..writeByte(2)
      ..write(obj.totalPosts)
      ..writeByte(3)
      ..write(obj.avgEngagementRate)
      ..writeByte(4)
      ..write(obj.followersByPlatform);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AnalyticsHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
