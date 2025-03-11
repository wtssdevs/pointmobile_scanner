import 'package:stacked/stacked.dart';

abstract class BaseFormViewModel extends BaseViewModel {
  bool _showValidation = false;
  bool get showValidation => _showValidation;

  List<String> _validationMessages = [];
  List<String> get validationMessages => _validationMessages;

  /// Stores the mapping of the form key to the value entered by the user
  Map<String, dynamic> formValueMap = Map<String, dynamic>();

  void clearAllValidationMessage() {
    _validationMessages.clear();
    _showValidation = _validationMessages.isNotEmpty;
  }

  void setValidationMessage(String value) {
    var hasMsg = _validationMessages.any((e) => e == value);
    if (hasMsg == false) {
      _validationMessages.add(value);
    }

    _showValidation = _validationMessages.isNotEmpty;
  }

  void clearValidationMessage(String? value) {
    if (value == null) {
      _validationMessages.clear();
      _showValidation = false;
    } else {
      _validationMessages.remove(value);
    }

    _showValidation = _validationMessages.isNotEmpty;
  }

  // void setData(Map<String, dynamic> data) {
  //   // Save the data from the controllers
  //   formValueMap = data;

  //   // Reset the form status
  //   setValidationMessage(null);

  //   // Set the new form status
  //   setFormStatus();

  //   // Rebuild the UI
  //   notifyListeners();
  // }

  // /// Called after the [formValueMap] has been updated and allows you to set
  // /// values relating to the forms status.
  // void setFormStatus();
}
