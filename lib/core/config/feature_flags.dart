import 'dart:io';

/// Feature Flags Configuration
/// Used to control feature visibility across the app
class FeatureFlags {
  // Private constructor
  FeatureFlags._();

  /// Show subscription/payment features
  /// Set to false to hide subscriptions on iOS for App Store approval
  /// After approval, set to true and update the app
  static bool get showSubscriptions {
    // Hide subscriptions on iOS until App Store approval
    if (Platform.isIOS) {
      return false; // Change to true after App Store approval
    }
    return true; // Always show on Android
  }

  /// Show payment options
  static bool get showPayments {
    if (Platform.isIOS) {
      return false; // Change to true after App Store approval
    }
    return true;
  }

  /// Show wallet features
  static bool get showWallet {
    if (Platform.isIOS) {
      return false; // Change to true after App Store approval
    }
    return true;
  }

  /// Show premium upgrade prompts
  static bool get showUpgradePrompts {
    if (Platform.isIOS) {
      return false; // Change to true after App Store approval
    }
    return true;
  }

  /// Check if running on iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if running on Android
  static bool get isAndroid => Platform.isAndroid;
}
