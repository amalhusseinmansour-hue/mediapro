class TranscribedAudio {
  final String id;
  final String? audioPath;
  final String transcribedText;
  final DateTime createdAt;
  final int duration; // in seconds
  final String language;
  final String? title;
  final List<AudioSegment> segments;
  final double confidence;
  final AudioSource source; // recording or file

  TranscribedAudio({
    required this.id,
    this.audioPath,
    required this.transcribedText,
    required this.createdAt,
    this.duration = 0,
    this.language = 'ar',
    this.title,
    this.segments = const [],
    this.confidence = 0.0,
    this.source = AudioSource.recording,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'audioPath': audioPath,
      'transcribedText': transcribedText,
      'createdAt': createdAt.toIso8601String(),
      'duration': duration,
      'language': language,
      'title': title,
      'segments': segments.map((s) => s.toJson()).toList(),
      'confidence': confidence,
      'source': source.toString(),
    };
  }

  factory TranscribedAudio.fromJson(Map<String, dynamic> json) {
    return TranscribedAudio(
      id: json['id'],
      audioPath: json['audioPath'],
      transcribedText: json['transcribedText'],
      createdAt: DateTime.parse(json['createdAt']),
      duration: json['duration'] ?? 0,
      language: json['language'] ?? 'ar',
      title: json['title'],
      segments: (json['segments'] as List?)
              ?.map((s) => AudioSegment.fromJson(s))
              .toList() ??
          [],
      confidence: json['confidence']?.toDouble() ?? 0.0,
      source: json['source'] == 'AudioSource.file'
          ? AudioSource.file
          : AudioSource.recording,
    );
  }
}

class AudioSegment {
  final int startTime; // in milliseconds
  final int endTime; // in milliseconds
  final String text;
  final double confidence;

  AudioSegment({
    required this.startTime,
    required this.endTime,
    required this.text,
    this.confidence = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'text': text,
      'confidence': confidence,
    };
  }

  factory AudioSegment.fromJson(Map<String, dynamic> json) {
    return AudioSegment(
      startTime: json['startTime'],
      endTime: json['endTime'],
      text: json['text'],
      confidence: json['confidence']?.toDouble() ?? 0.0,
    );
  }
}

enum AudioSource {
  recording,
  file,
}
