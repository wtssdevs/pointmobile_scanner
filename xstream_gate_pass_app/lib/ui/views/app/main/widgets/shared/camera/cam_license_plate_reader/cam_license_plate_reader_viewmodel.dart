import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/core/utils/mlkit_utils.dart';

class CamLicensePlateReaderViewModel extends BaseViewModel {
  final _navigationService = locator<NavigationService>();
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  void close([String? result]) => _navigationService.back(result: result);
  bool _canProcess = true;
  bool _isBusy = false;
  String _lastCandidate = '';
  int _candidateReads = 0;

  Future<String?> processImage(AnalysisImage analysisImage) async {
    if (!_canProcess || _isBusy) return null;
    _isBusy = true;
    try {
      final recognizedText =
          await _textRecognizer.processImage(analysisImage.toInputImage());
      final candidate = _extractPlate(recognizedText.text);
      if (candidate == null) {
        _lastCandidate = '';
        _candidateReads = 0;
        return null;
      }

      if (candidate == _lastCandidate) {
        _candidateReads++;
      } else {
        _lastCandidate = candidate;
        _candidateReads = 1;
      }

      return _candidateReads >= 2 ? candidate : null;
    } finally {
      _isBusy = false;
    }
  }

  String? _extractPlate(String text) {
    final tokens = text
        .toUpperCase()
        .split(RegExp(r'\s+'))
        .map((token) => token.replaceAll(RegExp(r'[^A-Z0-9]'), ''))
        .where((token) => token.isNotEmpty)
        .toList();
    final candidates = <String>{};

    for (var index = 0; index < tokens.length; index++) {
      var candidate = '';
      for (var end = index; end < tokens.length && end < index + 3; end++) {
        candidate += tokens[end];
        if (_isRegistrationCandidate(candidate)) {
          candidates.add(candidate);
        }
      }
    }

    if (candidates.isEmpty) return null;
    final sortedCandidates = candidates.toList()
      ..sort((a, b) => _plateScore(b).compareTo(_plateScore(a)));
    return sortedCandidates.first;
  }

  bool _isRegistrationCandidate(String value) {
    if (value.length < 5 || value.length > 10) return false;
    return RegExp(r'^[A-Z]{2,3}[0-9]{3}[A-Z]{0,2}$').hasMatch(value) ||
        RegExp(r'^[A-Z]{2}[0-9]{3}[0-9]{3}$').hasMatch(value) ||
        RegExp(r'^[0-9]{4,5}[A-Z]{2}$').hasMatch(value) ||
        RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{2}[A-Z]{2}$').hasMatch(value);
  }

  int _plateScore(String value) {
    final letters = RegExp(r'[A-Z]').allMatches(value).length;
    final digits = RegExp(r'[0-9]').allMatches(value).length;
    return (value.length * 10) + (letters > 0 && digits > 0 ? 20 : 0);
  }

  @override
  void dispose() {
    _canProcess = false;
    _textRecognizer.close();
    super.dispose();
  }
}
