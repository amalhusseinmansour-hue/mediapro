import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج حدث المجتمع
class CommunityEventModel {
  final String id;
  final String title;
  final String description;
  final String coverImage;
  final String organizerId;
  final String? groupId;
  final DateTime startTime;
  final DateTime endTime;
  final String location; // physical address or "online"
  final String? onlineLink; // Zoom, Google Meet, etc.
  final String category;
  final bool isOnline;
  final bool isPaid;
  final double price;
  final int maxAttendees;
  final List<String> attendeeIds;
  final int attendeesCount;
  final List<String> tags;
  final Map<String, dynamic>? agenda;
  final String status; // upcoming, ongoing, completed, cancelled
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isFeatured;
  final String? recordingUrl;
  final List<EventSpeakerModel> speakers;
  final Map<String, dynamic>? eventSettings;

  CommunityEventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.coverImage,
    required this.organizerId,
    this.groupId,
    required this.startTime,
    required this.endTime,
    required this.location,
    this.onlineLink,
    required this.category,
    this.isOnline = false,
    this.isPaid = false,
    this.price = 0.0,
    this.maxAttendees = 0,
    this.attendeeIds = const [],
    this.attendeesCount = 0,
    this.tags = const [],
    this.agenda,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.isFeatured = false,
    this.recordingUrl,
    this.speakers = const [],
    this.eventSettings,
  });

  factory CommunityEventModel.fromJson(Map<String, dynamic> json) {
    return CommunityEventModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['cover_image'] ?? '',
      organizerId: json['organizer_id'] ?? '',
      groupId: json['group_id'],
      startTime: json['start_time'] is Timestamp
          ? (json['start_time'] as Timestamp).toDate()
          : DateTime.parse(json['start_time'] ?? DateTime.now().toIso8601String()),
      endTime: json['end_time'] is Timestamp
          ? (json['end_time'] as Timestamp).toDate()
          : DateTime.parse(json['end_time'] ?? DateTime.now().toIso8601String()),
      location: json['location'] ?? '',
      onlineLink: json['online_link'],
      category: json['category'] ?? '',
      isOnline: json['is_online'] ?? false,
      isPaid: json['is_paid'] ?? false,
      price: (json['price'] ?? 0).toDouble(),
      maxAttendees: json['max_attendees'] ?? 0,
      attendeeIds: (json['attendee_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      attendeesCount: json['attendees_count'] ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      agenda: json['agenda'] as Map<String, dynamic>?,
      status: json['status'] ?? 'upcoming',
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] is Timestamp
              ? (json['updated_at'] as Timestamp).toDate()
              : DateTime.parse(json['updated_at']))
          : null,
      isFeatured: json['is_featured'] ?? false,
      recordingUrl: json['recording_url'],
      speakers: (json['speakers'] as List<dynamic>?)
              ?.map((e) => EventSpeakerModel.fromJson(e))
              .toList() ??
          [],
      eventSettings: json['event_settings'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cover_image': coverImage,
      'organizer_id': organizerId,
      'group_id': groupId,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'location': location,
      'online_link': onlineLink,
      'category': category,
      'is_online': isOnline,
      'is_paid': isPaid,
      'price': price,
      'max_attendees': maxAttendees,
      'attendee_ids': attendeeIds,
      'attendees_count': attendeesCount,
      'tags': tags,
      'agenda': agenda,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_featured': isFeatured,
      'recording_url': recordingUrl,
      'speakers': speakers.map((s) => s.toJson()).toList(),
      'event_settings': eventSettings,
    };
  }
}

/// نموذج متحدث في الحدث
class EventSpeakerModel {
  final String id;
  final String name;
  final String bio;
  final String avatarUrl;
  final String? title;
  final String? company;
  final List<String> socialLinks;

  EventSpeakerModel({
    required this.id,
    required this.name,
    required this.bio,
    required this.avatarUrl,
    this.title,
    this.company,
    this.socialLinks = const [],
  });

  factory EventSpeakerModel.fromJson(Map<String, dynamic> json) {
    return EventSpeakerModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      bio: json['bio'] ?? '',
      avatarUrl: json['avatar_url'] ?? '',
      title: json['title'],
      company: json['company'],
      socialLinks: (json['social_links'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bio': bio,
      'avatar_url': avatarUrl,
      'title': title,
      'company': company,
      'social_links': socialLinks,
    };
  }
}

/// نموذج حضور الحدث
class EventAttendanceModel {
  final String id;
  final String userId;
  final String eventId;
  final DateTime registeredAt;
  final bool isPaid;
  final String? paymentId;
  final String status; // registered, attended, cancelled, no-show
  final int? rating;
  final String? feedback;

  EventAttendanceModel({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.registeredAt,
    this.isPaid = false,
    this.paymentId,
    required this.status,
    this.rating,
    this.feedback,
  });

  factory EventAttendanceModel.fromJson(Map<String, dynamic> json) {
    return EventAttendanceModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      eventId: json['event_id'] ?? '',
      registeredAt: json['registered_at'] is Timestamp
          ? (json['registered_at'] as Timestamp).toDate()
          : DateTime.parse(json['registered_at'] ?? DateTime.now().toIso8601String()),
      isPaid: json['is_paid'] ?? false,
      paymentId: json['payment_id'],
      status: json['status'] ?? 'registered',
      rating: json['rating'],
      feedback: json['feedback'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'event_id': eventId,
      'registered_at': registeredAt.toIso8601String(),
      'is_paid': isPaid,
      'payment_id': paymentId,
      'status': status,
      'rating': rating,
      'feedback': feedback,
    };
  }
}
