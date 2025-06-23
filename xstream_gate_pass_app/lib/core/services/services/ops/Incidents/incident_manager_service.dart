import 'package:sembast/timestamp.dart';
import 'package:stacked/stacked_annotations.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/app_const.dart';

import 'package:xstream_gate_pass_app/core/models/ops/incidents/incident_model.dart';
import 'package:xstream_gate_pass_app/core/models/shared/api_response.dart';
import 'package:xstream_gate_pass_app/core/services/api/api_manager.dart';

@LazySingleton()
class IncidentManagerService {
  final log = getLogger('IncidentManagerService');
  final ApiManager _apiManager = locator<ApiManager>();

  final _dialogService = locator<DialogService>();

  Future<Incident?> createIncident(dynamic entity) async {
    var baseResponse = await _apiManager.post(AppConst.CreateIncident,
        showLoader: false, data: entity);
    if (baseResponse != null) {
      var apiResponse = ApiResponse.fromJson(baseResponse);
      if (apiResponse.success != null) {
        return Incident.fromJson(apiResponse.result);
      }
    }
    return null;
  }
}
