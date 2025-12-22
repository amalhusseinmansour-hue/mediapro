// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sponsored_ad_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TargetAudienceAdapter extends TypeAdapter<TargetAudience> {
  @override
  final int typeId = 74;

  @override
  TargetAudience read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TargetAudience(
      ageRange: fields[0] as String?,
      genders: (fields[1] as List?)?.cast<String>(),
      locations: (fields[2] as List?)?.cast<String>(),
      interests: (fields[3] as List?)?.cast<String>(),
      languages: (fields[4] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, TargetAudience obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.ageRange)
      ..writeByte(1)
      ..write(obj.genders)
      ..writeByte(2)
      ..write(obj.locations)
      ..writeByte(3)
      ..write(obj.interests)
      ..writeByte(4)
      ..write(obj.languages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TargetAudienceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SponsoredAdModelAdapter extends TypeAdapter<SponsoredAdModel> {
  @override
  final int typeId = 75;

  @override
  SponsoredAdModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SponsoredAdModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      title: fields[2] as String,
      description: fields[3] as String,
      adType: fields[4] as AdType,
      platforms: (fields[5] as List).cast<AdPlatform>(),
      objective: fields[6] as AdObjective,
      budget: fields[7] as double,
      durationDays: fields[8] as int,
      targetAudience: fields[9] as TargetAudience?,
      websiteUrl: fields[10] as String?,
      callToAction: fields[11] as String?,
      imageUrls: (fields[12] as List?)?.cast<String>(),
      status: fields[13] as AdStatus,
      createdAt: fields[14] as DateTime,
      reviewedAt: fields[15] as DateTime?,
      startDate: fields[16] as DateTime?,
      endDate: fields[17] as DateTime?,
      adminNote: fields[18] as String?,
      rejectionReason: fields[19] as String?,
      statistics: (fields[20] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, SponsoredAdModel obj) {
    writer
      ..writeByte(21)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.adType)
      ..writeByte(5)
      ..write(obj.platforms)
      ..writeByte(6)
      ..write(obj.objective)
      ..writeByte(7)
      ..write(obj.budget)
      ..writeByte(8)
      ..write(obj.durationDays)
      ..writeByte(9)
      ..write(obj.targetAudience)
      ..writeByte(10)
      ..write(obj.websiteUrl)
      ..writeByte(11)
      ..write(obj.callToAction)
      ..writeByte(12)
      ..write(obj.imageUrls)
      ..writeByte(13)
      ..write(obj.status)
      ..writeByte(14)
      ..write(obj.createdAt)
      ..writeByte(15)
      ..write(obj.reviewedAt)
      ..writeByte(16)
      ..write(obj.startDate)
      ..writeByte(17)
      ..write(obj.endDate)
      ..writeByte(18)
      ..write(obj.adminNote)
      ..writeByte(19)
      ..write(obj.rejectionReason)
      ..writeByte(20)
      ..write(obj.statistics);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SponsoredAdModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdStatusAdapter extends TypeAdapter<AdStatus> {
  @override
  final int typeId = 70;

  @override
  AdStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdStatus.pending;
      case 1:
        return AdStatus.underReview;
      case 2:
        return AdStatus.approved;
      case 3:
        return AdStatus.rejected;
      case 4:
        return AdStatus.active;
      case 5:
        return AdStatus.completed;
      case 6:
        return AdStatus.cancelled;
      default:
        return AdStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, AdStatus obj) {
    switch (obj) {
      case AdStatus.pending:
        writer.writeByte(0);
        break;
      case AdStatus.underReview:
        writer.writeByte(1);
        break;
      case AdStatus.approved:
        writer.writeByte(2);
        break;
      case AdStatus.rejected:
        writer.writeByte(3);
        break;
      case AdStatus.active:
        writer.writeByte(4);
        break;
      case AdStatus.completed:
        writer.writeByte(5);
        break;
      case AdStatus.cancelled:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdTypeAdapter extends TypeAdapter<AdType> {
  @override
  final int typeId = 71;

  @override
  AdType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdType.post;
      case 1:
        return AdType.story;
      case 2:
        return AdType.video;
      case 3:
        return AdType.carousel;
      case 4:
        return AdType.collection;
      default:
        return AdType.post;
    }
  }

  @override
  void write(BinaryWriter writer, AdType obj) {
    switch (obj) {
      case AdType.post:
        writer.writeByte(0);
        break;
      case AdType.story:
        writer.writeByte(1);
        break;
      case AdType.video:
        writer.writeByte(2);
        break;
      case AdType.carousel:
        writer.writeByte(3);
        break;
      case AdType.collection:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdPlatformAdapter extends TypeAdapter<AdPlatform> {
  @override
  final int typeId = 72;

  @override
  AdPlatform read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdPlatform.facebook;
      case 1:
        return AdPlatform.instagram;
      case 2:
        return AdPlatform.twitter;
      case 3:
        return AdPlatform.linkedin;
      case 4:
        return AdPlatform.tiktok;
      case 5:
        return AdPlatform.youtube;
      default:
        return AdPlatform.facebook;
    }
  }

  @override
  void write(BinaryWriter writer, AdPlatform obj) {
    switch (obj) {
      case AdPlatform.facebook:
        writer.writeByte(0);
        break;
      case AdPlatform.instagram:
        writer.writeByte(1);
        break;
      case AdPlatform.twitter:
        writer.writeByte(2);
        break;
      case AdPlatform.linkedin:
        writer.writeByte(3);
        break;
      case AdPlatform.tiktok:
        writer.writeByte(4);
        break;
      case AdPlatform.youtube:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdPlatformAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AdObjectiveAdapter extends TypeAdapter<AdObjective> {
  @override
  final int typeId = 73;

  @override
  AdObjective read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AdObjective.awareness;
      case 1:
        return AdObjective.traffic;
      case 2:
        return AdObjective.engagement;
      case 3:
        return AdObjective.leads;
      case 4:
        return AdObjective.sales;
      case 5:
        return AdObjective.appInstalls;
      default:
        return AdObjective.awareness;
    }
  }

  @override
  void write(BinaryWriter writer, AdObjective obj) {
    switch (obj) {
      case AdObjective.awareness:
        writer.writeByte(0);
        break;
      case AdObjective.traffic:
        writer.writeByte(1);
        break;
      case AdObjective.engagement:
        writer.writeByte(2);
        break;
      case AdObjective.leads:
        writer.writeByte(3);
        break;
      case AdObjective.sales:
        writer.writeByte(4);
        break;
      case AdObjective.appInstalls:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdObjectiveAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
