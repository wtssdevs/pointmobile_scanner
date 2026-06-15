import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_inspection_state.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_container_inspection_bundle.dart';
import 'package:xstream_gate_pass_app/core/models/cms/cms_response_envelope.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspectable_container.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_edit.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_filter.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_inspection_history_row.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_repair_date_input.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_input.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_start_inspection_result.dart';
import 'package:xstream_gate_pass_app/core/models/shared/list_page.dart';
import 'package:xstream_gate_pass_app/core/services/api/cms_api_manager.dart';

@LazySingleton()
class CmsMobileInspectionsService {
  CmsMobileInspectionsService([CmsApiManager? apiManager]) : _apiManager = apiManager ?? locator<CmsApiManager>();

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
    final items = cmsParseMapList(payload['items']).map(CmsInspectableContainer.fromJson).toList(growable: false);
    final totalCount = cmsParseInt(payload['totalCount']) ?? items.length;
    final totalPages = filter.pageSize <= 0 ? 0 : ((totalCount + filter.pageSize - 1) ~/ filter.pageSize);

    return PagedList<CmsInspectableContainer>(
      totalCount: totalCount,
      items: items,
      pageNumber: filter.pageNumber,
      pageSize: filter.pageSize,
      totalPages: totalPages,
    );
  }

  Future<CmsContainerInspectionBundle> getContainerInspections(
    int containerId,
  ) async {
    final response = await _apiManager.post(
      AppConst.CmsGetContainerInspectionBundle,
      data: {'id': containerId},
      showLoader: false,
    );

    final payload = CmsResponseEnvelope.unwrapMap(response);
    return CmsContainerInspectionBundle.fromJson(payload);
  }

  Future<PagedList<CmsInspectionHistoryRow>> getContainerInspectionHistory({
    required int containerId,
    required int pageNumber,
    int pageSize = 20,
  }) async {
    final response = await _apiManager.post(
      AppConst.CmsGetContainerInspectionHistory,
      data: {
        'containerId': containerId,
        'pageNumber': pageNumber,
        'pageSize': pageSize,
      },
      showLoader: false,
    );

    final payload = CmsResponseEnvelope.unwrapPaged(response);
    final items = cmsParseMapList(payload['items']).map(CmsInspectionHistoryRow.fromJson).toList(growable: false);
    final totalCount = cmsParseInt(payload['totalCount']) ?? items.length;
    final totalPages = pageSize <= 0 ? 0 : ((totalCount + pageSize - 1) ~/ pageSize);

    return PagedList<CmsInspectionHistoryRow>(
      totalCount: totalCount,
      items: items,
      pageNumber: pageNumber,
      pageSize: pageSize,
      totalPages: totalPages,
    );
  }

  Future<CmsStartInspectionResult> startInspection(
    CmsStartInspectionInput input,
  ) async {
    final response = await _apiManager.post(
      AppConst.CmsStartInspectionForContainer,
      data: input.toJson(),
    );

    final payload = CmsResponseEnvelope.unwrapMap(response);
    return CmsStartInspectionResult.fromJson(payload);
  }

  Future<CmsInspectionState> cancelInspection(int inspectionId) async {
    final response = await _apiManager.post(
      AppConst.CmsCancelInspection,
      data: {'id': inspectionId},
    );

    final payload = CmsResponseEnvelope.unwrapMap(response);
    return CmsInspectionState.fromValue(payload['state']) ?? CmsInspectionState.cancelled;
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
