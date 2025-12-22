class VideoScript {
  final String id;
  final String topic;
  final String script;
  final String? description;
  final DateTime createdAt;
  final int estimatedDuration; // in seconds
  final String language;
  final String videoType; // educational, entertainment, promotional, etc.
  final List<ScriptScene> scenes;

  VideoScript({
    required this.id,
    required this.topic,
    required this.script,
    this.description,
    required this.createdAt,
    this.estimatedDuration = 60,
    this.language = 'ar',
    this.videoType = 'educational',
    this.scenes = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic': topic,
      'script': script,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'estimatedDuration': estimatedDuration,
      'language': language,
      'videoType': videoType,
      'scenes': scenes.map((s) => s.toJson()).toList(),
    };
  }

  factory VideoScript.fromJson(Map<String, dynamic> json) {
    return VideoScript(
      id: json['id'],
      topic: json['topic'],
      script: json['script'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      estimatedDuration: json['estimatedDuration'] ?? 60,
      language: json['language'] ?? 'ar',
      videoType: json['videoType'] ?? 'educational',
      scenes: (json['scenes'] as List?)
              ?.map((s) => ScriptScene.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class ScriptScene {
  final int sceneNumber;
  final String text;
  final String? voiceOver;
  final String? visualDescription;
  final int duration; // in seconds

  ScriptScene({
    required this.sceneNumber,
    required this.text,
    this.voiceOver,
    this.visualDescription,
    this.duration = 5,
  });

  Map<String, dynamic> toJson() {
    return {
      'sceneNumber': sceneNumber,
      'text': text,
      'voiceOver': voiceOver,
      'visualDescription': visualDescription,
      'duration': duration,
    };
  }

  factory ScriptScene.fromJson(Map<String, dynamic> json) {
    return ScriptScene(
      sceneNumber: json['sceneNumber'],
      text: json['text'],
      voiceOver: json['voiceOver'],
      visualDescription: json['visualDescription'],
      duration: json['duration'] ?? 5,
    );
  }
}

class GeneratedVideo {
  final String id;
  final String scriptId;
  final String videoUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final int duration; // in seconds
  final String status; // generating, completed, failed
  final String? errorMessage;

  GeneratedVideo({
    required this.id,
    required this.scriptId,
    required this.videoUrl,
    this.thumbnailUrl,
    required this.createdAt,
    this.duration = 0,
    this.status = 'completed',
    this.errorMessage,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'scriptId': scriptId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration,
      'status': status,
      'errorMessage': errorMessage,
    };
  }

  factory GeneratedVideo.fromJson(Map<String, dynamic> json) {
    return GeneratedVideo(
      id: json['id'],
      scriptId: json['scriptId'],
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      duration: json['duration'] ?? 0,
      status: json['status'] ?? 'completed',
      errorMessage: json['errorMessage'],
    );
  }
}
