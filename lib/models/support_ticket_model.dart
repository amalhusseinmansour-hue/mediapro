import 'package:hive/hive.dart';

part 'support_ticket_model.g.dart';

@HiveType(typeId: 7)
enum TicketStatus {
  @HiveField(0)
  open,
  @HiveField(1)
  inProgress,
  @HiveField(2)
  resolved,
  @HiveField(3)
  closed,
}

@HiveType(typeId: 8)
enum TicketPriority {
  @HiveField(0)
  low,
  @HiveField(1)
  medium,
  @HiveField(2)
  high,
  @HiveField(3)
  urgent,
}

@HiveType(typeId: 9)
enum TicketCategory {
  @HiveField(0)
  technical,
  @HiveField(1)
  billing,
  @HiveField(2)
  feature,
  @HiveField(3)
  bug,
  @HiveField(4)
  account,
  @HiveField(5)
  other,
}

@HiveType(typeId: 60)
class SupportTicketModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final String subject;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final TicketCategory category;

  @HiveField(5)
  final TicketPriority priority;

  @HiveField(6)
  final TicketStatus status;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? updatedAt;

  @HiveField(9)
  final DateTime? resolvedAt;

  @HiveField(10)
  final String? response;

  @HiveField(11)
  final String? adminNote;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.subject,
    required this.description,
    required this.category,
    this.priority = TicketPriority.medium,
    this.status = TicketStatus.open,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.response,
    this.adminNote,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json) {
    return SupportTicketModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      category: TicketCategory.values[json['category'] ?? 0],
      priority: TicketPriority.values[json['priority'] ?? 1],
      status: TicketStatus.values[json['status'] ?? 0],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'])
          : null,
      response: json['response'],
      adminNote: json['adminNote'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'subject': subject,
      'description': description,
      'category': category.index,
      'priority': priority.index,
      'status': status.index,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'response': response,
      'adminNote': adminNote,
    };
  }

  String get statusText {
    switch (status) {
      case TicketStatus.open:
        return 'مفتوحة';
      case TicketStatus.inProgress:
        return 'قيد المعالجة';
      case TicketStatus.resolved:
        return 'تم الحل';
      case TicketStatus.closed:
        return 'مغلقة';
    }
  }

  String get priorityText {
    switch (priority) {
      case TicketPriority.low:
        return 'منخفضة';
      case TicketPriority.medium:
        return 'متوسطة';
      case TicketPriority.high:
        return 'عالية';
      case TicketPriority.urgent:
        return 'عاجلة';
    }
  }

  String get categoryText {
    switch (category) {
      case TicketCategory.technical:
        return 'مشكلة تقنية';
      case TicketCategory.billing:
        return 'الفواتير';
      case TicketCategory.feature:
        return 'طلب ميزة';
      case TicketCategory.bug:
        return 'بلاغ خطأ';
      case TicketCategory.account:
        return 'الحساب';
      case TicketCategory.other:
        return 'أخرى';
    }
  }
}
