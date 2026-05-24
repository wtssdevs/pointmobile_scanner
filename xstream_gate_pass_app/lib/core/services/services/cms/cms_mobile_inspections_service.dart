import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_response_envelope.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_complete_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_filter.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_repair_date_input.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';

@LazySingleton()
class CmsMobileInspectionsService {
  CmsMobileInspectionsService([CmsApiManager? apiManager])
      : _apiManager = apiManager ?? locator<CmsApiManager>();

  final CmsApiManager _apiManager;

  Future<PagedList<CmsInspectableContainer>> getInspectableContainers(
    CmsInspectionFilter filter,
  ) async {
    final response = await _apiManager.post(
      AppConst.CmsGetInspectableContainers,
      data: filter.toJson(),
      showLoader: false,
    );

    final payload = CmsResponseEnvelope.unwrapPaged(response);
    final items = cmsParseMapList(payload['items'])
        .map(CmsInspectableContainer.fromJson)
        .toList(growable: false);
    final totalCount = cmsParseInt(payload['totalCount']) ?? items.length;
    final totalPages = filter.pageSize <= 0
        ? 0
        : ((totalCount + filter.pageSize - 1) ~/ filter.pageSize);

    return PagedList<CmsInspectableContainer>(
      totalCount: totalCount,
      items: items,
      pageNumber: filter.pageNumber,
      pageSize: filter.pageSize,
      totalPages: totalPages,
    );
  }

  Future<CmsInspectionEdit> startInspection(
      CmsStartInspectionInput input) async {
    return _postForEdit(
      AppConst.CmsStartInspectionForContainer,
      data: input.toJson(),
    );
  }

  Future<CmsInspectionEdit> getInspectionForEdit(int inspectionId) async {
    return _postForEdit(
      AppConst.CmsGetInspectionForEdit,
      data: {'id': inspectionId},
      showLoader: false,
    );
  }

  Future<CmsInspectionEdit> saveInspection(CmsInspectionEdit input) async {
    return _postForEdit(
      AppConst.CmsSaveInspection,
      data: input.toJson(),
    );
  }

  Future<CmsInspectionEdit> completeInspection(
    CmsCompleteInspectionInput input,
  ) async {
    return _postForEdit(
      AppConst.CmsCompleteInspection,
      data: input.toJson(),
    );
  }

  Future<CmsInspectionEdit> setRepairDatesNow(CmsRepairDateInput input) async {
    return _postForEdit(
      AppConst.CmsSetInspectionRepairDatesNow,
      data: input.toJson(),
    );
  }

  Future<CmsInspectionEdit> _postForEdit(
    String endpoint, {
    required Map<String, dynamic> data,
    bool showLoader = true,
  }) async {
    final response = await _apiManager.post(
      endpoint,
      data: data,
      showLoader: showLoader,
    );

    final payload = CmsResponseEnvelope.unwrapMap(response);
    return CmsInspectionEdit.fromJson(payload);
  }
}
