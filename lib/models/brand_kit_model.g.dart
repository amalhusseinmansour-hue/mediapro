// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_kit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BrandKitAdapter extends TypeAdapter<BrandKit> {
  @override
  final int typeId = 80;

  @override
  BrandKit read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BrandKit(
      id: fields[0] as String,
      userId: fields[1] as String,
      brandName: fields[2] as String,
      industry: fields[3] as String,
      description: fields[4] as String,
      primaryColors: (fields[5] as List).cast<String>(),
      secondaryColors: (fields[6] as List).cast<String>(),
      logoUrl: fields[7] as String?,
      websiteUrl: fields[8] as String?,
      tone: fields[9] as String,
      keywords: (fields[10] as List).cast<String>(),
      targetAudience: (fields[11] as List).cast<String>(),
      slogan: fields[12] as String?,
      fonts: (fields[13] as Map?)?.cast<String, dynamic>(),
      createdAt: fields[14] as DateTime,
      updatedAt: fields[15] as DateTime,
      trendingData: (fields[16] as Map?)?.cast<String, dynamic>(),
      aiSuggestions: (fields[17] as Map?)?.cast<String, dynamic>(),
      isActive: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, BrandKit obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.brandName)
      ..writeByte(3)
      ..write(obj.industry)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.primaryColors)
      ..writeByte(6)
      ..write(obj.secondaryColors)
      ..writeByte(7)
      ..write(obj.logoUrl)
      ..writeByte(8)
      ..write(obj.websiteUrl)
      ..writeByte(9)
      ..write(obj.tone)
      ..writeByte(10)
      ..write(obj.keywords)
      ..writeByte(11)
      ..write(obj.targetAudience)
      ..writeByte(12)
      ..write(obj.slogan)
      ..writeByte(13)
      ..write(obj.fonts)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.updatedAt)
      ..writeByte(16)
      ..write(obj.trendingData)
      ..writeByte(17)
      ..write(obj.aiSuggestions)
      ..writeByte(18)
      ..write(obj.isActive);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrandKitAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
