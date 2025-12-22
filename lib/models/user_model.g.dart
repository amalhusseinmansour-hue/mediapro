// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 24;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      name: fields[1] as String,
      email: fields[2] as String,
      photoUrl: fields[3] as String?,
      subscriptionType: fields[4] as String,
      subscriptionStartDate: fields[5] as DateTime,
      subscriptionEndDate: fields[6] as DateTime?,
      isActive: fields[7] as bool,
      phoneNumber: fields[8] as String,
      isLoggedIn: fields[9] as bool,
      lastLogin: fields[10] as DateTime?,
      subscriptionTier: fields[11] as String,
      userType: fields[12] as String,
      isPhoneVerified: fields[13] as bool,
      isAdmin: fields[14] as bool,
      createdAt: fields[15] as DateTime?,
      commercialRegistration: fields[16] as String?,
      tradeLicense: fields[17] as String?,
      companyName: fields[18] as String?,
      businessVerificationStatus: fields[19] as String,
      verificationRejectionReason: fields[20] as String?,
      accountStatus: fields[21] as String,
      accountRejectionReason: fields[22] as String?,
      accountActivatedAt: fields[23] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.photoUrl)
      ..writeByte(4)
      ..write(obj.subscriptionType)
      ..writeByte(5)
      ..write(obj.subscriptionStartDate)
      ..writeByte(6)
      ..write(obj.subscriptionEndDate)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.phoneNumber)
      ..writeByte(9)
      ..write(obj.isLoggedIn)
      ..writeByte(10)
      ..write(obj.lastLogin)
      ..writeByte(11)
      ..write(obj.subscriptionTier)
      ..writeByte(12)
      ..write(obj.userType)
      ..writeByte(13)
      ..write(obj.isPhoneVerified)
      ..writeByte(14)
      ..write(obj.isAdmin)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.commercialRegistration)
      ..writeByte(17)
      ..write(obj.tradeLicense)
      ..writeByte(18)
      ..write(obj.companyName)
      ..writeByte(19)
      ..write(obj.businessVerificationStatus)
      ..writeByte(20)
      ..write(obj.verificationRejectionReason)
      ..writeByte(21)
      ..write(obj.accountStatus)
      ..writeByte(22)
      ..write(obj.accountRejectionReason)
      ..writeByte(23)
      ..write(obj.accountActivatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
