import 'dart:math';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_group_model.dart';
import '../models/community_event_model.dart';
import '../models/community_interaction_model.dart';
import 'n8n_service.dart';

/// خدمة المجتمع المتقدمة مع استراتيجيات ذكية لزيادة الأرباح 500%
class CommunityAdvancedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final N8nService _n8nService = N8nService();

  // =====================================================
  // 1️⃣ GROUPS MANAGEMENT - إدارة المجموعات
  // =====================================================

  /// إنشاء مجموعة جديدة مع AI Optimization
  Future<CommunityGroupModel> createGroup({
    required String name,
    required String description,
    required String coverImage,
    required String category,
    bool isPrivate = false,
    bool isPremium = false,
    double premiumPrice = 0.0,
    List<String> tags = const [],
    String? rules,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // 🤖 تحليل AI للمحتوى وتحسين SEO
      final aiOptimization = await _optimizeGroupContent(
        name: name,
        description: description,
        category: category,
      );

      final group = CommunityGroupModel(
        id: _firestore.collection('community_groups').doc().id,
        name: name,
        description: aiOptimization['optimized_description'] ?? description,
        coverImage: coverImage,
        category: category,
        creatorId: user.uid,
        adminIds: [user.uid],
        memberIds: [user.uid],
        membersCount: 1,
        isPrivate: isPrivate,
        isPremium: isPremium,
        premiumPrice: premiumPrice,
        createdAt: DateTime.now(),
        tags: aiOptimization['suggested_tags'] ?? tags,
        rules: rules,
        isVerified: false,
        postsCount: 0,
        engagementScore: 0,
      );

      await _firestore
          .collection('community_groups')
          .doc(group.id)
          .set(group.toJson());

      // 🎯 إطلاق automation workflows
      await _launchGroupAutomation(group);

      // 📊 تتبع الإيرادات المحتملة
      await _trackPotentialRevenue(
        type: 'group_creation',
        groupId: group.id,
        isPremium: isPremium,
        price: premiumPrice,
      );

      return group;
    } catch (e) {
      print('Error creating group: $e');
      rethrow;
    }
  }

  /// الانضمام لمجموعة مع معالجة الدفع للمجموعات المدفوعة
  Future<bool> joinGroup({required String groupId, String? paymentId}) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final groupDoc = await _firestore
          .collection('community_groups')
          .doc(groupId)
          .get();
      if (!groupDoc.exists) throw Exception('Group not found');

      final group = CommunityGroupModel.fromJson(groupDoc.data()!);

      // التحقق من الدفع للمجموعات المدفوعة
      if (group.isPremium && paymentId == null) {
        throw Exception('Payment required for premium group');
      }

      // إنشاء عضوية
      final membership = GroupMembershipModel(
        id: _firestore.collection('group_memberships').doc().id,
        userId: user.uid,
        groupId: groupId,
        role: 'member',
        joinedAt: DateTime.now(),
        isActive: true,
        contributionScore: 0,
      );

      await _firestore
          .collection('group_memberships')
          .doc(membership.id)
          .set(membership.toJson());

      // تحديث عدد الأعضاء
      await _firestore.collection('community_groups').doc(groupId).update({
        'member_ids': FieldValue.arrayUnion([user.uid]),
        'members_count': FieldValue.increment(1),
      });

      // 💰 تسجيل الإيرادات إذا كانت مدفوعة
      if (group.isPremium && paymentId != null) {
        await _recordRevenue(
          type: 'premium_group_join',
          amount: group.premiumPrice,
          groupId: groupId,
          userId: user.uid,
          paymentId: paymentId,
        );
      }

      // 🤖 تفعيل automation للعضو الجديد
      await _triggerMemberWelcomeAutomation(group, user.uid);

      return true;
    } catch (e) {
      print('Error joining group: $e');
      return false;
    }
  }

  /// الحصول على المجموعات الموصى بها بناءً على AI
  Future<List<CommunityGroupModel>> getRecommendedGroups({
    int limit = 20,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // جلب اهتمامات المستخدم
      final userInterests = await _getUserInterests(user.uid);

      // 🤖 استخدام AI للتوصيات الذكية
      final recommendedGroupIds = await _getAIRecommendations(
        userId: user.uid,
        interests: userInterests,
        type: 'groups',
      );

      if (recommendedGroupIds.isEmpty) {
        // الاحتياطي: المجموعات الشائعة
        final query = await _firestore
            .collection('community_groups')
            .orderBy('engagement_score', descending: true)
            .limit(limit)
            .get();

        return query.docs
            .map((doc) => CommunityGroupModel.fromJson(doc.data()))
            .toList();
      }

      // جلب المجموعات الموصى بها
      final groups = <CommunityGroupModel>[];
      for (final groupId in recommendedGroupIds.take(limit)) {
        final doc = await _firestore
            .collection('community_groups')
            .doc(groupId)
            .get();
        if (doc.exists) {
          groups.add(CommunityGroupModel.fromJson(doc.data()!));
        }
      }

      return groups;
    } catch (e) {
      print('Error getting recommended groups: $e');
      return [];
    }
  }

  // =====================================================
  // 2️⃣ POSTS MANAGEMENT - إدارة المنشورات
  // =====================================================

  /// إنشاء منشور جديد في المجتمع
  Future<Map<String, dynamic>> createCommunityPost({
    required String content,
    required String authorId,
    String? groupId,
    List<String> tags = const [],
    String? title,
    String postType = 'text',
    List<File>? images,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // التحقق من المحتوى
      if (content.trim().isEmpty) {
        throw Exception('لا يمكن نشر منشور فارغ');
      }

      final postId = _firestore.collection('community_posts').doc().id;

      // تحسين المحتوى بالـ AI
      final aiOptimization = await _optimizeGroupContent(
        name: title ?? 'منشور جديد',
        description: content,
        category: 'post',
      );

      // إنشاء بيانات المنشور
      final post = {
        'id': postId,
        'authorId': authorId,
        'authorName': user.displayName ?? 'مستخدم',
        'authorAvatar': user.photoURL,
        'groupId': groupId,
        'title': title,
        'content': content,
        'type': postType,
        'tags': aiOptimization['suggested_tags'] ?? tags,
        'imagesCount': images?.length ?? 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'likedBy': [],
        'commentsCount': 0,
        'sharesCount': 0,
        'viewsCount': 1,
        'isPublished': true,
        'isPinned': false,
        'status': 'active',
      };

      // حفظ المنشور
      await _firestore.collection('community_posts').doc(postId).set(post);

      // حفظ الصور إذا كانت موجودة
      if (images != null && images.isNotEmpty) {
        for (int i = 0; i < images.length; i++) {
          // TODO: رفع الصور إلى Firebase Storage
          // يمكن تطبيق هذا لاحقاً
        }
      }

      // تحديث إحصائيات المجموعة
      if (groupId != null) {
        await _firestore.collection('community_groups').doc(groupId).update({
          'postsCount': FieldValue.increment(1),
          'lastActivityAt': FieldValue.serverTimestamp(),
        });
      }

      // تسجيل الإيرادات المحتملة
      await _trackPotentialRevenue(
        type: 'community_post',
        groupId: groupId,
        isPremium: false,
        price: 0.0,
      );

      print('✅ تم إنشاء المنشور بنجاح: $postId');

      return {
        'id': postId,
        'status': 'success',
        'message': 'تم نشر المنشور بنجاح',
      };
    } catch (e) {
      print('❌ خطأ في إنشاء المنشور: $e');
      rethrow;
    }
  }

  // =====================================================
  // 3️⃣ EVENTS MANAGEMENT - إدارة الأحداث
  // =====================================================

  /// إنشاء حدث مع تحسين AI
  Future<CommunityEventModel> createEvent({
    required String title,
    required String description,
    required String coverImage,
    String? groupId,
    required DateTime startTime,
    required DateTime endTime,
    required String location,
    String? onlineLink,
    required String category,
    bool isOnline = false,
    bool isPaid = false,
    double price = 0.0,
    int maxAttendees = 0,
    List<String> tags = const [],
    Map<String, dynamic>? agenda,
    List<EventSpeakerModel> speakers = const [],
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // 🤖 تحسين بيانات الحدث بالـ AI
      final aiOptimization = await _optimizeEventContent(
        title: title,
        description: description,
        category: category,
      );

      final event = CommunityEventModel(
        id: _firestore.collection('community_events').doc().id,
        title: title,
        description: aiOptimization['optimized_description'] ?? description,
        coverImage: coverImage,
        organizerId: user.uid,
        groupId: groupId,
        startTime: startTime,
        endTime: endTime,
        location: location,
        onlineLink: onlineLink,
        category: category,
        isOnline: isOnline,
        isPaid: isPaid,
        price: price,
        maxAttendees: maxAttendees,
        attendeeIds: [],
        attendeesCount: 0,
        tags: aiOptimization['suggested_tags'] ?? tags,
        agenda: agenda,
        status: 'upcoming',
        createdAt: DateTime.now(),
        isFeatured: false,
        speakers: speakers,
      );

      await _firestore
          .collection('community_events')
          .doc(event.id)
          .set(event.toJson());

      // 🎯 إطلاق automation للحدث
      await _launchEventAutomation(event);

      // 💰 تتبع الإيرادات المحتملة
      if (isPaid) {
        await _trackPotentialRevenue(
          type: 'event_creation',
          eventId: event.id,
          isPremium: true,
          price: price,
        );
      }

      return event;
    } catch (e) {
      print('Error creating event: $e');
      rethrow;
    }
  }

  /// التسجيل في حدث
  Future<bool> registerForEvent({
    required String eventId,
    String? paymentId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final eventDoc = await _firestore
          .collection('community_events')
          .doc(eventId)
          .get();
      if (!eventDoc.exists) throw Exception('Event not found');

      final event = CommunityEventModel.fromJson(eventDoc.data()!);

      // التحقق من السعة
      if (event.maxAttendees > 0 &&
          event.attendeesCount >= event.maxAttendees) {
        throw Exception('Event is full');
      }

      // التحقق من الدفع للأحداث المدفوعة
      if (event.isPaid && paymentId == null) {
        throw Exception('Payment required for paid event');
      }

      // إنشاء سجل الحضور
      final attendance = EventAttendanceModel(
        id: _firestore.collection('event_attendance').doc().id,
        userId: user.uid,
        eventId: eventId,
        registeredAt: DateTime.now(),
        isPaid: event.isPaid,
        paymentId: paymentId,
        status: 'registered',
      );

      await _firestore
          .collection('event_attendance')
          .doc(attendance.id)
          .set(attendance.toJson());

      // تحديث عدد الحضور
      await _firestore.collection('community_events').doc(eventId).update({
        'attendee_ids': FieldValue.arrayUnion([user.uid]),
        'attendees_count': FieldValue.increment(1),
      });

      // 💰 تسجيل الإيرادات إذا كانت مدفوعة
      if (event.isPaid && paymentId != null) {
        await _recordRevenue(
          type: 'event_registration',
          amount: event.price,
          eventId: eventId,
          userId: user.uid,
          paymentId: paymentId,
        );
      }

      // 🤖 تفعيل automation للمسجل
      await _triggerEventRegistrationAutomation(event, user.uid);

      return true;
    } catch (e) {
      print('Error registering for event: $e');
      return false;
    }
  }

  /// الحصول على الأحداث الموصى بها
  Future<List<CommunityEventModel>> getRecommendedEvents({
    int limit = 20,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      // جلب اهتمامات المستخدم
      final userInterests = await _getUserInterests(user.uid);

      // 🤖 استخدام AI للتوصيات
      final recommendedEventIds = await _getAIRecommendations(
        userId: user.uid,
        interests: userInterests,
        type: 'events',
      );

      if (recommendedEventIds.isEmpty) {
        // الاحتياطي: الأحداث القادمة
        final query = await _firestore
            .collection('community_events')
            .where('status', isEqualTo: 'upcoming')
            .where(
              'start_time',
              isGreaterThan: DateTime.now().toIso8601String(),
            )
            .orderBy('start_time')
            .limit(limit)
            .get();

        return query.docs
            .map((doc) => CommunityEventModel.fromJson(doc.data()))
            .toList();
      }

      // جلب الأحداث الموصى بها
      final events = <CommunityEventModel>[];
      for (final eventId in recommendedEventIds.take(limit)) {
        final doc = await _firestore
            .collection('community_events')
            .doc(eventId)
            .get();
        if (doc.exists) {
          events.add(CommunityEventModel.fromJson(doc.data()!));
        }
      }

      return events;
    } catch (e) {
      print('Error getting recommended events: $e');
      return [];
    }
  }

  // =====================================================
  // 3️⃣ INTERACTIONS - التفاعلات
  // =====================================================

  /// إضافة تعليق مع AI Content Moderation
  Future<CommentModel> addComment({
    required String postId,
    required String content,
    String? parentCommentId,
    List<String> mentions = const [],
    List<String> mediaUrls = const [],
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // 🤖 فحص المحتوى بالـ AI (مكافحة السبام والمحتوى المسيء)
      final isContentSafe = await _moderateContent(content);
      if (!isContentSafe) {
        throw Exception('Content violates community guidelines');
      }

      // جلب بيانات المستخدم
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      final comment = CommentModel(
        id: _firestore.collection('comments').doc().id,
        postId: postId,
        authorId: user.uid,
        authorName: userData['full_name'] ?? 'User',
        authorAvatar: userData['avatar_url'] ?? '',
        content: content,
        createdAt: DateTime.now(),
        parentCommentId: parentCommentId,
        mentions: mentions,
        mediaUrls: mediaUrls,
      );

      await _firestore
          .collection('comments')
          .doc(comment.id)
          .set(comment.toJson());

      // تحديث عدد التعليقات في المنشور
      await _firestore.collection('community_posts').doc(postId).update({
        'comments_count': FieldValue.increment(1),
      });

      // 🔔 إرسال إشعارات للمشاركين
      await _sendCommentNotifications(comment);

      // 📊 تحديث engagement score
      await _updateEngagementScore(postId, 'comment');

      return comment;
    } catch (e) {
      print('Error adding comment: $e');
      rethrow;
    }
  }

  /// إضافة تفاعل (Reaction)
  Future<bool> addReaction({
    required String targetId,
    required String targetType,
    required String reactionType,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final reaction = ReactionModel(
        id: _firestore.collection('reactions').doc().id,
        targetId: targetId,
        targetType: targetType,
        userId: user.uid,
        reactionType: reactionType,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('reactions')
          .doc(reaction.id)
          .set(reaction.toJson());

      // تحديث العداد
      final collection = targetType == 'post' ? 'community_posts' : 'comments';
      await _firestore.collection(collection).doc(targetId).update({
        'like_ids': FieldValue.arrayUnion([user.uid]),
        'likes_count': FieldValue.increment(1),
      });

      // 📊 تحديث engagement score
      await _updateEngagementScore(targetId, 'reaction');

      return true;
    } catch (e) {
      print('Error adding reaction: $e');
      return false;
    }
  }

  /// حفظ منشور (Bookmark)
  Future<bool> bookmarkPost({
    required String postId,
    String? collectionId,
    String? notes,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final bookmark = BookmarkModel(
        id: _firestore.collection('bookmarks').doc().id,
        userId: user.uid,
        postId: postId,
        savedAt: DateTime.now(),
        collectionId: collectionId,
        notes: notes,
      );

      await _firestore
          .collection('bookmarks')
          .doc(bookmark.id)
          .set(bookmark.toJson());

      // 📊 تتبع البيانات
      await _trackUserBehavior(
        userId: user.uid,
        action: 'bookmark',
        targetId: postId,
      );

      return true;
    } catch (e) {
      print('Error bookmarking post: $e');
      return false;
    }
  }

  // =====================================================
  // 4️⃣ AI & AUTOMATION HELPERS
  // =====================================================

  /// تحسين محتوى المجموعة بالـ AI
  Future<Map<String, dynamic>> _optimizeGroupContent({
    required String name,
    required String description,
    required String category,
  }) async {
    try {
      // استدعاء N8N workflow للتحسين
      final response = await _n8nService.triggerWorkflow(
        'optimize_community_content',
        {
          'type': 'group',
          'name': name,
          'description': description,
          'category': category,
        },
      );

      return response ??
          {'optimized_description': description, 'suggested_tags': <String>[]};
    } catch (e) {
      print('Error optimizing group content: $e');
      return {
        'optimized_description': description,
        'suggested_tags': <String>[],
      };
    }
  }

  /// تحسين محتوى الحدث بالـ AI
  Future<Map<String, dynamic>> _optimizeEventContent({
    required String title,
    required String description,
    required String category,
  }) async {
    try {
      final response = await _n8nService.triggerWorkflow(
        'optimize_community_content',
        {
          'type': 'event',
          'title': title,
          'description': description,
          'category': category,
        },
      );

      return response ??
          {'optimized_description': description, 'suggested_tags': <String>[]};
    } catch (e) {
      print('Error optimizing event content: $e');
      return {
        'optimized_description': description,
        'suggested_tags': <String>[],
      };
    }
  }

  /// فحص المحتوى بالـ AI (Content Moderation)
  Future<bool> _moderateContent(String content) async {
    try {
      final response = await _n8nService.triggerWorkflow('moderate_content', {
        'content': content,
      });

      return (response?['is_safe'] as bool?) ?? true;
    } catch (e) {
      print('Error moderating content: $e');
      return true; // افتراضياً نسمح بالمحتوى
    }
  }

  /// الحصول على توصيات AI
  Future<List<String>> _getAIRecommendations({
    required String userId,
    required List<String> interests,
    required String type,
  }) async {
    try {
      final response = await _n8nService.triggerWorkflow(
        'get_ai_recommendations',
        {'user_id': userId, 'interests': interests, 'type': type},
      );

      return (response?['recommendations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];
    } catch (e) {
      print('Error getting AI recommendations: $e');
      return [];
    }
  }

  /// جلب اهتمامات المستخدم
  Future<List<String>> _getUserInterests(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userData = userDoc.data();

      if (userData != null && userData['interests'] != null) {
        return (userData['interests'] as List<dynamic>)
            .map((e) => e.toString())
            .toList();
      }

      // إذا لم تكن محددة، نحاول استنتاجها من النشاط
      final activityDoc = await _firestore
          .collection('user_activity')
          .doc(userId)
          .get();

      if (activityDoc.exists) {
        final activityData = activityDoc.data()!;
        return (activityData['inferred_interests'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
      }

      return [];
    } catch (e) {
      print('Error getting user interests: $e');
      return [];
    }
  }

  // =====================================================
  // 5️⃣ AUTOMATION WORKFLOWS
  // =====================================================

  /// إطلاق automation للمجموعة الجديدة
  Future<void> _launchGroupAutomation(CommunityGroupModel group) async {
    try {
      await _n8nService.triggerWorkflow('group_created', {
        'group_id': group.id,
        'group_name': group.name,
        'creator_id': group.creatorId,
        'is_premium': group.isPremium,
        'category': group.category,
      });
    } catch (e) {
      print('Error launching group automation: $e');
    }
  }

  /// إطلاق automation للحدث الجديد
  Future<void> _launchEventAutomation(CommunityEventModel event) async {
    try {
      await _n8nService.triggerWorkflow('event_created', {
        'event_id': event.id,
        'event_title': event.title,
        'organizer_id': event.organizerId,
        'start_time': event.startTime.toIso8601String(),
        'is_paid': event.isPaid,
        'category': event.category,
      });
    } catch (e) {
      print('Error launching event automation: $e');
    }
  }

  /// تفعيل automation للعضو الجديد
  Future<void> _triggerMemberWelcomeAutomation(
    CommunityGroupModel group,
    String userId,
  ) async {
    try {
      await _n8nService.triggerWorkflow('member_joined_group', {
        'group_id': group.id,
        'group_name': group.name,
        'user_id': userId,
        'is_premium': group.isPremium,
      });
    } catch (e) {
      print('Error triggering welcome automation: $e');
    }
  }

  /// تفعيل automation للتسجيل في الحدث
  Future<void> _triggerEventRegistrationAutomation(
    CommunityEventModel event,
    String userId,
  ) async {
    try {
      await _n8nService.triggerWorkflow('user_registered_event', {
        'event_id': event.id,
        'event_title': event.title,
        'user_id': userId,
        'start_time': event.startTime.toIso8601String(),
      });
    } catch (e) {
      print('Error triggering event registration automation: $e');
    }
  }

  // =====================================================
  // 6️⃣ REVENUE & ANALYTICS
  // =====================================================

  /// تتبع الإيرادات المحتملة
  Future<void> _trackPotentialRevenue({
    required String type,
    String? groupId,
    String? eventId,
    required bool isPremium,
    required double price,
  }) async {
    try {
      await _firestore.collection('revenue_tracking').add({
        'type': type,
        'group_id': groupId,
        'event_id': eventId,
        'is_premium': isPremium,
        'potential_price': price,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'potential',
      });

      // 🤖 إطلاق automation للتسويق
      if (isPremium) {
        await _n8nService.triggerWorkflow('premium_item_created', {
          'type': type,
          'id': groupId ?? eventId,
          'price': price,
        });
      }
    } catch (e) {
      print('Error tracking potential revenue: $e');
    }
  }

  /// تسجيل الإيرادات الفعلية
  Future<void> _recordRevenue({
    required String type,
    required double amount,
    String? groupId,
    String? eventId,
    required String userId,
    required String paymentId,
  }) async {
    try {
      await _firestore.collection('revenue_records').add({
        'type': type,
        'amount': amount,
        'group_id': groupId,
        'event_id': eventId,
        'user_id': userId,
        'payment_id': paymentId,
        'recorded_at': DateTime.now().toIso8601String(),
        'status': 'completed',
      });

      // 📊 تحديث إحصائيات الإيرادات
      await _updateRevenueStats(type, amount);

      // 🎯 إطلاق automation لتحفيز المزيد من الشراء
      await _n8nService.triggerWorkflow('revenue_generated', {
        'type': type,
        'amount': amount,
        'user_id': userId,
      });
    } catch (e) {
      print('Error recording revenue: $e');
    }
  }

  /// تحديث إحصائيات الإيرادات
  Future<void> _updateRevenueStats(String type, double amount) async {
    try {
      final today = DateTime.now();
      final statsId = '${today.year}_${today.month}_${today.day}';

      await _firestore.collection('revenue_stats').doc(statsId).set({
        'date': today.toIso8601String(),
        'total_revenue': FieldValue.increment(amount),
        '${type}_revenue': FieldValue.increment(amount),
        '${type}_count': FieldValue.increment(1),
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error updating revenue stats: $e');
    }
  }

  /// تحديث engagement score
  Future<void> _updateEngagementScore(
    String targetId,
    String actionType,
  ) async {
    try {
      // قيم الـ engagement المختلفة
      final scores = {
        'view': 1,
        'reaction': 3,
        'comment': 5,
        'share': 8,
        'bookmark': 4,
      };

      final score = scores[actionType] ?? 1;

      await _firestore.collection('community_posts').doc(targetId).update({
        'engagement_score': FieldValue.increment(score),
      });
    } catch (e) {
      print('Error updating engagement score: $e');
    }
  }

  /// تتبع سلوك المستخدم
  Future<void> _trackUserBehavior({
    required String userId,
    required String action,
    required String targetId,
  }) async {
    try {
      await _firestore.collection('user_behavior').add({
        'user_id': userId,
        'action': action,
        'target_id': targetId,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // 🤖 تحليل البيانات وتحديث التوصيات
      await _n8nService.triggerWorkflow('analyze_user_behavior', {
        'user_id': userId,
        'action': action,
      });
    } catch (e) {
      print('Error tracking user behavior: $e');
    }
  }

  // =====================================================
  // 7️⃣ NOTIFICATIONS
  // =====================================================

  /// إرسال إشعارات التعليقات
  Future<void> _sendCommentNotifications(CommentModel comment) async {
    try {
      // جلب صاحب المنشور
      final postDoc = await _firestore
          .collection('community_posts')
          .doc(comment.postId)
          .get();
      if (!postDoc.exists) return;

      final postData = postDoc.data()!;
      final postAuthorId = postData['author_id'];

      // إشعار صاحب المنشور
      if (postAuthorId != comment.authorId) {
        await _createNotification(
          userId: postAuthorId,
          type: 'comment',
          title: 'تعليق جديد',
          body: '${comment.authorName} علق على منشورك',
          actorId: comment.authorId,
          actorName: comment.authorName,
          actorAvatar: comment.authorAvatar,
          actionUrl: '/post/${comment.postId}',
        );
      }

      // إشعارات للـ mentions
      for (final mentionedUserId in comment.mentions) {
        if (mentionedUserId != comment.authorId) {
          await _createNotification(
            userId: mentionedUserId,
            type: 'mention',
            title: 'ذكرك في تعليق',
            body: '${comment.authorName} ذكرك في تعليق',
            actorId: comment.authorId,
            actorName: comment.authorName,
            actorAvatar: comment.authorAvatar,
            actionUrl: '/post/${comment.postId}#comment-${comment.id}',
          );
        }
      }
    } catch (e) {
      print('Error sending comment notifications: $e');
    }
  }

  /// إنشاء إشعار
  Future<void> _createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? actorId,
    String? actorName,
    String? actorAvatar,
    String? actionUrl,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notification = CommunityNotificationModel(
        id: _firestore.collection('notifications').doc().id,
        userId: userId,
        type: type,
        title: title,
        body: body,
        actionUrl: actionUrl,
        imageUrl: imageUrl,
        data: data,
        isRead: false,
        createdAt: DateTime.now(),
        actorId: actorId,
        actorName: actorName,
        actorAvatar: actorAvatar,
      );

      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notification.toJson());

      // 🔔 إرسال push notification
      await _n8nService.triggerWorkflow('send_push_notification', {
        'user_id': userId,
        'title': title,
        'body': body,
        'data': data,
      });
    } catch (e) {
      print('Error creating notification: $e');
    }
  }

  // =====================================================
  // 8️⃣ ANALYTICS & INSIGHTS
  // =====================================================

  /// الحصول على تحليلات المجموعة
  Future<Map<String, dynamic>> getGroupAnalytics(String groupId) async {
    try {
      final group = await _firestore
          .collection('community_groups')
          .doc(groupId)
          .get();
      if (!group.exists) throw Exception('Group not found');

      // حساب معدل النمو
      final membershipQuery = await _firestore
          .collection('group_memberships')
          .where('group_id', isEqualTo: groupId)
          .orderBy('joined_at', descending: true)
          .limit(100)
          .get();

      final last30Days = membershipQuery.docs
          .where(
            (doc) => (doc.data()['joined_at'] as Timestamp).toDate().isAfter(
              DateTime.now().subtract(Duration(days: 30)),
            ),
          )
          .length;

      // حساب engagement rate
      final postsQuery = await _firestore
          .collection('community_posts')
          .where('group_id', isEqualTo: groupId)
          .get();

      final totalEngagement = postsQuery.docs.fold<int>(
        0,
        (sum, doc) => sum + (doc.data()['engagement_score'] ?? 0) as int,
      );

      final groupData = group.data()!;
      final membersCount = groupData['members_count'] ?? 1;

      return {
        'total_members': membersCount,
        'new_members_30d': last30Days,
        'growth_rate': (last30Days / max(membersCount - last30Days, 1) * 100)
            .toStringAsFixed(2),
        'total_posts': groupData['posts_count'] ?? 0,
        'engagement_score': groupData['engagement_score'] ?? 0,
        'engagement_rate': (totalEngagement / max(membersCount, 1))
            .toStringAsFixed(2),
        'is_premium': groupData['is_premium'] ?? false,
        'premium_price': groupData['premium_price'] ?? 0,
      };
    } catch (e) {
      print('Error getting group analytics: $e');
      return {};
    }
  }

  /// الحصول على تحليلات الحدث
  Future<Map<String, dynamic>> getEventAnalytics(String eventId) async {
    try {
      final event = await _firestore
          .collection('community_events')
          .doc(eventId)
          .get();
      if (!event.exists) throw Exception('Event not found');

      final eventData = event.data()!;

      // حساب معدل التحويل
      final attendeesCount = eventData['attendees_count'] ?? 0;
      final viewsCount = eventData['views_count'] ?? attendeesCount;
      final conversionRate = (attendeesCount / max(viewsCount, 1) * 100)
          .toStringAsFixed(2);

      // حساب الإيرادات
      final isPaid = eventData['is_paid'] ?? false;
      final price = eventData['price'] ?? 0.0;
      final totalRevenue = isPaid ? attendeesCount * price : 0.0;

      return {
        'total_attendees': attendeesCount,
        'max_attendees': eventData['max_attendees'] ?? 0,
        'capacity_used': eventData['max_attendees'] > 0
            ? (attendeesCount / eventData['max_attendees'] * 100)
                  .toStringAsFixed(2)
            : '0',
        'conversion_rate': conversionRate,
        'is_paid': isPaid,
        'price': price,
        'total_revenue': totalRevenue,
        'status': eventData['status'] ?? 'upcoming',
      };
    } catch (e) {
      print('Error getting event analytics: $e');
      return {};
    }
  }

  /// الحصول على Dashboard Analytics الشاملة
  Future<Map<String, dynamic>> getDashboardAnalytics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // إحصائيات المجموعات
      final myGroupsQuery = await _firestore
          .collection('community_groups')
          .where('creator_id', isEqualTo: user.uid)
          .get();

      final totalGroups = myGroupsQuery.docs.length;
      final premiumGroups = myGroupsQuery.docs
          .where((doc) => doc.data()['is_premium'] == true)
          .length;

      // إحصائيات الأحداث
      final myEventsQuery = await _firestore
          .collection('community_events')
          .where('organizer_id', isEqualTo: user.uid)
          .get();

      final totalEvents = myEventsQuery.docs.length;
      final paidEvents = myEventsQuery.docs
          .where((doc) => doc.data()['is_paid'] == true)
          .length;

      // حساب الإيرادات الإجمالية
      final revenueQuery = await _firestore
          .collection('revenue_records')
          .where('user_id', isEqualTo: user.uid)
          .get();

      final totalRevenue = revenueQuery.docs.fold<double>(
        0,
        (sum, doc) => sum + (doc.data()['amount'] ?? 0.0),
      );

      // إيرادات آخر 30 يوم
      final last30DaysRevenue = revenueQuery.docs
          .where(
            (doc) => DateTime.parse(
              doc.data()['recorded_at'],
            ).isAfter(DateTime.now().subtract(Duration(days: 30))),
          )
          .fold<double>(0, (sum, doc) => sum + (doc.data()['amount'] ?? 0.0));

      return {
        'total_groups': totalGroups,
        'premium_groups': premiumGroups,
        'total_events': totalEvents,
        'paid_events': paidEvents,
        'total_revenue': totalRevenue,
        'revenue_30d': last30DaysRevenue,
        'revenue_growth': totalRevenue > 0
            ? ((last30DaysRevenue / (totalRevenue - last30DaysRevenue)) * 100)
                  .toStringAsFixed(2)
            : '0',
      };
    } catch (e) {
      print('Error getting dashboard analytics: $e');
      return {};
    }
  }
}
