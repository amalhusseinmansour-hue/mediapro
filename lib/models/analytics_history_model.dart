import 'package:hive/hive.dart';

part 'analytics_history_model.g.dart';

@HiveType(typeId: 90)
class AnalyticsHistoryModel extends HiveObject {
  @HiveField(0)
  final DateTime date;

  @HiveField(1)
  final int totalFollowers;

  @HiveField(2)
  final int totalPosts;

  @HiveField(3)
  final double avgEngagementRate;

  @HiveField(4)
  final Map<String, int> followersByPlatform;

  AnalyticsHistoryModel({
    required this.date,
    required this.totalFollowers,
    required this.totalPosts,
    required this.avgEngagementRate,
    required this.followersByPlatform,
  });
}
