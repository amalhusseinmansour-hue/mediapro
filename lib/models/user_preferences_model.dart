import 'package:hive/hive.dart';

part 'user_preferences_model.g.dart';

@HiveType(typeId: 10)
class UserPreferencesModel extends HiveObject {
  @HiveField(0)
  String userId;

  @HiveField(1)
  String language; // ar, en

  @HiveField(2)
  bool darkMode;

  @HiveField(3)
  bool notificationsEnabled;

  @HiveField(4)
  bool soundEnabled;

  @HiveField(5)
  bool vibrationEnabled;

  @HiveField(6)
  String defaultPlatform; // Default platform to share to

  @HiveField(7)
  List<String> favoritePlatforms; // Favorited platforms

  @HiveField(8)
  bool autoSaveDrafts;

  @HiveField(9)
  int reminderMinutesBefore; // Remind X minutes before scheduled post

  @HiveField(10)
  DateTime? lastBackupDate;

  @HiveField(11)
  bool analyticsEnabled;

  @HiveField(12)
  Map<String, dynamic>? customSettings;

  UserPreferencesModel({
    required this.userId,
    this.language = 'ar',
    this.darkMode = true,
    this.notificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.defaultPlatform = '',
    this.favoritePlatforms = const [],
    this.autoSaveDrafts = true,
    this.reminderMinutesBefore = 30,
    this.lastBackupDate,
    this.analyticsEnabled = true,
    this.customSettings,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'language': language,
      'darkMode': darkMode,
      'notificationsEnabled': notificationsEnabled,
      'soundEnabled': soundEnabled,
      'vibrationEnabled': vibrationEnabled,
      'defaultPlatform': defaultPlatform,
      'favoritePlatforms': favoritePlatforms,
      'autoSaveDrafts': autoSaveDrafts,
      'reminderMinutesBefore': reminderMinutesBefore,
      'lastBackupDate': lastBackupDate?.toIso8601String(),
      'analyticsEnabled': analyticsEnabled,
      'customSettings': customSettings,
    };
  }

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      userId: json['userId'] ?? '',
      language: json['language'] ?? 'ar',
      darkMode: json['darkMode'] ?? true,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      soundEnabled: json['soundEnabled'] ?? true,
      vibrationEnabled: json['vibrationEnabled'] ?? true,
      defaultPlatform: json['defaultPlatform'] ?? '',
      favoritePlatforms: List<String>.from(json['favoritePlatforms'] ?? []),
      autoSaveDrafts: json['autoSaveDrafts'] ?? true,
      reminderMinutesBefore: json['reminderMinutesBefore'] ?? 30,
      lastBackupDate: json['lastBackupDate'] != null
          ? DateTime.parse(json['lastBackupDate'])
          : null,
      analyticsEnabled: json['analyticsEnabled'] ?? true,
      customSettings: json['customSettings'],
    );
  }
}
