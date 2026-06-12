import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

/// Translates transport/ABP errors into short user-facing text for CMS banners.
///
/// Never exposes exception class names, stack traces, or URLs.
class CmsErrorTranslator {
  CmsErrorTranslator._();

  static const String offlineMessage =
      'No connection. Check your network and try again.';
  static const String _permissionMessage =
      "You don't have permission for this action. Sign in again if this persists.";

  /// Returns a short, user-facing message for [error].
  static String messageFrom(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    if (error is DioException) {
      if (_isOffline(error)) {
        return offlineMessage;
      }

      final abpMessage = _abpMessageFrom(error.response?.data);
      if (abpMessage != null && abpMessage.isNotEmpty) {
        return abpMessage;
      }

      final statusCode = error.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return _permissionMessage;
      }

      return fallback;
    }

    return fallback;
  }

  static bool _isOffline(DioException error) {
    if (error.error is SocketException) {
      return true;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.connectionError:
        return true;
      default:
        return false;
    }
  }

  /// Extracts the ABP error message/details from a response body that may be a
  /// [Map] or a JSON [String]. Returns null when no ABP envelope is present.
  /// Parses defensively and never throws.
  static String? _abpMessageFrom(dynamic data) {
    try {
      Map<dynamic, dynamic>? body;
      if (data is Map) {
        body = data;
      } else if (data is String) {
        final trimmed = data.trim();
        if (trimmed.isEmpty) {
          return null;
        }

        final decoded = jsonDecode(trimmed);
        if (decoded is Map) {
          body = decoded;
        }
      }

      if (body == null) {
        return null;
      }

      final errorNode = body['error'];
      if (errorNode is! Map) {
        return null;
      }

      final details = _trimToNull(errorNode['details']);
      if (details != null) {
        return details;
      }

      return _trimToNull(errorNode['message']);
    } catch (_) {
      return null;
    }
  }

  static String? _trimToNull(dynamic value) {
    if (value is! String) {
      return null;
    }

    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
