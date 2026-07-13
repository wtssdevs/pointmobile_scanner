enum AuthPortal {
  xac,
  cms,
}

extension AuthPortalMetadata on AuthPortal {
  String get displayName {
    switch (this) {
      case AuthPortal.xac:
        return 'Xstream Gatepass';
      case AuthPortal.cms:
        return 'CMS';
    }
  }

  String get shortLabel {
    switch (this) {
      case AuthPortal.xac:
        return 'XAC';
      case AuthPortal.cms:
        return 'CMS';
    }
  }

  String get storagePrefix {
    switch (this) {
      case AuthPortal.xac:
        return 'xac';
      case AuthPortal.cms:
        return 'cms';
    }
  }

  static AuthPortal? fromStorageValue(String? value) {
    switch (value) {
      case 'xac':
        return AuthPortal.xac;
      case 'cms':
        return AuthPortal.cms;
      default:
        return null;
    }
  }
}