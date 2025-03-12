import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:dart_helper_utils/dart_helper_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:stacked/stacked.dart';
import 'package:xstream_gate_pass_app/app/app.locator.dart';
import 'package:xstream_gate_pass_app/app/app.logger.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/containers/container_info_extratced_model.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/containers/container_iso_types_model.dart';
import 'package:xstream_gate_pass_app/core/utils/mlkit_utils.dart';
import 'package:xstream_gate_pass_app/services/iso_type_service.dart';
import 'dart:math' as math;

// Helper classes for storing potential matches
class _PotentialContainer {
  final String containerNumber;
  final int position;

  _PotentialContainer({required this.containerNumber, required this.position});
}

class _PotentialIsoType {
  final String isoType;
  final int position;

  _PotentialIsoType({required this.isoType, required this.position});
}

class CamContainernoReaderViewModel extends BaseViewModel {
  final log = getLogger('CamContainernoReaderViewModel');
  final _isoTypeService = locator<IsoTypeService>();

  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  bool _canProcess = true;
  bool _isBusy = false;
  CustomPaint? _customPaint;
  String? _text;
  List<ContainerInfo> _containerInfos = [];

  // Add ISO type reference data
  List<IsoType> get _isoTypes => _isoTypeService.getAllIsoTypes;
  // Get valid ISO codes for validation
  Set<String> get _validIsoCodes => _isoTypeService.getAllCodes();
  List<String> get _isoCodes => _isoTypeService.getAllIsoTypes.map((e) => e.code).toList();

  // Load ISO type data from the JSON file
  // Load ISO types from JSON file

  void dispose() async {
    _canProcess = false;
    _textRecognizer.close();
  }

  Future<ContainerInfo?> extractContainerNo(String text) async {
    // Early return if text is too short
    if (text.isEmpty || text.length < 10) return null;

    // Clean and normalize the text
    final cleanText = text.toUpperCase().replaceAll('\n', ' ').replaceAll('\r', ' ').replaceAll(',', ' ').replaceAll('.', ' ').replaceAll('/', ' ').trim();

    log.i("Cleaned text: $cleanText");

    // Split into tokens and clean up any empty tokens
    List<String> tokens = cleanText.split(' ').where((token) => token.isNotEmpty).toList();

    // First pass: Find potential container numbers and ISO types
    List<_PotentialContainer> containerCandidates = [];
    List<_PotentialIsoType> isoCandidates = [];

    for (int i = 0; i < tokens.length; i++) {
      // Check for potential container prefix (4 letters)
      if (i < tokens.length - 1 && _isAlphaString(tokens[i]) && tokens[i].length == 4) {
        // Check if next token(s) could be the numeric part
        String potentialPrefix = tokens[i];
        String numericPart = "";
        int checkDigit = -1;

        // Try to find the numeric part in subsequent tokens
        for (int j = i + 1; j < tokens.length && j < i + 3; j++) {
          if (_isNumericString(tokens[j])) {
            if (tokens[j].length == 7) {
              // Complete numeric part
              numericPart = tokens[j];
              checkDigit = int.tryParse(numericPart[6]) ?? -1;
              break;
            } else if (tokens[j].length == 6) {
              // Numeric part without check digit, look ahead for check digit
              numericPart = tokens[j];
              if (j + 1 < tokens.length && tokens[j + 1].length == 1 && _isNumericString(tokens[j + 1])) {
                checkDigit = int.tryParse(tokens[j + 1]) ?? -1;
              }
              break;
            } else if (tokens[j].length == 5 && j + 1 < tokens.length) {
              // Potential 5+1 pattern
              numericPart = tokens[j];
              if (tokens[j + 1].length == 1 && _isNumericString(tokens[j + 1])) {
                checkDigit = int.tryParse(tokens[j + 1]) ?? -1;
                // Add a '1' to make it 6 digits (for SEGU case)
                numericPart = "1" + numericPart;
              }
              break;
            }
          }
        }

        // If we found a potential container number, validate and add to candidates
        if (numericPart.isNotEmpty) {
          String containerNumber;
          if (numericPart.length == 7) {
            containerNumber = potentialPrefix + numericPart;
          } else if (numericPart.length == 6 && checkDigit != -1) {
            containerNumber = potentialPrefix + numericPart + checkDigit.toString();
          } else if (numericPart.length == 6) {
            // Calculate check digit
            containerNumber = potentialPrefix + numericPart;
            int calculatedCheckDigit = _isoTypeService.iso6346CheckDigit(containerNumber);
            containerNumber = containerNumber + calculatedCheckDigit.toString();
          } else {
            continue; // Invalid format
          }

          // Simple validation to avoid noise
          if (_isValidContainerNumber(containerNumber)) {
            containerCandidates.add(_PotentialContainer(containerNumber: containerNumber, position: i));
          }
        }
      }

      // Check for potential ISO types (4 chars starting with 2 or 4)
      if (tokens[i].length == 4 && (tokens[i].startsWith('2') || tokens[i].startsWith('4')) && _isAlphanumericString(tokens[i])) {
        String potentialIsoType = tokens[i];
        if (_validIsoCodes.contains(potentialIsoType)) {
          isoCandidates.add(_PotentialIsoType(isoType: potentialIsoType, position: i));
        }
      }
    }

    // Second pass: Match container numbers with ISO types based on proximity
    if (containerCandidates.isEmpty) {
      return null; // No container numbers found
    }

    // Sort container candidates by validity (check digit validation)
    containerCandidates.sort((a, b) {
      bool aValid = _isValidCheckDigit(a.containerNumber);
      bool bValid = _isValidCheckDigit(b.containerNumber);
      if (aValid && !bValid) return -1;
      if (!aValid && bValid) return 1;
      return 0;
    });

    // For each container candidate, find the closest ISO type
    for (var container in containerCandidates) {
      String? closestIsoType;
      int minDistance = tokens.length;

      for (var iso in isoCandidates) {
        int distance = (container.position - iso.position).abs();
        if (distance < minDistance) {
          minDistance = distance;
          closestIsoType = iso.isoType;
        }
      }

      // Return the first valid container with an ISO type if possible
      if (closestIsoType != null) {
        return ContainerInfo(
          containerNumber: container.containerNumber,
          isoType: closestIsoType,
        );
      }
    }

    // If we have a container but no ISO type
    if (containerCandidates.isNotEmpty) {
      return ContainerInfo(
        containerNumber: containerCandidates[0].containerNumber,
        isoType: '',
      );
    }

    return null;
  }

  // Helper methods to check string types
  bool _isAlphaString(String s) {
    return RegExp(r'^[A-Z]+$').hasMatch(s);
  }

  bool _isNumericString(String s) {
    return RegExp(r'^[0-9]+$').hasMatch(s);
  }

  bool _isAlphanumericString(String s) {
    return RegExp(r'^[A-Z0-9]+$').hasMatch(s);
  }

  // Basic validation for container numbers
  bool _isValidContainerNumber(String containerNumber) {
    // Check length
    if (containerNumber.length != 11) return false;

    // Check format (4 letters followed by 7 digits)
    if (!RegExp(r'^[A-Z]{4}[0-9]{7}$').hasMatch(containerNumber)) return false;

    // Check digit validation
    return _isValidCheckDigit(containerNumber);
  }

  // Helper method to validate container number check digit
  bool _isValidCheckDigit(String containerNumber) {
    if (containerNumber.length != 11) return false;

    final prefix = containerNumber.substring(0, 10);
    final providedCheckDigit = int.tryParse(containerNumber[10]);
    if (providedCheckDigit == null) return false;

    final calculatedCheckDigit = _isoTypeService.iso6346CheckDigit(prefix);
    return providedCheckDigit == calculatedCheckDigit;
  }

// Method to process the image and extract container info
  Future<ContainerInfo?> processImageForContainer(AnalysisImage analysisImage) async {
    final recognizedText = await processImage(analysisImage);
    if (recognizedText == null || recognizedText.text.isEmpty) {
      _isBusy = false;
      return null;
    }

    var contInfo = await extractContainerNo(recognizedText.text);
    if (contInfo != null && contInfo.isoType.isNotEmpty) {
      // _canProcess = false;
      _containerInfos.add(contInfo);
      log.i("contInfo: ${contInfo.containerNumber} ${contInfo.isoType}");
      return contInfo;
      //_isBusy = true;
      //rebuildUi();
    }
    _isBusy = false;
    return null;
  }

  Future<RecognizedText?> processImage(AnalysisImage analysisImage) async {
    if (!_canProcess) return null;
    if (_isBusy) return null;
    _isBusy = true;

    final inputImage = analysisImage.toInputImage();
    final recognizedText = await _textRecognizer.processImage(inputImage);

    if (recognizedText.text.isNotEmpty) {
      if (recognizedText.text.length > 10) {
        _text = recognizedText.text;
      }
      return recognizedText;
    }

    _isBusy = false;

    return null;
  }

  void runStartupLogic() async {
    _canProcess = false;
    await _isoTypeService.initialize();
    _canProcess = true;
  }
}
