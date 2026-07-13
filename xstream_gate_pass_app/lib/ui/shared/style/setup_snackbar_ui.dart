
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

/// Snackbar types for different scenarios across the app.
///
/// Usage:
/// ```dart
/// final _snackbarService = locator<SnackbarService>();
///
/// // Success message
/// _snackbarService.showCustomSnackBar(
///   variant: SnackbarType.success,
///   message: 'Item saved successfully',
/// );
///
/// // Error with action button
/// _snackbarService.showCustomSnackBar(
///   variant: SnackbarType.error,
///   message: 'Failed to save',
///   mainButtonTitle: 'Retry',
///   onMainButtonTapped: () => retry(),
/// );
/// ```
enum SnackbarType {
  /// Success messages - green theme
  /// Use for: save success, upload complete, action completed
  success,

  /// Error messages - red theme
  /// Use for: API errors, validation failures, critical issues
  error,

  /// Warning messages - amber/orange theme
  /// Use for: potential issues, confirmations needed, caution alerts
  warning,

  /// Informational messages - blue theme
  /// Use for: tips, hints, neutral notifications
  info,

  /// Location-related messages - teal theme
  /// Use for: location updates, GPS status, distance info
  location,

  /// Network/connectivity messages - grey theme
  /// Use for: offline mode, sync status, connection issues
  network,

  /// Upload/download progress - primary theme
  /// Use for: file uploads, sync progress, background tasks
  progress,

  /// Undo action messages - dark theme with action
  /// Use for: delete confirmations, reversible actions
  undo,

  /// Bid-related messages - accent theme
  /// Use for: bid placed, outbid notifications, auction updates
  bidding,

  /// Favorites/wishlist messages - pink theme
  /// Use for: added to favorites, removed from favorites
  favorite,

  /// Copy/share confirmation - subtle theme
  /// Use for: copied to clipboard, link shared
  clipboard,

  // Legacy types for backwards compatibility
  blueAndYellow,
  greenAndRed,
}

void setupSnackbarUi() {
  final service = locator<SnackbarService>();

  // ============================================================
  // DEFAULT SNACKBAR CONFIG
  // ============================================================
  service.registerSnackbarConfig(
    SnackbarConfig(
      backgroundColor: kcDarkGreyColor,
      textColor: Colors.white,
      mainButtonTextColor: kcPrimaryColor,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      animationDuration: const Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
    ),
  );

  // ============================================================
  // SUCCESS SNACKBAR - Green theme
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.success,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFF2E7D32), // Green 800
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.95),
      mainButtonTextColor: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.check_circle, color: Colors.white, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
    ),
  );

  // ============================================================
  // ERROR SNACKBAR - Red theme
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.error,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFFC62828), // Red 800
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.95),
      mainButtonTextColor: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.error, color: Colors.white, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 4),
    ),
  );

  // ============================================================
  // WARNING SNACKBAR - Amber/Orange theme
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.warning,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFFF57C00), // Orange 700
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.95),
      mainButtonTextColor: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.warning_amber_rounded,
          color: Colors.white, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 4),
    ),
  );

  // ============================================================
  // INFO SNACKBAR - Blue theme
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.info,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFF1565C0), // Blue 800
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.95),
      mainButtonTextColor: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.info, color: Colors.white, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
    ),
  );

  // ============================================================
  // LOCATION SNACKBAR - Teal theme
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.location,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFF00796B), // Teal 700
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.95),
      mainButtonTextColor: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.location_on, color: Colors.white, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
    ),
  );

  // ============================================================
  // NETWORK SNACKBAR - Grey theme for connectivity
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.network,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFF455A64), // Blue Grey 700
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.95),
      mainButtonTextColor: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.wifi_off, color: Colors.white, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 4),
    ),
  );

  // ============================================================
  // PROGRESS SNACKBAR - Primary theme for uploads/downloads
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.progress,
    config: SnackbarConfig(
      backgroundColor: kcPrimaryColor,
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.95),
      mainButtonTextColor: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.cloud_upload, color: Colors.white, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
    ),
  );

  // ============================================================
  // UNDO SNACKBAR - Dark theme with prominent action button
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.undo,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFF212121), // Grey 900
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.9),
      mainButtonTextColor: const Color(0xFF64B5F6), // Blue 300 - stands out
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.delete_outline, color: Colors.white70, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 5), // Longer for undo actions
    ),
  );

  // ============================================================
  // BIDDING SNACKBAR - Accent theme for auction activities
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.bidding,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFF6A1B9A), // Purple 800
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.95),
      mainButtonTextColor: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.gavel, color: Colors.white, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 3),
    ),
  );

  // ============================================================
  // FAVORITE SNACKBAR - Pink theme for wishlist actions
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.favorite,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFFC2185B), // Pink 700
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.95),
      mainButtonTextColor: Colors.white,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.favorite, color: Colors.white, size: 24),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 2),
    ),
  );

  // ============================================================
  // CLIPBOARD SNACKBAR - Subtle theme for copy actions
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.clipboard,
    config: SnackbarConfig(
      backgroundColor: const Color(0xFF37474F), // Blue Grey 800
      textColor: Colors.white,
      titleColor: Colors.white,
      messageColor: Colors.white.withOpacity(0.9),
      mainButtonTextColor: Colors.white70,
      borderRadius: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      icon: const Icon(Icons.content_copy, color: Colors.white70, size: 22),
      snackPosition: SnackPosition.BOTTOM,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
      duration: const Duration(seconds: 2),
    ),
  );

  // ============================================================
  // LEGACY SNACKBARS - Backwards compatibility
  // ============================================================
  service.registerCustomSnackbarConfig(
    variant: SnackbarType.blueAndYellow,
    config: SnackbarConfig(
      backgroundColor: Colors.blueAccent,
      textColor: Colors.yellow,
      borderRadius: 8,
      dismissDirection: DismissDirection.horizontal,
      snackStyle: SnackStyle.FLOATING,
    ),
  );

  service.registerCustomSnackbarConfig(
    variant: SnackbarType.greenAndRed,
    config: SnackbarConfig(
      backgroundColor: Colors.white,
      titleColor: Colors.green,
      messageColor: Colors.red,
      borderRadius: 8,
      snackStyle: SnackStyle.FLOATING,
    ),
  );
}

// ============================================================
// SNACKBAR HELPER EXTENSION
// ============================================================

/// Extension on SnackbarService for convenient typed snackbar methods.
///
/// Usage:
/// ```dart
/// _snackbarService.showSuccess('Item saved!');
/// _snackbarService.showError('Failed to save', onRetry: () => save());
/// _snackbarService.showUndo('Item deleted', onUndo: () => restore());
/// ```
extension SnackbarServiceExtension on SnackbarService {
  /// Show success snackbar
  Future<void> showSuccess(String message, {String? title}) async {
    await showCustomSnackBar(
      variant: SnackbarType.success,
      message: message,
      title: title,
    );
  }

  /// Show error snackbar with optional retry action
  Future<void> showError(
    String message, {
    String? title,
    VoidCallback? onRetry,
  }) async {
    await showCustomSnackBar(
      variant: SnackbarType.error,
      message: message,
      title: title ?? 'Error',
      mainButtonTitle: onRetry != null ? 'Retry' : null,
      onMainButtonTapped: onRetry,
    );
  }

  /// Show warning snackbar
  Future<void> showWarning(String message, {String? title}) async {
    await showCustomSnackBar(
      variant: SnackbarType.warning,
      message: message,
      title: title ?? 'Warning',
    );
  }

  /// Show info snackbar
  Future<void> showInfo(String message, {String? title}) async {
    await showCustomSnackBar(
      variant: SnackbarType.info,
      message: message,
      title: title,
    );
  }

  /// Show location-related snackbar with optional settings action
  Future<void> showLocation(
    String message, {
    String? title,
    VoidCallback? onOpenSettings,
  }) async {
    await showCustomSnackBar(
      variant: SnackbarType.location,
      message: message,
      title: title,
      mainButtonTitle: onOpenSettings != null ? 'Settings' : null,
      onMainButtonTapped: onOpenSettings,
    );
  }

  /// Show network/connectivity snackbar
  Future<void> showNetwork(String message,
      {String? title, bool isOffline = true}) async {
    await showCustomSnackBar(
      variant: SnackbarType.network,
      message: message,
      title: title ?? (isOffline ? 'Offline' : 'Connection'),
    );
  }

  /// Show undo snackbar with undo action
  Future<void> showUndo(
    String message, {
    required VoidCallback onUndo,
    String? title,
  }) async {
    await showCustomSnackBar(
      variant: SnackbarType.undo,
      message: message,
      title: title,
      mainButtonTitle: 'Undo',
      onMainButtonTapped: onUndo,
    );
  }

  /// Show bidding-related snackbar
  Future<void> showBidding(String message, {String? title}) async {
    await showCustomSnackBar(
      variant: SnackbarType.bidding,
      message: message,
      title: title,
    );
  }

  /// Show favorite/wishlist snackbar
  Future<void> showFavorite(String message, {bool added = true}) async {
    await showCustomSnackBar(
      variant: SnackbarType.favorite,
      message: message,
      title: added ? 'Added to Favorites' : 'Removed',
    );
  }

  /// Show clipboard copy confirmation
  Future<void> showCopied({String message = 'Copied to clipboard'}) async {
    await showCustomSnackBar(
      variant: SnackbarType.clipboard,
      message: message,
    );
  }

  /// Show progress/upload snackbar
  Future<void> showProgress(String message, {String? title}) async {
    await showCustomSnackBar(
      variant: SnackbarType.progress,
      message: message,
      title: title,
    );
  }
}
