import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../models/n8n_workflow_model.dart';
import '../models/n8n_workflow_execution_model.dart';
import 'http_service.dart';

class N8nWorkflowService extends GetxController {
  final HttpService _httpService = Get.find<HttpService>();
  final String baseUrl = 'https://mediaprosocial.io/api';

  final RxList<N8nWorkflowModel> workflows = <N8nWorkflowModel>[].obs;
  final RxList<N8nWorkflowExecutionModel> executions = <N8nWorkflowExecutionModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isPosting = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchWorkflows();
  }

  /// Fetch all active N8N workflows
  Future<bool> fetchWorkflows() async {
    try {
      isLoading.value = true;

      final response = await http.get(
        Uri.parse('$baseUrl/n8n-workflows'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          workflows.value = (data['data'] as List)
              .map((workflow) => N8nWorkflowModel.fromJson(workflow))
              .toList();
          print('✅ ${workflows.length} N8N workflows loaded');
          return true;
        }
      }

      print('⚠️ Failed to fetch workflows: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error fetching workflows: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get workflow by platform
  Future<N8nWorkflowModel?> getWorkflowByPlatform(String platform) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/n8n-workflows/platform/$platform'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return N8nWorkflowModel.fromJson(data['data']);
        }
      }

      return null;
    } catch (e) {
      print('❌ Error getting workflow for $platform: $e');
      return null;
    }
  }

  /// Post to social media platform using N8N workflow
  Future<Map<String, dynamic>> postToPlatform({
    required String platform,
    required String fileID,
    required String text,
    String? n8nUrl,
  }) async {
    try {
      isPosting.value = true;

      final response = await http.post(
        Uri.parse('$baseUrl/n8n-workflows/post'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ..._httpService.authHeaders,
        },
        body: json.encode({
          'platform': platform,
          'fileID': fileID,
          'text': text,
          if (n8nUrl != null) 'n8n_url': n8nUrl,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Successfully posted to $platform');

        // Refresh execution history
        await fetchExecutionHistory();

        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        print('⚠️ Failed to post to $platform: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'فشل النشر',
          'error': data['error'],
        };
      }
    } catch (e) {
      print('❌ Error posting to $platform: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
        'error': e.toString(),
      };
    } finally {
      isPosting.value = false;
    }
  }

  /// Execute a specific workflow
  Future<Map<String, dynamic>> executeWorkflow({
    required String workflowId,
    required String fileID,
    required String text,
    String? n8nUrl,
  }) async {
    try {
      isPosting.value = true;

      final response = await http.post(
        Uri.parse('$baseUrl/n8n-workflows/execute'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          ..._httpService.authHeaders,
        },
        body: json.encode({
          'workflow_id': workflowId,
          'fileID': fileID,
          'text': text,
          if (n8nUrl != null) 'n8n_url': n8nUrl,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('✅ Workflow executed successfully');

        // Refresh execution history
        await fetchExecutionHistory();

        return {
          'success': true,
          'message': data['message'],
          'data': data['data'],
        };
      } else {
        print('⚠️ Workflow execution failed: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'فشل تنفيذ Workflow',
          'error': data['error'],
        };
      }
    } catch (e) {
      print('❌ Error executing workflow: $e');
      return {
        'success': false,
        'message': 'حدث خطأ غير متوقع',
        'error': e.toString(),
      };
    } finally {
      isPosting.value = false;
    }
  }

  /// Fetch execution history
  Future<bool> fetchExecutionHistory({
    String? platform,
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (platform != null) 'platform': platform,
        if (status != null) 'status': status,
      };

      final uri = Uri.parse('$baseUrl/n8n-workflows/executions')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          ..._httpService.authHeaders,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          executions.value = (data['data']['data'] as List)
              .map((execution) => N8nWorkflowExecutionModel.fromJson(execution))
              .toList();
          print('✅ ${executions.length} executions loaded');
          return true;
        }
      }

      return false;
    } catch (e) {
      print('❌ Error fetching execution history: $e');
      return false;
    }
  }

  /// Get workflow statistics
  Future<Map<String, dynamic>?> getWorkflowStatistics(String workflowId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/n8n-workflows/$workflowId/statistics'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }

      return null;
    } catch (e) {
      print('❌ Error fetching workflow statistics: $e');
      return null;
    }
  }

  /// Get workflows by platform from local list
  List<N8nWorkflowModel> getWorkflowsByPlatform(String platform) {
    return workflows.where((w) => w.platform == platform).toList();
  }

  /// Check if a platform has an active workflow
  bool hasPlatformWorkflow(String platform) {
    return workflows.any((w) => w.platform == platform && w.isActive);
  }

  /// Get all supported platforms
  List<String> getSupportedPlatforms() {
    return workflows
        .where((w) => w.isActive)
        .map((w) => w.platform)
        .toSet()
        .toList();
  }
}
