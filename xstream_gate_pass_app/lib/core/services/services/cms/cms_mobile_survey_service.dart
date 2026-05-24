import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_response_envelope.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_edit_dto.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_email_dto.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_list_dto.dart';
import 'package:xstream_gate_pass_app/core/models/cms/survey/cms_mobile_survey_list_input.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';

@LazySingleton()
class CmsMobileSurveyService {
  CmsMobileSurveyService([CmsApiManager? apiManager]) : _apiManager = apiManager ?? locator<CmsApiManager>();

  final CmsApiManager _apiManager;

  Future<PagedList<CmsMobileSurveyListDto>> getList(
    CmsMobileSurveyListInput input,
  ) async {
    final response = await _apiManager.post(
      AppConst.CmsMobileSurveyGetList,
      data: input.toJson(),
      showLoader: false,
    );

    final payload = CmsResponseEnvelope.unwrapPaged(response);
    final items = cmsParseMapList(payload['items']).map(CmsMobileSurveyListDto.fromJson).toList(growable: false);
    final totalCount = cmsParseInt(payload['totalCount']) ?? items.length;
    final totalPages = input.pageSize <= 0 ? 0 : ((totalCount + input.pageSize - 1) ~/ input.pageSize);

    return PagedList<CmsMobileSurveyListDto>(
      totalCount: totalCount,
      items: items,
      pageNumber: input.pageNumber,
      pageSize: input.pageSize,
      totalPages: totalPages,
    );
  }

  Future<CmsMobileSurveyEditDto> getById(int surveyId) async {
    final response = await _apiManager.post(
      AppConst.CmsMobileSurveyGetById,
      data: {'id': surveyId},
      showLoader: false,
    );

    return CmsMobileSurveyEditDto.fromJson(
      CmsResponseEnvelope.unwrapMap(response),
    );
  }

  Future<CmsMobileSurveyEditDto> addUpdate(
    CmsMobileSurveyEditDto input,
  ) async {
    final response = await _apiManager.post(
      AppConst.CmsMobileSurveyAddUpdate,
      data: input.toJson(),
    );

    return CmsMobileSurveyEditDto.fromJson(
      CmsResponseEnvelope.unwrapMap(response),
    );
  }

  Future<List<String>> getEmailAddresses(int surveyId) async {
    final response = await _apiManager.post(
      AppConst.CmsMobileSurveyGetEmailAddresses,
      data: {'id': surveyId},
      showLoader: false,
    );

    return _unwrapStringList(response);
  }

  Future<void> sendEmail(CmsMobileSurveyEmailDto input) async {
    await _apiManager.post(
      AppConst.CmsMobileSurveySendEmail,
      data: input.toJson(),
    );
  }

  Future<String> downloadReport({
    required int surveyId,
    required CmsSurveyType surveyType,
    required int referenceId,
    Directory? targetDirectory,
  }) async {
    final bytes = await _apiManager.getBytes(
      surveyType == CmsSurveyType.gatePass ? AppConst.cmsGatePassSurveyReport(referenceId) : AppConst.cmsSurveyReport(referenceId),
      showLoader: false,
    );
    if (bytes.isEmpty) {
      throw StateError('Survey report download returned no data.');
    }

    final directory = targetDirectory ?? await getTemporaryDirectory();
    await directory.create(recursive: true);
    final file = File(path.join(directory.path, 'survey-$surveyId-${surveyType.name}.pdf'));
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  List<String> _unwrapStringList(dynamic response) {
    if (response is List) {
      return response.map((item) => item.toString()).toList(growable: false);
    }

    final root = cmsParseMap(response);
    if (root == null) {
      return const [];
    }

    final result = root['result'];
    if (result is List) {
      return result.map((item) => item.toString()).toList(growable: false);
    }

    final resultMap = cmsParseMap(result);
    if (resultMap != null && resultMap['items'] is List) {
      return (resultMap['items'] as List).map((item) => item.toString()).toList(growable: false);
    }

    final items = root['items'];
    if (items is List) {
      return items.map((item) => item.toString()).toList(growable: false);
    }

    return const [];
  }
}
