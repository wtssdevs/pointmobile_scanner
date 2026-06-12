import 'package:xstream_gate_pass_app/core/models/cms/cms_json_utils.dart';

/// Mirrors the CMS backend `InspectionState` lifecycle enum.
enum CmsInspectionState {
  pending(0, 'Pending'),
  inProgress(1, 'In progress'),
  complete(2, 'Completed'),
  cancelled(3, 'Cancelled');

  const CmsInspectionState(this.value, this.label);

  final int value;
  final String label;

  bool get isCancelled => this == CmsInspectionState.cancelled;

  /// Resolves a state from an int value (0-3) or a backend name (case-insensitive).
  static CmsInspectionState? fromValue(dynamic value) {
    final parsedInt = cmsParseInt(value);
    if (parsedInt != null) {
      for (final state in CmsInspectionState.values) {
        if (state.value == parsedInt) {
          return state;
        }
      }
      return null;
    }

    final parsedName = cmsParseString(value)?.trim().toLowerCase().replaceAll(' ', '');
    if (parsedName == null || parsedName.isEmpty) {
      return null;
    }

    switch (parsedName) {
      case 'pending':
        return CmsInspectionState.pending;
      case 'inprogress':
        return CmsInspectionState.inProgress;
      case 'complete':
      case 'completed':
        return CmsInspectionState.complete;
      case 'cancelled':
      case 'canceled':
        return CmsInspectionState.cancelled;
      default:
        return null;
    }
  }
}
