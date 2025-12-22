import 'package:flutter/material.dart';

enum ActivityType {
  postPublished,
  postScheduled,
  accountConnected,
  postFailed,
  commentReceived,
  likeReceived,
  shareReceived,
}

class ActivityModel {
  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final IconData icon;
  final Color color;
  final Map<String, dynamic>? metadata;

  ActivityModel({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.icon,
    required this.color,
    this.metadata,
  });

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    } else if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return 'منذ ${(difference.inDays / 7).floor()} أسبوع';
    }
  }

  factory ActivityModel.fromMap(Map<String, dynamic> map) {
    return ActivityModel(
      id: map['id'] ?? '',
      type: ActivityType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ActivityType.postPublished,
      ),
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      icon: _iconFromString(map['icon']),
      color: Color(map['color'] ?? 0xFF00D9FF),
      metadata: map['metadata'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'subtitle': subtitle,
      'timestamp': timestamp.toIso8601String(),
      'icon': _iconToString(icon),
      'color': color.value,
      'metadata': metadata,
    };
  }

  static IconData _iconFromString(String? iconString) {
    switch (iconString) {
      case 'send_rounded':
        return Icons.send_rounded;
      case 'access_time_rounded':
        return Icons.access_time_rounded;
      case 'link_rounded':
        return Icons.link_rounded;
      case 'error_outline':
        return Icons.error_outline;
      case 'comment_rounded':
        return Icons.comment_rounded;
      case 'favorite_rounded':
        return Icons.favorite_rounded;
      case 'share_rounded':
        return Icons.share_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  static String _iconToString(IconData icon) {
    if (icon == Icons.send_rounded) return 'send_rounded';
    if (icon == Icons.access_time_rounded) return 'access_time_rounded';
    if (icon == Icons.link_rounded) return 'link_rounded';
    if (icon == Icons.error_outline) return 'error_outline';
    if (icon == Icons.comment_rounded) return 'comment_rounded';
    if (icon == Icons.favorite_rounded) return 'favorite_rounded';
    if (icon == Icons.share_rounded) return 'share_rounded';
    return 'notifications_rounded';
  }
}
