import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';

class CmsMobileSurveyListInput {
  const CmsMobileSurveyListInput({
    this.pageNumber = 1,
    this.pageSize = 25,
    this.searchText,
    this.surveyType,
    this.fromDateUtc,
    this.toDateUtc,
  });

  final int pageNumber;
  final int pageSize;
  final String? searchText;
  final CmsSurveyType? surveyType;
  final DateTime? fromDateUtc;
  final DateTime? toDateUtc;

  int get skipCount => (pageNumber - 1) * pageSize;

  Map<String, dynamic> toJson() {
    return {
      'skipCount': skipCount < 0 ? 0 : skipCount,
      'maxResultCount': pageSize,
      'searchText': searchText,
      'surveyType': surveyType?.value,
      'fromDateUtc': fromDateUtc?.toUtc().toIso8601String(),
      'toDateUtc': toDateUtc?.toUtc().toIso8601String(),
    };
  }
}
