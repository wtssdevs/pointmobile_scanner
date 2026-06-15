import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_survey_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/surveys/list/cms_surveys_list_viewmodel.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsSurveysListViewModel -', () {
    late MockCmsMobileSurveyService cmsMobileSurveyService;

    setUp(() {
      registerServices();
      cmsMobileSurveyService =
          locator<CmsMobileSurveyService>() as MockCmsMobileSurveyService;
    });

    tearDown(() => locator.reset());

    test('list load failure surfaces a friendly translated message', () async {
      when(cmsMobileSurveyService.getList(any)).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: '/surveys'),
          response: Response(
            requestOptions: RequestOptions(path: '/surveys'),
            statusCode: 500,
            data: const {
              'error': {'message': 'Surveys are unavailable right now.'}
            },
          ),
        ),
      );

      final model = CmsSurveysListViewModel();
      await model.fetchPage(1);

      expect(model.loadError, 'Surveys are unavailable right now.');
    });
  });
}
