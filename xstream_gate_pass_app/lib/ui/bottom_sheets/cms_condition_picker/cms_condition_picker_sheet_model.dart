import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/core/models/cms/inspection/cms_condition_type.dart';

class CmsConditionPickerSheetModel extends BaseViewModel {
  List<CmsConditionType> _allConditions = const <CmsConditionType>[];
  int? _selectedConditionId;
  String _searchTerm = '';

  void initialise(List<CmsConditionType> conditions, int? selectedConditionId) {
    _allConditions = conditions;
    _selectedConditionId = selectedConditionId;
  }

  int? get selectedConditionId => _selectedConditionId;

  List<CmsConditionType> get visibleConditions {
    final term = _searchTerm.trim().toLowerCase();
    if (term.isEmpty) {
      return _allConditions;
    }

    return _allConditions.where((condition) {
      final code = (condition.code ?? '').toLowerCase();
      final name = condition.displayName.toLowerCase();
      return code.contains(term) || name.contains(term);
    }).toList(growable: false);
  }

  void search(String value) {
    _searchTerm = value;
    rebuildUi();
  }
}
