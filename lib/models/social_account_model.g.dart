// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_account_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SocialAccountModelAdapter extends TypeAdapter<SocialAccountModel> {
  @override
  final int typeId = 16;

  @override
  SocialAccountModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SocialAccountModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      platform: fields[2] as String,
      accountName: fields[3] as String,
      accountId: fields[4] as String,
      profileImageUrl: fields[5] as String?,
      accessToken: fields[6] as String?,
      connectedDate: fields[7] as DateTime,
      isActive: fields[8] as bool,
      platformData: (fields[9] as Map?)?.cast<String, dynamic>(),
      stats: fields[10] as AccountStats?,
    );
  }

  @override
  void write(BinaryWriter writer, SocialAccountModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.platform)
      ..writeByte(3)
      ..write(obj.accountName)
      ..writeByte(4)
      ..write(obj.accountId)
      ..writeByte(5)
      ..write(obj.profileImageUrl)
      ..writeByte(6)
      ..write(obj.accessToken)
      ..writeByte(7)
      ..write(obj.connectedDate)
      ..writeByte(8)
      ..write(obj.isActive)
      ..writeByte(9)
      ..write(obj.platformData)
      ..writeByte(10)
      ..write(obj.stats);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SocialAccountModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AccountStatsAdapter extends TypeAdapter<AccountStats> {
  @override
  final int typeId = 17;

  @override
  AccountStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AccountStats(
      followers: fields[0] as int,
      following: fields[1] as int,
      postsCount: fields[2] as int,
      engagementRate: fields[3] as double,
      lastUpdated: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AccountStats obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.followers)
      ..writeByte(1)
      ..write(obj.following)
      ..writeByte(2)
      ..write(obj.postsCount)
      ..writeByte(3)
      ..write(obj.engagementRate)
      ..writeByte(4)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AccountStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
