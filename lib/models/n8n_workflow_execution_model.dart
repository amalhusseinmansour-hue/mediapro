class N8nWorkflowExecutionModel {
  final int id;
  final int? userId;
  final String workflowId;
  final String? executionId;
  final String platform;
  final String status;
  final Map<String, dynamic> inputData;
  final Map<String, dynamic>? outputData;
  final String? errorMessage;
  final Map<String, dynamic>? errorDetails;
  final String? postUrl;
  final int? duration;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  N8nWorkflowExecutionModel({
    required this.id,
    this.userId,
    required this.workflowId,
    this.executionId,
    required this.platform,
    required this.status,
    required this.inputData,
    this.outputData,
    this.errorMessage,
    this.errorDetails,
    this.postUrl,
    this.duration,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory N8nWorkflowExecutionModel.fromJson(Map<String, dynamic> json) {
    return N8nWorkflowExecutionModel(
      id: json['id'],
      userId: json['user_id'],
      workflowId: json['workflow_id'],
      executionId: json['execution_id'],
      platform: json['platform'],
      status: json['status'],
      inputData: json['input_data'] is String
          ? {}
          : json['input_data'] as Map<String, dynamic>,
      outputData: json['output_data'] != null
          ? (json['output_data'] is String
              ? {}
              : json['output_data'] as Map<String, dynamic>)
          : null,
      errorMessage: json['error_message'],
      errorDetails: json['error_details'] != null
          ? (json['error_details'] is String
              ? {}
              : json['error_details'] as Map<String, dynamic>)
          : null,
      postUrl: json['post_url'],
      duration: json['duration'],
      startedAt: json['started_at'] != null
          ? DateTime.tryParse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'workflow_id': workflowId,
      'execution_id': executionId,
      'platform': platform,
      'status': status,
      'input_data': inputData,
      'output_data': outputData,
      'error_message': errorMessage,
      'error_details': errorDetails,
      'post_url': postUrl,
      'duration': duration,
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Check if execution is successful
  bool get isSuccessful => status == 'success';

  /// Check if execution failed
  bool get isFailed => status == 'failed';

  /// Check if execution is pending
  bool get isPending => status == 'pending';

  /// Check if execution is running
  bool get isRunning => status == 'running';

  /// Get status display name in Arabic
  String get statusDisplayName {
    switch (status.toLowerCase()) {
      case 'success':
        return 'نجح';
      case 'failed':
        return 'فشل';
      case 'pending':
        return 'معلق';
      case 'running':
        return 'جاري التنفيذ';
      default:
        return status;
    }
  }

  /// Get status color
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'success':
        return 'green';
      case 'failed':
        return 'red';
      case 'pending':
        return 'orange';
      case 'running':
        return 'blue';
      default:
        return 'gray';
    }
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
      default:
        return platform;
    }
  }

  /// Get execution duration in readable format
  String? get durationFormatted {
    if (duration == null) return null;

    if (duration! < 60) {
      return '$duration ثانية';
    } else if (duration! < 3600) {
      final minutes = (duration! / 60).floor();
      final seconds = duration! % 60;
      return '$minutes دقيقة $seconds ثانية';
    } else {
      final hours = (duration! / 3600).floor();
      final minutes = ((duration! % 3600) / 60).floor();
      return '$hours ساعة $minutes دقيقة';
    }
  }

  @override
  String toString() {
    return 'N8nWorkflowExecution{id: $id, platform: $platform, status: $status, duration: $durationFormatted}';
  }
}
