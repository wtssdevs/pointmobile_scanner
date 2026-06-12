import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_error_translator.dart';

void main() {
  final requestOptions = RequestOptions(
    path: '/api/services/app/MobileInspections/GetInspectableContainers',
  );

  DioException dio({
    Object? error,
    Response<dynamic>? response,
    DioExceptionType type = DioExceptionType.badResponse,
  }) {
    return DioException(
      requestOptions: requestOptions,
      error: error,
      response: response,
      type: type,
    );
  }

  Response<dynamic> resp(dynamic data, int statusCode) {
    return Response<dynamic>(
      requestOptions: requestOptions,
      data: data,
      statusCode: statusCode,
    );
  }

  group('CmsErrorTranslator', () {
    test('SocketException-wrapped DioException returns offline text', () {
      final result = CmsErrorTranslator.messageFrom(
        dio(
          error: const SocketException('failed'),
          type: DioExceptionType.connectionError,
        ),
      );

      expect(result, 'No connection. Check your network and try again.');
    });

    test('ABP 500 with message and details prefers details', () {
      final result = CmsErrorTranslator.messageFrom(
        dio(
          response: resp(
            {
              'error': {'message': 'Top message', 'details': 'Friendly details'}
            },
            500,
          ),
        ),
      );

      expect(result, 'Friendly details');
    });

    test('ABP 500 with message only returns message', () {
      final result = CmsErrorTranslator.messageFrom(
        dio(
          response: resp(
            {
              'error': {'message': 'Just a message', 'details': null}
            },
            500,
          ),
        ),
      );

      expect(result, 'Just a message');
    });

    test('ABP body provided as JSON string is parsed', () {
      final result = CmsErrorTranslator.messageFrom(
        dio(
          response: resp(
            '{"error":{"message":"Str message","details":"Str details"}}',
            500,
          ),
        ),
      );

      expect(result, 'Str details');
    });

    test('403 without ABP body returns permission text', () {
      final result = CmsErrorTranslator.messageFrom(dio(response: resp(null, 403)));

      expect(
        result,
        "You don't have permission for this action. Sign in again if this persists.",
      );
    });

    test('garbage HTML body returns fallback', () {
      final result = CmsErrorTranslator.messageFrom(
        dio(response: resp('<html><body>502 Bad Gateway</body></html>', 502)),
      );

      expect(result, 'Something went wrong. Please try again.');
    });

    test('non-Dio error returns fallback', () {
      expect(
        CmsErrorTranslator.messageFrom(const FormatException('bad')),
        'Something went wrong. Please try again.',
      );
    });

    test('output never contains DioException text', () {
      final results = <String>[
        CmsErrorTranslator.messageFrom(
          dio(
            error: const SocketException('x'),
            type: DioExceptionType.connectionError,
          ),
        ),
        CmsErrorTranslator.messageFrom(
          dio(
            response: resp(
              {
                'error': {'message': 'm', 'details': 'd'}
              },
              500,
            ),
          ),
        ),
        CmsErrorTranslator.messageFrom(dio(response: resp(null, 403))),
        CmsErrorTranslator.messageFrom(dio(response: resp('<html>', 502))),
        CmsErrorTranslator.messageFrom(Exception('raw exception text')),
      ];

      for (final result in results) {
        expect(result.contains('DioException'), isFalse);
        expect(result.contains('Exception'), isFalse);
      }
    });
  });
}
