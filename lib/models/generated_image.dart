class GeneratedImage {
  final String id;
  final String imageUrl;
  final String prompt;
  final String? negativePrompt;
  final DateTime createdAt;
  final int width;
  final int height;
  final String? seed;
  final double? cfgScale;
  final int? steps;

  GeneratedImage({
    required this.id,
    required this.imageUrl,
    required this.prompt,
    this.negativePrompt,
    required this.createdAt,
    this.width = 512,
    this.height = 512,
    this.seed,
    this.cfgScale,
    this.steps,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'prompt': prompt,
      'negativePrompt': negativePrompt,
      'createdAt': createdAt.toIso8601String(),
      'width': width,
      'height': height,
      'seed': seed,
      'cfgScale': cfgScale,
      'steps': steps,
    };
  }

  factory GeneratedImage.fromJson(Map<String, dynamic> json) {
    return GeneratedImage(
      id: json['id'],
      imageUrl: json['imageUrl'],
      prompt: json['prompt'],
      negativePrompt: json['negativePrompt'],
      createdAt: DateTime.parse(json['createdAt']),
      width: json['width'] ?? 512,
      height: json['height'] ?? 512,
      seed: json['seed'],
      cfgScale: json['cfgScale']?.toDouble(),
      steps: json['steps'],
    );
  }
}
