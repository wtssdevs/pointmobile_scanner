import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';

/// Which login portal(s) a build exposes. Driven by the `APP_PORTAL_MODE` env
/// key so a single codebase can ship as:
/// - [dual]: both XAC and CMS tabs (dev / QA).
/// - [cms]: CMS login only (e.g. the Google Play Store build).
/// - [xac]: XAC login only (e.g. the Point Mobile device build).
enum AppPortalMode { dual, cms, xac }

extension AppPortalModeX on AppPortalMode {
  /// Portals this mode exposes, in display order. Never empty; the first entry
  /// is the mode's default portal.
  List<AuthPortal> get enabledPortals {
    switch (this) {
      case AppPortalMode.dual:
        return const [AuthPortal.xac, AuthPortal.cms];
      case AppPortalMode.cms:
        return const [AuthPortal.cms];
      case AppPortalMode.xac:
        return const [AuthPortal.xac];
    }
  }

  /// Parses the env value. Unknown / missing values fall back to [dual] so the
  /// full experience is preserved unless a build explicitly restricts it.
  static AppPortalMode fromValue(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'cms':
        return AppPortalMode.cms;
      case 'xac':
        return AppPortalMode.xac;
      case 'dual':
      default:
        return AppPortalMode.dual;
    }
  }
}
