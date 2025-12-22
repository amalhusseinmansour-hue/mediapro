class N8nWorkflowModel {
  final int id;
  final String workflowId;
  final String name;
  final String? description;
  final String platform;
  final String type;
  final Map<String, dynamic> workflowJson;
  final Map<String, dynamic>? inputSchema;
  final String? n8nUrl;
  final String? credentialId;
  final String uploadPostUser;
  final bool isActive;
  final int executionCount;
  final DateTime? lastExecutedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  N8nWorkflowModel({
    required this.id,
    required this.workflowId,
    required this.name,
    this.description,
    required this.platform,
    required this.type,
    required this.workflowJson,
    this.inputSchema,
    this.n8nUrl,
    this.credentialId,
    required this.uploadPostUser,
    required this.isActive,
    required this.executionCount,
    this.lastExecutedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory N8nWorkflowModel.fromJson(Map<String, dynamic> json) {
    return N8nWorkflowModel(
      id: json['id'],
      workflowId: json['workflow_id'],
      name: json['name'],
      description: json['description'],
      platform: json['platform'],
      type: json['type'],
      workflowJson: json['workflow_json'] is String
          ? {}
          : json['workflow_json'] as Map<String, dynamic>,
      inputSchema: json['input_schema'] != null
          ? (json['input_schema'] is String
              ? {}
              : json['input_schema'] as Map<String, dynamic>)
          : null,
      n8nUrl: json['n8n_url'],
      credentialId: json['credential_id'],
      uploadPostUser: json['upload_post_user'] ?? 'uploadn8n',
      isActive: json['is_active'] ?? true,
      executionCount: json['execution_count'] ?? 0,
      lastExecutedAt: json['last_executed_at'] != null
          ? DateTime.tryParse(json['last_executed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workflow_id': workflowId,
      'name': name,
      'description': description,
      'platform': platform,
      'type': type,
      'workflow_json': workflowJson,
      'input_schema': inputSchema,
      'n8n_url': n8nUrl,
      'credential_id': credentialId,
      'upload_post_user': uploadPostUser,
      'is_active': isActive,
      'execution_count': executionCount,
      'last_executed_at': lastExecutedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Get platform display name
  String get platformDisplayName {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return 'Instagram';
      case 'tiktok':
        return 'TikTok';
      case 'youtube':
        return 'YouTube';
      case 'facebook':
        return 'Facebook';
      case 'twitter':
        return 'Twitter';
      case 'linkedin':
        return 'LinkedIn';
      default:
        return platform;
    }
  }

  /// Get type display name
  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'video':
        return 'فيديو';
      case 'image':
        return 'صورة';
      case 'text':
        return 'نص';
      case 'carousel':
        return 'مجموعة';
      default:
        return type;
    }
  }

  /// Get platform icon
  String get platformIcon {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return '📸';
      case 'tiktok':
        return '🎵';
      case 'youtube':
        return '🎥';
      case 'facebook':
        return '👥';
      case 'twitter':
        return '🐦';
      case 'linkedin':
        return '💼';
      default:
        return '📱';
    }
  }

  /// Check if workflow requires fileID (for video/image posts)
  bool get requiresFileID {
    return type == 'video' || type == 'image';
  }

  /// Get success rate percentage
  double? get successRate {
    if (executionCount == 0) return null;
    // Note: This would require execution stats from the API
    // For now, we return null as a placeholder
    return null;
  }

  @override
  String toString() {
    return 'N8nWorkflow{id: $id, name: $name, platform: $platform, type: $type, isActive: $isActive}';
  }
}
