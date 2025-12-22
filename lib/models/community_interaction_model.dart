import 'package:cloud_firestore/cloud_firestore.dart';

/// نموذج التعليق
class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorAvatar;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? parentCommentId; // للردود على التعليقات
  final List<String> likeIds;
  final int likesCount;
  final List<String> replyIds;
  final int repliesCount;
  final bool isEdited;
  final bool isPinned;
  final List<String> mentions;
  final List<String> mediaUrls;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.updatedAt,
    this.parentCommentId,
    this.likeIds = const [],
    this.likesCount = 0,
    this.replyIds = const [],
    this.repliesCount = 0,
    this.isEdited = false,
    this.isPinned = false,
    this.mentions = const [],
    this.mediaUrls = const [],
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id']?.toString() ?? '',
      postId: json['post_id'] ?? '',
      authorId: json['author_id'] ?? '',
      authorName: json['author_name'] ?? '',
      authorAvatar: json['author_avatar'] ?? '',
      content: json['content'] ?? '',
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: json['updated_at'] != null
          ? (json['updated_at'] is Timestamp
              ? (json['updated_at'] as Timestamp).toDate()
              : DateTime.parse(json['updated_at']))
          : null,
      parentCommentId: json['parent_comment_id'],
      likeIds: (json['like_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      likesCount: json['likes_count'] ?? 0,
      replyIds: (json['reply_ids'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      repliesCount: json['replies_count'] ?? 0,
      isEdited: json['is_edited'] ?? false,
      isPinned: json['is_pinned'] ?? false,
      mentions: (json['mentions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      mediaUrls: (json['media_urls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'author_id': authorId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'parent_comment_id': parentCommentId,
      'like_ids': likeIds,
      'likes_count': likesCount,
      'reply_ids': replyIds,
      'replies_count': repliesCount,
      'is_edited': isEdited,
      'is_pinned': isPinned,
      'mentions': mentions,
      'media_urls': mediaUrls,
    };
  }
}

/// نموذج التفاعل (Reactions)
class ReactionModel {
  final String id;
  final String targetId; // post_id, comment_id, etc.
  final String targetType; // post, comment, event, etc.
  final String userId;
  final String reactionType; // like, love, haha, wow, sad, angry
  final DateTime createdAt;

  ReactionModel({
    required this.id,
    required this.targetId,
    required this.targetType,
    required this.userId,
    required this.reactionType,
    required this.createdAt,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id']?.toString() ?? '',
      targetId: json['target_id'] ?? '',
      targetType: json['target_type'] ?? '',
      userId: json['user_id'] ?? '',
      reactionType: json['reaction_type'] ?? 'like',
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_id': targetId,
      'target_type': targetType,
      'user_id': userId,
      'reaction_type': reactionType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// نموذج المشاركة
class ShareModel {
  final String id;
  final String postId;
  final String userId;
  final String platform; // twitter, facebook, whatsapp, telegram, copy_link
  final DateTime sharedAt;
  final String? caption;

  ShareModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.platform,
    required this.sharedAt,
    this.caption,
  });

  factory ShareModel.fromJson(Map<String, dynamic> json) {
    return ShareModel(
      id: json['id']?.toString() ?? '',
      postId: json['post_id'] ?? '',
      userId: json['user_id'] ?? '',
      platform: json['platform'] ?? '',
      sharedAt: json['shared_at'] is Timestamp
          ? (json['shared_at'] as Timestamp).toDate()
          : DateTime.parse(json['shared_at'] ?? DateTime.now().toIso8601String()),
      caption: json['caption'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'platform': platform,
      'shared_at': sharedAt.toIso8601String(),
      'caption': caption,
    };
  }
}

/// نموذج الحفظ (Bookmarks)
class BookmarkModel {
  final String id;
  final String userId;
  final String postId;
  final DateTime savedAt;
  final String? collectionId; // للتنظيم في مجموعات
  final String? notes;

  BookmarkModel({
    required this.id,
    required this.userId,
    required this.postId,
    required this.savedAt,
    this.collectionId,
    this.notes,
  });

  factory BookmarkModel.fromJson(Map<String, dynamic> json) {
    return BookmarkModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      postId: json['post_id'] ?? '',
      savedAt: json['saved_at'] is Timestamp
          ? (json['saved_at'] as Timestamp).toDate()
          : DateTime.parse(json['saved_at'] ?? DateTime.now().toIso8601String()),
      collectionId: json['collection_id'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'post_id': postId,
      'saved_at': savedAt.toIso8601String(),
      'collection_id': collectionId,
      'notes': notes,
    };
  }
}

/// نموذج الإشعار
class CommunityNotificationModel {
  final String id;
  final String userId;
  final String type; // like, comment, mention, follow, event, etc.
  final String title;
  final String body;
  final String? actionUrl;
  final String? imageUrl;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final String? actorId; // من قام بالفعل
  final String? actorName;
  final String? actorAvatar;

  CommunityNotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.actionUrl,
    this.imageUrl,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.actorId,
    this.actorName,
    this.actorAvatar,
  });

  factory CommunityNotificationModel.fromJson(Map<String, dynamic> json) {
    return CommunityNotificationModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      actionUrl: json['action_url'],
      imageUrl: json['image_url'],
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] is Timestamp
          ? (json['created_at'] as Timestamp).toDate()
          : DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      actorId: json['actor_id'],
      actorName: json['actor_name'],
      actorAvatar: json['actor_avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'action_url': actionUrl,
      'image_url': imageUrl,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'actor_id': actorId,
      'actor_name': actorName,
      'actor_avatar': actorAvatar,
    };
  }
}
