import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/user_model.dart';
import '../core/config/backend_config.dart';

/// Laravel API Service
/// Handles all communication with the Laravel backend
class LaravelApiService extends GetxController {
  // استخدام BackendConfig للحصول على Base URL الموحد
  static String get baseUrl => BackendConfig.baseUrl;

  final RxBool isLoading = false.obs;
  final RxString authToken = ''.obs;

  // ==================== AUTHENTICATION ====================

  /// Register or update user after phone verification
  Future<bool> registerUser(UserModel user) async {
    try {
      isLoading.value = true;
      print('📤 Attempting to sync user data to Laravel API...');

      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(user.toJson()),
      ).timeout(const Duration(seconds: 10));

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);

        // Save auth token if provided
        if (data['token'] != null) {
          authToken.value = data['token'];
          print('✅ Auth token saved');
        }

        print('✅ User synced successfully with Laravel API');
        return true;
      } else {
        print('⚠️ Laravel API returned status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      // Silent fail - Laravel API not available yet
      print('ℹ️ Laravel API not available - user saved locally only');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user data
  Future<bool> updateUser(UserModel user) async {
    try {
      isLoading.value = true;
      print('📤 Updating user data in Laravel API...');

      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
        body: json.encode(user.toJson()),
      );

      if (response.statusCode == 200) {
        print('✅ User updated successfully in Laravel');
        return true;
      } else {
        print('❌ Failed to update user: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating user: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      isLoading.value = true;
      print('📤 Fetching user from Laravel API...');

      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ User fetched successfully from Laravel');
        return UserModel.fromJson(data['user']);
      } else {
        print('❌ Failed to fetch user: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching user: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Update user last login
  Future<bool> updateUserLastLogin(String userId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/login'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Last login updated in Laravel');
        return true;
      } else {
        print('❌ Failed to update last login: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating last login: $e');
      return false;
    }
  }

  // ==================== GENERIC HTTP METHODS ====================

  /// Generic GET method
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Authorization': authToken.value.isNotEmpty ? 'Bearer ${authToken.value}' : '',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generic POST method
  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': authToken.value.isNotEmpty ? 'Bearer ${authToken.value}' : '',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}',
          'body': response.body,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generic PUT method
  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': authToken.value.isNotEmpty ? 'Bearer ${authToken.value}' : '',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Generic DELETE method
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Authorization': authToken.value.isNotEmpty ? 'Bearer ${authToken.value}' : '',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Request failed with status: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ==================== SUBSCRIPTION ====================

  /// Update user subscription
  Future<bool> updateUserSubscription({
    required String userId,
    required String tier,
    required String subscriptionType,
    DateTime? endDate,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId/subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
        body: json.encode({
          'tier': tier,
          'subscription_type': subscriptionType,
          'end_date': endDate?.toIso8601String(),
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Subscription updated in Laravel');
        return true;
      } else {
        print('❌ Failed to update subscription: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error updating subscription: $e');
      return false;
    }
  }

  // ==================== WALLET OPERATIONS ====================

  /// Create wallet transaction
  Future<bool> createWalletTransaction({
    required String userId,
    required String type,
    required double amount,
    required String description,
    String? referenceId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/wallet/transactions'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
        body: json.encode({
          'user_id': userId,
          'type': type,
          'amount': amount,
          'description': description,
          'reference_id': referenceId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Wallet transaction created in Laravel');
        return true;
      } else {
        print('❌ Failed to create wallet transaction: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error creating wallet transaction: $e');
      return false;
    }
  }

  /// Get wallet balance
  Future<double?> getWalletBalance(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/wallet/$userId/balance'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Wallet balance fetched from Laravel');
        return (data['balance'] as num).toDouble();
      } else {
        print('❌ Failed to fetch wallet balance: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching wallet balance: $e');
      return null;
    }
  }

  // ==================== TELEGRAM BOTS ====================

  /// Get all connected Telegram bots for the current user
  Future<List<Map<String, dynamic>>> getTelegramBots() async {
    try {
      print('📤 Fetching Telegram bots from backend...');
      final response = await http.get(
        Uri.parse('$baseUrl/telegram-bots'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Telegram bots fetched successfully');
        return List<Map<String, dynamic>>.from(data['bots'] ?? []);
      } else {
        print('❌ Failed to fetch Telegram bots: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching Telegram bots: $e');
      return [];
    }
  }

  /// Connect a new Telegram bot
  Future<Map<String, dynamic>> connectTelegramBot({
    required String botToken,
    required String botUsername,
  }) async {
    try {
      print('📤 Connecting Telegram bot: $botUsername');
      final response = await http.post(
        Uri.parse('$baseUrl/telegram-bots'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
        body: json.encode({
          'bot_token': botToken,
          'bot_username': botUsername,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Telegram bot connected successfully');
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ Failed to connect bot: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to connect bot',
        };
      }
    } catch (e) {
      print('❌ Error connecting Telegram bot: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Disconnect a Telegram bot
  Future<bool> disconnectTelegramBot(String botId) async {
    try {
      print('📤 Disconnecting Telegram bot: $botId');
      final response = await http.delete(
        Uri.parse('$baseUrl/telegram-bots/$botId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Telegram bot disconnected successfully');
        return true;
      } else {
        print('❌ Failed to disconnect bot: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error disconnecting Telegram bot: $e');
      return false;
    }
  }

  /// Publish content to Telegram channel using bot
  Future<Map<String, dynamic>> publishToTelegram({
    required String botId,
    required String channelUsername,
    required String content,
    String? imageUrl,
    List<String>? hashtags,
  }) async {
    try {
      print('📤 Publishing to Telegram channel: @$channelUsername');
      final response = await http.post(
        Uri.parse('$baseUrl/telegram-bots/$botId/publish'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
        body: json.encode({
          'channel_username': channelUsername,
          'content': content,
          'image_url': imageUrl,
          'hashtags': hashtags,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Published to Telegram successfully');
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ Failed to publish to Telegram: ${response.statusCode}');
        final data = json.decode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to publish',
        };
      }
    } catch (e) {
      print('❌ Error publishing to Telegram: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get Telegram channel info
  Future<Map<String, dynamic>?> getTelegramChannelInfo({
    required String botId,
    required String channelUsername,
  }) async {
    try {
      print('📤 Fetching Telegram channel info: @$channelUsername');
      final response = await http.get(
        Uri.parse('$baseUrl/telegram-bots/$botId/channel/$channelUsername'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Telegram channel info fetched successfully');
        return data;
      } else {
        print('❌ Failed to fetch channel info: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error fetching Telegram channel info: $e');
      return null;
    }
  }

  // ==================== AUTOMATION WORKFLOWS ====================

  /// Get all workflows for the current user
  Future<List<Map<String, dynamic>>> getWorkflows() async {
    try {
      print('📤 Fetching workflows from backend...');
      final response = await http.get(
        Uri.parse('$baseUrl/n8n-workflows'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Workflows fetched successfully');
        return List<Map<String, dynamic>>.from(data['workflows'] ?? []);
      } else {
        print('❌ Failed to fetch workflows: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching workflows: $e');
      return [];
    }
  }

  /// Create a new workflow
  Future<Map<String, dynamic>> createWorkflow({
    required String name,
    required String description,
    required String trigger,
    required String action,
  }) async {
    try {
      print('📤 Creating workflow: $name');
      final response = await http.post(
        Uri.parse('$baseUrl/n8n-workflows'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
        body: json.encode({
          'name': name,
          'description': description,
          'trigger': trigger,
          'action': action,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Workflow created successfully');
        return {
          'success': true,
          'data': data,
        };
      } else {
        print('❌ Failed to create workflow: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to create workflow',
        };
      }
    } catch (e) {
      print('❌ Error creating workflow: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Delete a workflow
  Future<bool> deleteWorkflow(String workflowId) async {
    try {
      print('📤 Deleting workflow: $workflowId');
      final response = await http.delete(
        Uri.parse('$baseUrl/n8n-workflows/$workflowId'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
      );

      if (response.statusCode == 200) {
        print('✅ Workflow deleted successfully');
        return true;
      } else {
        print('❌ Failed to delete workflow: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error deleting workflow: $e');
      return false;
    }
  }

  /// Toggle workflow active status
  Future<bool> toggleWorkflow(String workflowId, bool isActive) async {
    try {
      print('📤 Toggling workflow: $workflowId to ${isActive ? "active" : "inactive"}');
      final response = await http.patch(
        Uri.parse('$baseUrl/n8n-workflows/$workflowId/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${authToken.value}',
        },
        body: json.encode({
          'is_active': isActive,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Workflow toggled successfully');
        return true;
      } else {
        print('❌ Failed to toggle workflow: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error toggling workflow: $e');
      return false;
    }
  }

  // ==================== UTILITIES ====================

  /// Check if API is reachable
  Future<bool> checkConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Laravel API not reachable: $e');
      return false;
    }
  }

  /// Set auth token (after login)
  void setAuthToken(String token) {
    authToken.value = token;
    print('✅ Auth token set');
  }

  /// Clear auth token (after logout)
  void clearAuthToken() {
    authToken.value = '';
    print('✅ Auth token cleared');
  }
}
