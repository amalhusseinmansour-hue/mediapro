import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/scheduled_post_model.dart';

/// خدمة للتكامل مع n8n automation
/// تسمح بإنشاء وإدارة workflows للنشر التلقائي على منصات السوشال ميديا
class N8nService extends GetxService {
  final Logger _logger = Logger();

  // معلومات اتصال n8n - يجب تعيينها من الإعدادات
  String? _n8nUrl;
  String? _n8nApiKey;
  bool _isEnabled = false;

  // Getters
  bool get isEnabled => _isEnabled;
  String? get n8nUrl => _n8nUrl;

  /// تهيئة خدمة n8n
  Future<N8nService> init({String? n8nUrl, String? apiKey}) async {
    _n8nUrl = n8nUrl;
    _n8nApiKey = apiKey;
    _isEnabled = n8nUrl != null && n8nUrl.isNotEmpty;

    if (_isEnabled) {
      _logger.i('✅ N8N Service initialized with URL: $_n8nUrl');
    } else {
      _logger.w('⚠️ N8N Service disabled - no URL provided');
    }

    return this;
  }

  /// إنشاء workflow جديد في n8n لجدولة منشور
  Future<Map<String, dynamic>?> createScheduledPostWorkflow({
    required ScheduledPost post,
  }) async {
    if (!_isEnabled || _n8nUrl == null) {
      _logger.w('⚠️ N8N is not enabled');
      return null;
    }

    try {
      _logger.i('📤 Creating N8N workflow for post: ${post.id}');

      // إنشاء workflow definition
      final workflowData = {
        'name': 'Scheduled Post - ${post.id}',
        'active': true,
        'nodes': _buildWorkflowNodes(post),
        'connections': _buildWorkflowConnections(post.platforms.length),
        'settings': {'executionOrder': 'v1'},
        'staticData': null,
        'tags': ['social-media', 'scheduled-post'],
      };

      final response = await http.post(
        Uri.parse('$_n8nUrl/api/v1/workflows'),
        headers: {
          'Content-Type': 'application/json',
          if (_n8nApiKey != null) 'X-N8N-API-KEY': _n8nApiKey!,
        },
        body: jsonEncode(workflowData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = jsonDecode(response.body);
        _logger.i('✅ N8N workflow created: ${result['id']}');
        return result;
      } else {
        _logger.e('❌ Failed to create N8N workflow: ${response.statusCode}');
        _logger.e('Response: ${response.body}');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error creating N8N workflow: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// جدولة تنفيذ workflow في الوقت المحدد
  Future<Map<String, dynamic>?> scheduleWorkflowExecution({
    required String workflowId,
    required DateTime scheduledTime,
    required Map<String, dynamic> postData,
  }) async {
    if (!_isEnabled || _n8nUrl == null) {
      _logger.w('⚠️ N8N is not enabled');
      return null;
    }

    try {
      _logger.i('⏰ Scheduling N8N workflow execution for: $scheduledTime');

      // استخدام webhook trigger مع cron schedule
      final cronExpression = _generateCronExpression(scheduledTime);

      final response = await http.post(
        Uri.parse('$_n8nUrl/api/v1/workflows/$workflowId/activate'),
        headers: {
          'Content-Type': 'application/json',
          if (_n8nApiKey != null) 'X-N8N-API-KEY': _n8nApiKey!,
        },
        body: jsonEncode({
          'active': true,
          'cronExpression': cronExpression,
          'data': postData,
        }),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _logger.i('✅ Workflow scheduled successfully');
        return result;
      } else {
        _logger.e('❌ Failed to schedule workflow: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error scheduling workflow: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// تنفيذ workflow فوري
  Future<Map<String, dynamic>?> executeWorkflow({
    required String workflowId,
    required Map<String, dynamic> postData,
  }) async {
    if (!_isEnabled || _n8nUrl == null) {
      _logger.w('⚠️ N8N is not enabled');
      return null;
    }

    try {
      _logger.i('🚀 Executing N8N workflow immediately: $workflowId');

      final response = await http.post(
        Uri.parse('$_n8nUrl/api/v1/workflows/$workflowId/execute'),
        headers: {
          'Content-Type': 'application/json',
          if (_n8nApiKey != null) 'X-N8N-API-KEY': _n8nApiKey!,
        },
        body: jsonEncode(postData),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        _logger.i('✅ Workflow executed successfully');
        return result;
      } else {
        _logger.e('❌ Failed to execute workflow: ${response.statusCode}');
        return null;
      }
    } catch (e, stackTrace) {
      _logger.e(
        '❌ Error executing workflow: $e',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// الحصول على حالة تنفيذ workflow
  Future<Map<String, dynamic>?> getExecutionStatus(String executionId) async {
    if (!_isEnabled || _n8nUrl == null) {
      return null;
    }

    try {
      final response = await http.get(
        Uri.parse('$_n8nUrl/api/v1/executions/$executionId'),
        headers: {if (_n8nApiKey != null) 'X-N8N-API-KEY': _n8nApiKey!},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      _logger.e('❌ Error getting execution status: $e');
      return null;
    }
  }

  /// حذف workflow
  Future<bool> deleteWorkflow(String workflowId) async {
    if (!_isEnabled || _n8nUrl == null) {
      return false;
    }

    try {
      final response = await http.delete(
        Uri.parse('$_n8nUrl/api/v1/workflows/$workflowId'),
        headers: {if (_n8nApiKey != null) 'X-N8N-API-KEY': _n8nApiKey!},
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      _logger.e('❌ Error deleting workflow: $e');
      return false;
    }
  }

  /// بناء nodes للـ workflow
  List<Map<String, dynamic>> _buildWorkflowNodes(ScheduledPost post) {
    final nodes = <Map<String, dynamic>>[];

    // Start node
    nodes.add({
      'parameters': {},
      'name': 'Start',
      'type': 'n8n-nodes-base.start',
      'typeVersion': 1,
      'position': [250, 300],
    });

    // Schedule Trigger
    nodes.add({
      'parameters': {
        'rule': {
          'interval': [
            {
              'field': 'cronExpression',
              'expression': _generateCronExpression(post.scheduledTime),
            },
          ],
        },
      },
      'name': 'Schedule',
      'type': 'n8n-nodes-base.scheduleTrigger',
      'typeVersion': 1,
      'position': [450, 300],
    });

    // إضافة node لكل منصة
    int yPosition = 200;
    for (final platform in post.platforms) {
      nodes.add(_createPlatformNode(platform, yPosition, post));
      yPosition += 150;
    }

    return nodes;
  }

  /// إنشاء node لمنصة معينة
  Map<String, dynamic> _createPlatformNode(
    String platform,
    int yPosition,
    ScheduledPost post,
  ) {
    final nodeTypes = {
      'facebook': 'n8n-nodes-base.facebookGraph',
      'instagram': 'n8n-nodes-base.instagram',
      'twitter': 'n8n-nodes-base.twitter',
      'linkedin': 'n8n-nodes-base.linkedIn',
      'youtube': 'n8n-nodes-base.youtube',
      'tiktok': 'n8n-nodes-base.tikTok',
    };

    return {
      'parameters': {
        'operation': 'post',
        'message': post.content,
        'mediaUrls': post.mediaUrls ?? [],
        'additionalFields': post.platformSettings?[platform] ?? {},
      },
      'name': 'Post to ${platform.capitalize}',
      'type': nodeTypes[platform.toLowerCase()] ?? 'n8n-nodes-base.httpRequest',
      'typeVersion': 1,
      'position': [650, yPosition],
      'credentials': {
        platform: {'id': '1', 'name': '$platform Account'},
      },
    };
  }

  /// بناء الاتصالات بين الـ nodes
  Map<String, dynamic> _buildWorkflowConnections(int platformCount) {
    final connections = <String, dynamic>{
      'Schedule': {
        'main': [
          List.generate(
            platformCount,
            (index) => {
              'node': 'Post to Platform $index',
              'type': 'main',
              'index': 0,
            },
          ),
        ],
      },
    };

    return connections;
  }

  /// توليد Cron expression من التاريخ
  String _generateCronExpression(DateTime dateTime) {
    // Format: minute hour day month dayOfWeek
    return '${dateTime.minute} ${dateTime.hour} ${dateTime.day} ${dateTime.month} *';
  }

  /// التحقق من اتصال n8n
  Future<bool> testConnection() async {
    if (!_isEnabled || _n8nUrl == null) {
      return false;
    }

    try {
      final response = await http.get(
        Uri.parse('$_n8nUrl/healthz'),
        headers: {if (_n8nApiKey != null) 'X-N8N-API-KEY': _n8nApiKey!},
      );

      final isConnected = response.statusCode == 200;
      if (isConnected) {
        _logger.i('✅ N8N connection test successful');
      } else {
        _logger.w('⚠️ N8N connection test failed: ${response.statusCode}');
      }
      return isConnected;
    } catch (e) {
      _logger.e('❌ N8N connection test error: $e');
      return false;
    }
  }

  /// تنفيذ workflow بناءً على الاسم (الأسماء القديمة)
  Future<Map<String, dynamic>?> triggerWorkflow(
    String workflowName,
    Map<String, dynamic> data,
  ) async {
    // استخدام executeWorkflow مع workflowName بدلاً من workflowId
    // هذا متوافق مع الكود القديم
    _logger.i('🔔 Triggering workflow: $workflowName');

    // يمكن تنفيذ البيانات مباشرة للـ webhook
    try {
      if (!_isEnabled || _n8nUrl == null) {
        _logger.w('⚠️ N8N is not enabled');
        return null;
      }

      final response = await http.post(
        Uri.parse('$_n8nUrl/webhook/$workflowName'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.i('✅ Workflow triggered: $workflowName');
        return {'success': true, 'data': data};
      } else {
        _logger.w('⚠️ Workflow trigger response: ${response.statusCode}');
        return {'success': false, 'statusCode': response.statusCode};
      }
    } catch (e) {
      _logger.e('❌ Error triggering workflow: $e');
      return null;
    }
  }

  /// الحصول على قائمة workflows
  Future<List<Map<String, dynamic>>> getWorkflows() async {
    if (!_isEnabled || _n8nUrl == null) {
      return [];
    }

    try {
      final response = await http.get(
        Uri.parse('$_n8nUrl/api/v1/workflows'),
        headers: {if (_n8nApiKey != null) 'X-N8N-API-KEY': _n8nApiKey!},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      }
      return [];
    } catch (e) {
      _logger.e('❌ Error getting workflows: $e');
      return [];
    }
  }
}
