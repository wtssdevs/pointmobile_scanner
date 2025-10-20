import 'dart:convert';

import 'package:xstream_gate_pass_app/core/utils/helper.dart';

class LocalizationConfiguration {
  final MultiTenancy multiTenancy;
  final Session session;
  final Localization localization;
  final Features features;
  final Auth auth;
  final Nav nav;
  final Settings setting;
  final Clock clock;
  final Timing timing;
  final Security security;
  final Map<String, dynamic> custom;

  LocalizationConfiguration({
    required this.multiTenancy,
    required this.session,
    required this.localization,
    required this.features,
    required this.auth,
    required this.nav,
    required this.setting,
    required this.clock,
    required this.timing,
    required this.security,
    required this.custom,
  });

  factory LocalizationConfiguration.fromJson(Map<String, dynamic> json) =>
      LocalizationConfiguration(
        multiTenancy: MultiTenancy.fromJson(json["multiTenancy"]),
        session: Session.fromJson(json["session"]),
        localization: Localization.fromJson(json["localization"]),
        features: Features.fromJson(json["features"]),
        auth: Auth.fromJson(json["auth"]),
        nav: Nav.fromJson(json["nav"]),
        setting: Settings.fromJson(json["setting"]),
        clock: Clock.fromJson(json["clock"]),
        timing: Timing.fromJson(json["timing"]),
        security: Security.fromJson(json["security"]),
        custom: json["custom"] ?? {},
      );
}

class MultiTenancy {
  final bool isEnabled;
  final bool ignoreFeatureCheckForHostUsers;
  final MultiTenancySides sides;

  MultiTenancy({
    required this.isEnabled,
    required this.ignoreFeatureCheckForHostUsers,
    required this.sides,
  });

  factory MultiTenancy.fromJson(Map<String, dynamic> json) => MultiTenancy(
        isEnabled: json["isEnabled"],
        ignoreFeatureCheckForHostUsers: json["ignoreFeatureCheckForHostUsers"],
        sides: MultiTenancySides.fromJson(json["sides"]),
      );
}

class MultiTenancySides {
  final int host;
  final int tenant;

  MultiTenancySides({
    required this.host,
    required this.tenant,
  });

  factory MultiTenancySides.fromJson(Map<String, dynamic> json) =>
      MultiTenancySides(
        host: json["host"],
        tenant: json["tenant"],
      );
}

class Session {
  final int? userId;
  final int tenantId;
  final int? impersonatorUserId;
  final int? impersonatorTenantId;
  final int multiTenancySide;

  Session({
    this.userId,
    required this.tenantId,
    this.impersonatorUserId,
    this.impersonatorTenantId,
    required this.multiTenancySide,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
        userId: json["userId"],
        tenantId: json["tenantId"],
        impersonatorUserId: json["impersonatorUserId"],
        impersonatorTenantId: json["impersonatorTenantId"],
        multiTenancySide: json["multiTenancySide"],
      );
}

class Localization {
  final CurrentCulture currentCulture;
  final List<Language> languages;
  final Language currentLanguage;
  final List<Source> sources;
  final Map<String, Map<String, String>> values;

  Localization({
    required this.currentCulture,
    required this.languages,
    required this.currentLanguage,
    required this.sources,
    required this.values,
  });

  factory Localization.fromJson(Map<String, dynamic> json) => Localization(
        currentCulture: CurrentCulture.fromJson(json["currentCulture"]),
        languages: List<Language>.from(
            json["languages"].map((x) => Language.fromJson(x))),
        currentLanguage: Language.fromJson(json["currentLanguage"]),
        sources:
            List<Source>.from(json["sources"].map((x) => Source.fromJson(x))),
        values: Map.from(json["values"]).map((k, v) =>
            MapEntry<String, Map<String, String>>(
                k, Map<String, String>.from(v))),
      );
}

class CurrentCulture {
  final String name;
  final String displayName;

  CurrentCulture({
    required this.name,
    required this.displayName,
  });

  factory CurrentCulture.fromJson(Map<String, dynamic> json) => CurrentCulture(
        name: json["name"],
        displayName: json["displayName"],
      );
}

class Language {
  final String name;
  final String displayName;
  final String icon;
  final bool isDefault;
  final bool isDisabled;
  final bool isRightToLeft;

  Language({
    required this.name,
    required this.displayName,
    required this.icon,
    required this.isDefault,
    required this.isDisabled,
    required this.isRightToLeft,
  });

  factory Language.fromJson(Map<String, dynamic> json) => Language(
        name: json["name"],
        displayName: json["displayName"],
        icon: json["icon"],
        isDefault: json["isDefault"],
        isDisabled: json["isDisabled"],
        isRightToLeft: json["isRightToLeft"],
      );
}

class Source {
  final String name;
  final String type;

  Source({
    required this.name,
    required this.type,
  });

  factory Source.fromJson(Map<String, dynamic> json) => Source(
        name: json["name"],
        type: json["type"],
      );
}

class Features {
  final Map<String, dynamic> allFeatures;

  Features({
    required this.allFeatures,
  });

  factory Features.fromJson(Map<String, dynamic> json) => Features(
        allFeatures: json["allFeatures"] ?? {},
      );
}

class Auth {
  final Map<String, bool> allPermissions;
  final Map<String, bool> grantedPermissions;

  Auth({
    required this.allPermissions,
    required this.grantedPermissions,
  });

  // factory Auth.fromJson(Map<String, dynamic> json) => Auth(
  //       allPermissions: Map<String, bool>.from(json["allPermissions"]),
  //       grantedPermissions: Map<String, bool>.from(json["grantedPermissions"]),
  //     );
  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
        allPermissions: Map.from(json["allPermissions"]).map(
          (key, value) =>
              MapEntry(key, value.toString().toLowerCase() == 'true'),
        ),
        grantedPermissions: Map.from(json["grantedPermissions"]).map(
          (key, value) =>
              MapEntry(key, value.toString().toLowerCase() == 'true'),
        ),
      );
}

class Nav {
  final Menus menus;

  Nav({
    required this.menus,
  });

  factory Nav.fromJson(Map<String, dynamic> json) => Nav(
        menus: Menus.fromJson(json["menus"]),
      );
}

class Menus {
  final Map<String, Menu> menus;

  Menus({
    required this.menus,
  });

  factory Menus.fromJson(Map<String, dynamic> json) => Menus(
        menus: Map.from(json)
            .map((k, v) => MapEntry<String, Menu>(k, Menu.fromJson(v))),
      );
}

class Menu {
  final String name;
  final String displayName;
  final dynamic customData;
  final List<dynamic> items;

  Menu({
    required this.name,
    required this.displayName,
    this.customData,
    required this.items,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        name: json["name"],
        displayName: json["displayName"],
        customData: json["customData"],
        items: List<dynamic>.from(json["items"].map((x) => x)),
      );
}

class Settings {
  final Map<String, String> values;

  Settings({
    required this.values,
  });

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        values: Map<String, String>.from(json["values"]),
      );
}

class Clock {
  final String provider;

  Clock({
    required this.provider,
  });

  factory Clock.fromJson(Map<String, dynamic> json) => Clock(
        provider: json["provider"],
      );
}

class Timing {
  final TimeZoneInfo timeZoneInfo;

  Timing({
    required this.timeZoneInfo,
  });

  factory Timing.fromJson(Map<String, dynamic> json) => Timing(
        timeZoneInfo: TimeZoneInfo.fromJson(json["timeZoneInfo"]),
      );
}

class TimeZoneInfo {
  final WindowsTimeZone windows;
  final IanaTimeZone iana;

  TimeZoneInfo({
    required this.windows,
    required this.iana,
  });

  factory TimeZoneInfo.fromJson(Map<String, dynamic> json) => TimeZoneInfo(
        windows: WindowsTimeZone.fromJson(json["windows"]),
        iana: IanaTimeZone.fromJson(json["iana"]),
      );
}

class WindowsTimeZone {
  final String timeZoneId;
  final int baseUtcOffsetInMilliseconds;
  final int currentUtcOffsetInMilliseconds;
  final bool isDaylightSavingTimeNow;

  WindowsTimeZone({
    required this.timeZoneId,
    required this.baseUtcOffsetInMilliseconds,
    required this.currentUtcOffsetInMilliseconds,
    required this.isDaylightSavingTimeNow,
  });

  factory WindowsTimeZone.fromJson(Map<String, dynamic> json) =>
      WindowsTimeZone(
        timeZoneId: json["timeZoneId"],
        baseUtcOffsetInMilliseconds: json["baseUtcOffsetInMilliseconds"],
        currentUtcOffsetInMilliseconds: json["currentUtcOffsetInMilliseconds"],
        isDaylightSavingTimeNow: json["isDaylightSavingTimeNow"],
      );
}

class IanaTimeZone {
  final String timeZoneId;

  IanaTimeZone({
    required this.timeZoneId,
  });

  factory IanaTimeZone.fromJson(Map<String, dynamic> json) => IanaTimeZone(
        timeZoneId: json["timeZoneId"],
      );
}

class Security {
  final AntiForgery antiForgery;

  Security({
    required this.antiForgery,
  });

  factory Security.fromJson(Map<String, dynamic> json) => Security(
        antiForgery: AntiForgery.fromJson(json["antiForgery"]),
      );
}

class AntiForgery {
  final String tokenCookieName;
  final String tokenHeaderName;

  AntiForgery({
    required this.tokenCookieName,
    required this.tokenHeaderName,
  });

  factory AntiForgery.fromJson(Map<String, dynamic> json) => AntiForgery(
        tokenCookieName: json["tokenCookieName"],
        tokenHeaderName: json["tokenHeaderName"],
      );
}
