import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/notification_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService extends GetxController {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxString fcmToken = ''.obs;

  static const String _notificationsBoxName = 'notifications';
  Box<NotificationModel>? _notificationsBox;

  @override
  void onInit() {
    super.onInit();
    initializeNotifications();
    loadNotifications();
    initializeFirebaseMessaging();
  }

  Future<void> initializeNotifications() async {
    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS initialization settings
      const DarwinInitializationSettings iOSSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      await _notificationsPlugin.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Request permissions for Android 13+
      await _requestPermissions();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (GetPlatform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidImplementation?.requestNotificationsPermission();
    } else if (GetPlatform.isIOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      debugPrint('iOS notification permission granted: $granted');
    }
  }

  Future<void> loadNotifications() async {
    try {
      _notificationsBox = await Hive.openBox<NotificationModel>(_notificationsBoxName);
      notifications.value = _notificationsBox?.values.toList() ?? [];
      notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error loading notifications: $e');
      notifications.value = [];
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> showNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    String? imageUrl,
    Map<String, dynamic>? data,
  }) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      // Create notification model
      final notification = NotificationModel(
        id: const Uuid().v4(),
        title: title,
        body: body,
        type: type,
        timestamp: DateTime.now(),
        imageUrl: imageUrl,
        data: data,
      );

      // Save to storage
      await _saveNotification(notification);

      // Show local notification
      await _showLocalNotification(
        id: notificationId,
        title: title,
        body: body,
        type: type,
      );
    } catch (e) {
      debugPrint('Error showing notification: $e');
    }
  }

  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    required NotificationType type,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'social_media_manager_channel',
      'ميديا برو',
      channelDescription: 'إشعارات تطبيق ميديا برو',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      color: _getColorForType(type),
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  Color _getColorForType(NotificationType type) {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF4CAF50);
      case NotificationType.error:
        return const Color(0xFFF44336);
      case NotificationType.warning:
        return const Color(0xFFFFC107);
      case NotificationType.post:
        return const Color(0xFF00E5FF);
      case NotificationType.analytics:
        return const Color(0xFF7C4DFF);
      default:
        return const Color(0xFF00E5FF);
    }
  }

  Future<void> _saveNotification(NotificationModel notification) async {
    try {
      await _notificationsBox?.put(notification.id, notification);
      notifications.insert(0, notification);
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error saving notification: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final index = notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        notifications[index].isRead = true;
        await _notificationsBox?.put(notificationId, notifications[index]);
        notifications.refresh();
        _updateUnreadCount();
      }
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      for (var notification in notifications) {
        notification.isRead = true;
        await _notificationsBox?.put(notification.id, notification);
      }
      notifications.refresh();
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsBox?.delete(notificationId);
      notifications.removeWhere((n) => n.id == notificationId);
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      await _notificationsBox?.clear();
      notifications.clear();
      _updateUnreadCount();
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // Handle notification tap - navigate to relevant screen
    Get.toNamed('/notifications');
  }

  // Scheduled notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    NotificationType type = NotificationType.scheduled,
  }) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'social_media_manager_channel',
        'ميديا برو',
        channelDescription: 'إشعارات تطبيق ميديا برو',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        color: _getColorForType(type),
      );

      const DarwinNotificationDetails iOSDetails = DarwinNotificationDetails();

      final NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iOSDetails,
      );

      await _notificationsPlugin.zonedSchedule(
        notificationId,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      // Save scheduled notification
      final notification = NotificationModel(
        id: const Uuid().v4(),
        title: title,
        body: body,
        type: type,
        timestamp: scheduledDate,
      );
      await _saveNotification(notification);
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Firebase Cloud Messaging
  Future<void> initializeFirebaseMessaging() async {
    try {
      // Request permission for iOS
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('User granted permission');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        debugPrint('User granted provisional permission');
      } else {
        debugPrint('User declined or has not accepted permission');
      }

      // Get FCM token
      String? token = await _firebaseMessaging.getToken(
        vapidKey: 'BP9QWgJU-O750OC18NZlQxXRs1kXPfiOTodRwvWe_sn2LOZaNtb5eqf0lEUvHhiXmoVbEAa_-6Yo7Oxz94I7_yA',
      );
      fcmToken.value = token ?? '';
      debugPrint('FCM Token: $token');
      // هنا يمكنك إرسال التوكن إلى السيرفر الخاص بك
    
      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        debugPrint('FCM Token refreshed: $newToken');
        // هنا يمكنك تحديث التوكن في السيرفر الخاص بك
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('Got a message whilst in the foreground!');
        debugPrint('Message data: ${message.data}');

        if (message.notification != null) {
          debugPrint('Message also contained a notification: ${message.notification}');
          showNotification(
            title: message.notification!.title ?? 'إشعار جديد',
            body: message.notification!.body ?? '',
            type: _getNotificationTypeFromData(message.data),
            data: message.data,
          );
        }
      });

      // Handle background messages
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Handle notification taps when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        debugPrint('A new onMessageOpenedApp event was published!');
        _handleNotificationTap(message.data);
      });

      // Check if app was opened from notification
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationTap(initialMessage.data);
      }
    } catch (e) {
      debugPrint('Error initializing Firebase Messaging: $e');
    }
  }

  NotificationType _getNotificationTypeFromData(Map<String, dynamic> data) {
    String? type = data['type'];
    switch (type) {
      case 'success':
        return NotificationType.success;
      case 'error':
        return NotificationType.error;
      case 'warning':
        return NotificationType.warning;
      case 'post':
        return NotificationType.post;
      case 'analytics':
        return NotificationType.analytics;
      case 'scheduled':
        return NotificationType.scheduled;
      default:
        return NotificationType.general;
    }
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    debugPrint('Handling notification tap with data: $data');
    // Handle navigation based on notification data
    if (data.containsKey('route')) {
      Get.toNamed(data['route']);
    } else {
      Get.toNamed('/notifications');
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic: $e');
    }
  }

  // Send sample notifications for testing
  Future<void> sendTestNotifications() async {
    await showNotification(
      title: 'منشور جديد تم نشره',
      body: 'تم نشر منشورك على Instagram بنجاح!',
      type: NotificationType.success,
    );

    await Future.delayed(const Duration(seconds: 1));

    await showNotification(
      title: 'تحليلات جديدة متاحة',
      body: 'نما حسابك بنسبة 15% هذا الأسبوع',
      type: NotificationType.analytics,
    );

    await Future.delayed(const Duration(seconds: 1));

    await showNotification(
      title: 'تذكير بالجدولة',
      body: 'لديك 3 منشورات مجدولة لليوم',
      type: NotificationType.scheduled,
    );
  }
}

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Handling a background message: ${message.messageId}');
  // يمكنك معالجة الرسالة هنا
}
