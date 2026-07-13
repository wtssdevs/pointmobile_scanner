import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_list_dto.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_list_input.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/services/cms/cms_mobile_survey_service.dart';
import 'package:xstream_gate_pass_app/ui/views/cms/surveys/list/cms_surveys_list_viewmodel.dart';

import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  group('CmsSurveysListViewModel -', () {
    late MockCmsMobileSurveyService cmsMobileSurveyService;

    setUp(() {
      registerServices();
      cmsMobileSurveyService = locator<CmsMobileSurveyService>() as MockCmsMobileSurveyService;
      when(cmsMobileSurveyService.getList(any)).thenAnswer((invocation) async {
        final input = invocation.positionalArguments.single as CmsMobileSurveyListInput;
        return PagedList<CmsMobileSurveyListDto>(
          totalCount: 1,
          items: [
            CmsMobileSurveyListDto(
              id: 88,
              surveyType: input.surveyType ?? CmsSurveyType.container,
              containerNo: 'MSCU1234567',
              clientName: 'ACME',
              conductedBy: 'Inspector One',
            ),
          ],
          pageNumber: input.pageNumber,
          pageSize: input.pageSize,
          totalPages: 1,
        );
      });
    });

    tearDown(() => locator.reset());

    test('debounces search refresh before loading the next filtered page', () async {
      final model = CmsSurveysListViewModel();
      await model.runStartupLogic();
      expect(model.pagingController.itemList, isNotNull);
      clearInteractions(cmsMobileSurveyService);

      model.searchController.text = 'MSCU';
      model.onSearchTextChanged('MSCU');

      await Future<void>.delayed(const Duration(milliseconds: 200));
      expect(model.pagingController.itemList, isNotNull);

      await Future<void>.delayed(const Duration(milliseconds: 180));
      expect(model.pagingController.itemList, isNull);

      await model.fetchPage(1);

      final captured = verify(cmsMobileSurveyService.getList(captureAny)).captured.single as CmsMobileSurveyListInput;
      expect(captured.searchText, 'MSCU');
      expect(model.listContextSummary, contains('Search: MSCU'));
    });

    test('applies the survey type filter when loading pages', () async {
      final model = CmsSurveysListViewModel();
      await model.runStartupLogic();
      clearInteractions(cmsMobileSurveyService);

      model.selectSurveyType(CmsSurveyType.gatePass);
      expect(model.pagingController.itemList, isNull);

      await model.fetchPage(1);

      final captured = verify(cmsMobileSurveyService.getList(captureAny)).captured.single as CmsMobileSurveyListInput;
      expect(captured.surveyType, CmsSurveyType.gatePass);
      expect(model.activeFilterCount, 1);
      expect(model.listContextSummary, contains(CmsSurveyType.gatePass.displayName));
    });
  });
}
