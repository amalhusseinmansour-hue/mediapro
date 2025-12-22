// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentModelAdapter extends TypeAdapter<PaymentModel> {
  @override
  final int typeId = 9;

  @override
  PaymentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      paymobOrderId: fields[2] as int,
      paymobTransactionId: fields[3] as int?,
      subscriptionTier: fields[4] as String,
      amount: fields[5] as double,
      currency: fields[6] as String,
      status: fields[7] as PaymentStatusEnum,
      createdAt: fields[8] as DateTime,
      paidAt: fields[9] as DateTime?,
      paymentMethod: fields[10] as String,
      isYearly: fields[11] as bool,
      expiresAt: fields[12] as DateTime?,
      metadata: (fields[13] as Map?)?.cast<String, dynamic>(),
    );
  }

  @override
  void write(BinaryWriter writer, PaymentModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.paymobOrderId)
      ..writeByte(3)
      ..write(obj.paymobTransactionId)
      ..writeByte(4)
      ..write(obj.subscriptionTier)
      ..writeByte(5)
      ..write(obj.amount)
      ..writeByte(6)
      ..write(obj.currency)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.paidAt)
      ..writeByte(10)
      ..write(obj.paymentMethod)
      ..writeByte(11)
      ..write(obj.isYearly)
      ..writeByte(12)
      ..write(obj.expiresAt)
      ..writeByte(13)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentStatusEnumAdapter extends TypeAdapter<PaymentStatusEnum> {
  @override
  final int typeId = 10;

  @override
  PaymentStatusEnum read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PaymentStatusEnum.pending;
      case 1:
        return PaymentStatusEnum.processing;
      case 2:
        return PaymentStatusEnum.success;
      case 3:
        return PaymentStatusEnum.failed;
      case 4:
        return PaymentStatusEnum.refunded;
      case 5:
        return PaymentStatusEnum.cancelled;
      default:
        return PaymentStatusEnum.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PaymentStatusEnum obj) {
    switch (obj) {
      case PaymentStatusEnum.pending:
        writer.writeByte(0);
        break;
      case PaymentStatusEnum.processing:
        writer.writeByte(1);
        break;
      case PaymentStatusEnum.success:
        writer.writeByte(2);
        break;
      case PaymentStatusEnum.failed:
        writer.writeByte(3);
        break;
      case PaymentStatusEnum.refunded:
        writer.writeByte(4);
        break;
      case PaymentStatusEnum.cancelled:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentStatusEnumAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
