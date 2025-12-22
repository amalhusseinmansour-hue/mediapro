import 'package:hive/hive.dart';

part 'sms_model.g.dart';

@HiveType(typeId: 20)
enum SmsStatus {
  @HiveField(0)
  pending,
  @HiveField(1)
  sent,
  @HiveField(2)
  delivered,
  @HiveField(3)
  failed,
}

@HiveType(typeId: 21)
enum SmsPurpose {
  @HiveField(0)
  verification,
  @HiveField(1)
  notification,
  @HiveField(2)
  marketing,
  @HiveField(3)
  other,
}

@HiveType(typeId: 22)
class SmsMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String recipient;

  @HiveField(2)
  String message;

  @HiveField(3)
  SmsStatus status;

  @HiveField(4)
  SmsPurpose purpose;

  @HiveField(5)
  int parts;

  @HiveField(6)
  double cost;

  @HiveField(7)
  DateTime sentAt;

  @HiveField(8)
  DateTime? deliveredAt;

  @HiveField(9)
  String? errorMessage;

  SmsMessage({
    required this.id,
    required this.recipient,
    required this.message,
    required this.status,
    required this.purpose,
    this.parts = 1,
    this.cost = 0.0,
    required this.sentAt,
    this.deliveredAt,
    this.errorMessage,
  });

  String get statusText {
    switch (status) {
      case SmsStatus.pending:
        return 'قيد الإرسال';
      case SmsStatus.sent:
        return 'تم الإرسال';
      case SmsStatus.delivered:
        return 'تم التوصيل';
      case SmsStatus.failed:
        return 'فشل';
    }
  }

  String get purposeText {
    switch (purpose) {
      case SmsPurpose.verification:
        return 'رمز التحقق';
      case SmsPurpose.notification:
        return 'إشعار';
      case SmsPurpose.marketing:
        return 'تسويقي';
      case SmsPurpose.other:
        return 'أخرى';
    }
  }
}

@HiveType(typeId: 23)
class SmsSettings extends HiveObject {
  @HiveField(0)
  String? apiKey;

  @HiveField(1)
  String? senderId;

  @HiveField(2)
  bool isEnabled;

  @HiveField(3)
  double costPerMessage;

  @HiveField(4)
  String? apiUrl;

  SmsSettings({
    this.apiKey,
    this.senderId,
    this.isEnabled = false,
    this.costPerMessage = 0.0,
    this.apiUrl,
  });
}
