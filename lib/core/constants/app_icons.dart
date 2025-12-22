import 'package:flutter/material.dart';

/// Modern and attractive icons for the app
class AppIcons {
  // Dashboard Icons - Using modern rounded filled versions
  static const IconData home = Icons.home_rounded;
  static const IconData dashboard = Icons.dashboard_rounded;
  static const IconData rocket = Icons.rocket_launch_rounded;
  static const IconData sparkles = Icons.auto_awesome_rounded;

  // Content Icons
  static const IconData content = Icons.article_rounded;
  static const IconData edit = Icons.edit_note_rounded;
  static const IconData create = Icons.create_rounded;
  static const IconData document = Icons.description_rounded;
  static const IconData image = Icons.image_rounded;
  static const IconData video = Icons.videocam_rounded;
  static const IconData attachment = Icons.attach_file_rounded;

  // Social Media Platform Icons
  static const IconData instagram = Icons.camera_alt_rounded;
  static const IconData facebook = Icons.facebook_rounded;
  static const IconData twitter = Icons.flutter_dash_rounded; // Modern alternative
  static const IconData linkedin = Icons.work_rounded;
  static const IconData youtube = Icons.play_circle_rounded;
  static const IconData tiktok = Icons.music_note_rounded;

  // Analytics Icons
  static const IconData analytics = Icons.insights_rounded;
  static const IconData chart = Icons.bar_chart_rounded;
  static const IconData trending = Icons.trending_up_rounded;
  static const IconData growth = Icons.show_chart_rounded;
  static const IconData stats = Icons.analytics_outlined;

  // Gamification Icons
  static const IconData trophy = Icons.emoji_events_rounded;
  static const IconData medal = Icons.military_tech_rounded;
  static const IconData star = Icons.star_rounded;
  static const IconData fire = Icons.local_fire_department_rounded;
  static const IconData diamond = Icons.diamond_rounded;
  static const IconData crown = Icons.workspace_premium_rounded;
  static const IconData achievement = Icons.auto_awesome_rounded;
  static const IconData level = Icons.bar_chart_rounded;
  static const IconData xp = Icons.bolt_rounded;

  // AI & Smart Features Icons
  static const IconData ai = Icons.psychology_rounded;
  static const IconData brain = Icons.psychology_alt_rounded;
  static const IconData magic = Icons.auto_fix_high_rounded;
  static const IconData wand = Icons.auto_awesome_rounded;
  static const IconData robot = Icons.smart_toy_rounded;
  static const IconData spark = Icons.offline_bolt_rounded;
  static const IconData lightbulb = Icons.lightbulb_rounded;

  // Time & Schedule Icons
  static const IconData schedule = Icons.schedule_rounded;
  static const IconData calendar = Icons.calendar_month_rounded;
  static const IconData clock = Icons.access_time_rounded;
  static const IconData timer = Icons.timer_rounded;
  static const IconData alarm = Icons.alarm_rounded;

  // Notifications Icons
  static const IconData notification = Icons.notifications_rounded;
  static const IconData notificationActive = Icons.notifications_active_rounded;
  static const IconData bell = Icons.notifications_active_rounded;

  // User & Account Icons
  static const IconData user = Icons.person_rounded;
  static const IconData account = Icons.account_circle_rounded;
  static const IconData accounts = Icons.people_rounded;
  static const IconData profile = Icons.badge_rounded;
  static const IconData team = Icons.groups_rounded;
  static const IconData community = Icons.diversity_3_rounded;

  // Settings Icons
  static const IconData settings = Icons.settings_rounded;
  static const IconData tune = Icons.tune_rounded;
  static const IconData filter = Icons.filter_alt_rounded;

  // Actions Icons
  static const IconData add = Icons.add_circle_rounded;
  static const IconData remove = Icons.remove_circle_rounded;
  static const IconData check = Icons.check_circle_rounded;
  static const IconData close = Icons.cancel_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData save = Icons.save_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData send = Icons.send_rounded;
  static const IconData download = Icons.download_rounded;
  static const IconData upload = Icons.upload_rounded;
  static const IconData copy = Icons.content_copy_rounded;
  static const IconData paste = Icons.content_paste_rounded;

  // Navigation Icons
  static const IconData menu = Icons.menu_rounded;
  static const IconData more = Icons.more_vert_rounded;
  static const IconData back = Icons.arrow_back_ios_rounded;
  static const IconData forward = Icons.arrow_forward_ios_rounded;
  static const IconData up = Icons.arrow_upward_rounded;
  static const IconData down = Icons.arrow_downward_rounded;

  // Status Icons
  static const IconData success = Icons.check_circle_rounded;
  static const IconData error = Icons.error_rounded;
  static const IconData warning = Icons.warning_rounded;
  static const IconData info = Icons.info_rounded;

  // Engagement Icons
  static const IconData like = Icons.favorite_rounded;
  static const IconData comment = Icons.chat_bubble_rounded;
  static const IconData view = Icons.visibility_rounded;
  static const IconData reach = Icons.people_rounded;
  static const IconData engagement = Icons.thumb_up_rounded;

  // Premium Features Icons
  static const IconData premium = Icons.workspace_premium_rounded;
  static const IconData pro = Icons.star_rounded;
  static const IconData unlock = Icons.lock_open_rounded;
  static const IconData lock = Icons.lock_rounded;

  // Trending & Discovery Icons
  static const IconData hotTrending = Icons.whatshot_rounded;
  static const IconData explore = Icons.explore_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData compass = Icons.explore_rounded;

  // Performance Icons
  static const IconData speed = Icons.speed_rounded;
  static const IconData optimize = Icons.auto_fix_high_rounded;
  static const IconData boost = Icons.rocket_launch_rounded;

  // Hashtag & Tags Icons
  static const IconData hashtag = Icons.tag_rounded;
  static const IconData tag = Icons.local_offer_rounded;
  static const IconData label = Icons.label_rounded;

  // Security Icons
  static const IconData security = Icons.security_rounded;
  static const IconData shield = Icons.shield_rounded;
  static const IconData verified = Icons.verified_rounded;

  // Help & Support Icons
  static const IconData help = Icons.help_rounded;
  static const IconData support = Icons.support_agent_rounded;
  static const IconData feedback = Icons.feedback_rounded;

  // Other Modern Icons
  static const IconData gift = Icons.card_giftcard_rounded;
  static const IconData wallet = Icons.account_balance_wallet_rounded;
  static const IconData language = Icons.language_rounded;
  static const IconData theme = Icons.palette_rounded;
  static const IconData dark = Icons.dark_mode_rounded;
  static const IconData light = Icons.light_mode_rounded;
  static const IconData auto = Icons.brightness_auto_rounded;
}

/// Helper to get platform specific icons
class PlatformIcons {
  static IconData getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'instagram':
        return AppIcons.instagram;
      case 'facebook':
        return AppIcons.facebook;
      case 'twitter':
      case 'x':
        return AppIcons.twitter;
      case 'linkedin':
        return AppIcons.linkedin;
      case 'youtube':
        return AppIcons.youtube;
      case 'tiktok':
        return AppIcons.tiktok;
      default:
        return AppIcons.share;
    }
  }
}
