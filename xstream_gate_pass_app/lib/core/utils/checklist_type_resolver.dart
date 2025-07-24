import 'package:xstream_gate_pass_app/core/enums/dialog_type.dart';
import 'package:xstream_gate_pass_app/core/enums/gate_pass_status.dart';

class ChecklistTypeResolver {
  static const entryStatuses = {
    GatePassStatus.pending,
    GatePassStatus.atGate,
    GatePassStatus.rejectedEntry,
  };

  static const exitStatuses = {
    GatePassStatus.inYard,
    GatePassStatus.leftTheYard,
  };

  static (ChecklistType checklistType, DeliveryType deliveryType) resolve(GatePassStatus? status) {
    if (status == null) {
      return (ChecklistType.none, DeliveryType.other);
    }

    if (entryStatuses.contains(status)) {
      return (ChecklistType.gatePassAccessEntry, DeliveryType.receive);
    } else if (exitStatuses.contains(status)) {
      return (ChecklistType.gatePassAccessExit, DeliveryType.dispatch);
    }

    return (ChecklistType.gatePassAccess, DeliveryType.other);
  }
}
