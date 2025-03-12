import 'package:stacked/stacked_annotations.dart';
import 'package:xstream_gate_pass_app/core/models/basefiles/containers/container_iso_types_model.dart';
import 'dart:math';

@LazySingleton()
class IsoTypeService {
  // Singleton pattern

  List<IsoType> _isoTypes = [];
  List<IsoType> get isoTypes => _isoTypes;
  Map<String, IsoType> _isoTypesByCode = {};
  Map<String, IsoType> isoTypesMap = {};
  Set<String> _allIsoCodes = {};

  var validator = ContainerValidator();
  // Initialize the service
  Future<void> initialize() async {
    await loadIsoTypes();
    _allIsoCodes = _isoTypesByCode.keys.toSet();
    //need to create dicronary from _isoTypeService.getAllIsoTypes

    isoTypesMap = _isoTypes.asMap().map((key, value) => MapEntry(value.code, value));
  }

  int iso6346CheckDigit(String csc) {
    // Check if length fits requirements.
    if (csc.length < 10 || csc.length > 11) return -1; //
    var isvalid = validator.isValid(csc);
    if (!isvalid) {
      return -1;
    }

    var validation = validator.validate(csc);

    return int.tryParse(validator.getCheckDigit() ?? "") ?? -1;
    // // Remove any non-alphanumeric characters and convert to upper-case.
    // csc = csc.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

    // // Calculate check digit.
    // int sum = 0;
    // for (int i = 0; i < 10; i++) {
    //   // Map letters to numbers.
    //   int n = csc.codeUnitAt(i);
    //   n -= n < 58 ? 48 : 55;

    //   // Numbers 11, 22, 33 are omitted.
    //   n += ((n - 1) ~/ 10).toInt();

    //   // Sum of all numbers multiplied by weighting.
    //   sum += n << i;
    // }

    // // Modulus of 11, and map 10 to 0.
    // return sum % 11 % 10;
  } // Load ISO types from JSON file

  Future<void> loadIsoTypes() async {
    try {
      List<IsoType> isoTypesList = [
        IsoType(code: "20G0", description: "General Purpose Container", size: "20", type: "GP"),
        IsoType(code: "20G1", description: "General Purpose Container", size: "20", type: "GP"),
        IsoType(code: "20H0", description: "Insulated Container", size: "20", type: "HR"),
        IsoType(code: "20P1", description: "Flat (Fixed Ends)", size: "20", type: "PF"),
        IsoType(code: "20T0", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20T1", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20T2", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20T3", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20T4", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20T5", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20T6", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20T7", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20T8", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20TG", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "20TN", description: "Tank Container", size: "20", type: "TD"),
        IsoType(code: "22B0", description: "Bulk Container", size: "22", type: "BU"),
        IsoType(code: "22G0", description: "General Purpose Container", size: "22", type: "GP"),
        IsoType(code: "22G1", description: "General Purpose Container", size: "22", type: "GP"),
        IsoType(code: "22H0", description: "Insulated Container", size: "22", type: "HR"),
        IsoType(code: "22P3", description: "Flat (Collapsible)", size: "22", type: "PC"),
        IsoType(code: "22P8", description: "Flat (Coll. Flush Folding)", size: "22", type: "PC"),
        IsoType(code: "22P9", description: "Flat (Collapsible)", size: "22", type: "PC"),
        IsoType(code: "22P1", description: "Flat (Fixed Ends)", size: "22", type: "PF"),
        IsoType(code: "22P7", description: "Flat (Genset Carrier)", size: "22", type: "PF"),
        IsoType(code: "22R9", description: "Reefer Container (No Food)", size: "22", type: "RC"),
        IsoType(code: "22R7", description: "Built-in Gen. for Power Supply of Reefer", size: "22", type: "RS"),
        IsoType(code: "22R1", description: "Reefer Container", size: "22", type: "RT"),
        IsoType(code: "22S1", description: "Named Cargo Container", size: "22", type: "SN"),
        IsoType(code: "22T0", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22T1", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22T2", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22T3", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22T4", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22T5", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22T6", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22T7", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22T8", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22TG", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22TN", description: "Tank Container", size: "22", type: "TD"),
        IsoType(code: "22U6", description: "Hardtop Container", size: "22", type: "UP"),
        IsoType(code: "22U1", description: "Open Top Container", size: "22", type: "UT"),
        IsoType(code: "22V0", description: "Ventilated Container", size: "22", type: "VH"),
        IsoType(code: "22V2", description: "Ventilated Container", size: "22", type: "VH"),
        IsoType(code: "22V3", description: "Ventilated Container", size: "22", type: "VH"),
        IsoType(code: "25G0", description: "GP-Container Over-Height", size: "25", type: "GP"),
        IsoType(code: "26G0", description: "GP-Container Over-Height", size: "26", type: "GP"),
        IsoType(code: "26H0", description: "Insulated Container", size: "26", type: "HR"),
        IsoType(code: "28T8", description: "Tank for Gas", size: "28", type: "TG"),
        IsoType(code: "28U1", description: "Open Top (Half Height)", size: "28", type: "UT"),
        IsoType(code: "28V0", description: "VE-Half-Height = 1448 mm Height", size: "28", type: "VH"),
        IsoType(code: "29P0", description: "Platform", size: "29", type: "PL"),
        IsoType(code: "2EG0", description: "High Cube Cont. (Width 2.5m)", size: "2E", type: "GP"),
        IsoType(code: "42G0", description: "General Purpose Container", size: "42", type: "GP"),
        IsoType(code: "42G1", description: "General Purpose Container", size: "42", type: "GP"),
        IsoType(code: "42H0", description: "Insulated Container", size: "42", type: "HR"),
        IsoType(code: "42P3", description: "Flat (Collapsible)", size: "42", type: "PC"),
        IsoType(code: "42P8", description: "Flat (Coll. Flush Folding)", size: "42", type: "PC"),
        IsoType(code: "42P9", description: "Flat (Collapsible)", size: "42", type: "PC"),
        IsoType(code: "42P1", description: "Flat (Fixed Ends)", size: "42", type: "PF"),
        IsoType(code: "42P6", description: "Flat Space Saver", size: "42", type: "PS"),
        IsoType(code: "42R9", description: "Reefer Container (No Food)", size: "42", type: "RC"),
        IsoType(code: "42R3", description: "Reefer Cont. (Diesel Gen.)", size: "42", type: "RS"),
        IsoType(code: "42R1", description: "Reefer Container", size: "42", type: "RT"),
        IsoType(code: "42S1", description: "Named Cargo Container", size: "42", type: "SN"),
        IsoType(code: "42T2", description: "Tank Container", size: "42", type: "TD"),
        IsoType(code: "42T5", description: "Tank Container", size: "42", type: "TD"),
        IsoType(code: "42T6", description: "Tank Container", size: "42", type: "TD"),
        IsoType(code: "42T8", description: "Tank Container", size: "42", type: "TD"),
        IsoType(code: "42TG", description: "Tank Container", size: "42", type: "TD"),
        IsoType(code: "42TN", description: "Tank Container", size: "42", type: "TD"),
        IsoType(code: "42U6", description: "Hardtop Container", size: "42", type: "UP"),
        IsoType(code: "42U1", description: "Open Top Container", size: "42", type: "UT"),
        IsoType(code: "45B3", description: "Bulk Container", size: "45", type: "BK"),
        IsoType(code: "45G0", description: "High Cube Container", size: "45", type: "GP"),
        IsoType(code: "45G1", description: "High Cube Cont.", size: "45", type: "GP"),
        IsoType(code: "45P3", description: "Flat (Collapsible)", size: "45", type: "PC"),
        IsoType(code: "45P8", description: "Flat (Coll. Flush Folding)", size: "45", type: "PC"),
        IsoType(code: "45R9", description: "Reefer Container (No Food)", size: "45", type: "RC"),
        IsoType(code: "45R1", description: "Reefer High Cube Container", size: "45", type: "RT"),
        IsoType(code: "45U1", description: "Open Top Container", size: "45", type: "UT"),
        IsoType(code: "45U6", description: "High Cube Hardtop Cont.", size: "45", type: "UP"),
        IsoType(code: "46H0", description: "Insulated Container", size: "46", type: "HR"),
        IsoType(code: "48T8", description: "Tank for Gas", size: "48", type: "TG"),
        IsoType(code: "49P0", description: "Platform", size: "49", type: "PL"),
        IsoType(code: "4CG0", description: "GP Container (Width 2.5 m)", size: "4C", type: "GP"),
        IsoType(code: "L0G1", description: "High Cube Cont.", size: "L0", type: "GP"),
        IsoType(code: "L2G1", description: "High Cube Cont.", size: "L2", type: "GP"),
        IsoType(code: "L5G1", description: "High Cube Cont.", size: "L5", type: "GP"),
      ];
      _isoTypes = isoTypesList;
      // Create a map for quick lookups by code
      //_isoTypesByCode = {for (var isoType in _isoTypes) isoType.code: isoType};
    } catch (e) {
      print('Error loading ISO types: $e');
    }
  }

  // Get all ISO types
  List<IsoType> get getAllIsoTypes => _isoTypes;

  // Find ISO type by code
  IsoType? findByCode(String code) {
    return _isoTypesByCode[code];
  }

  // Get description for a code
  String? getDescriptionForCode(String code) {
    return _isoTypesByCode[code]?.description;
  }

  // Find ISO types by size
  List<IsoType> findBySize(String size) {
    return _isoTypes.where((isoType) => isoType.size == size).toList();
  }

  // Find ISO types by type
  List<IsoType> findByType(String type) {
    return _isoTypes.where((isoType) => isoType.type == type).toList();
  }

  // Get all ISO codes as a set for validation
  Set<String> getAllCodes() {
    return _allIsoCodes;
  }
}

class ContainerValidator {
  final Map<String, int> alphabetNumerical = {
    'A': 10,
    'B': 12,
    'C': 13,
    'D': 14,
    'E': 15,
    'F': 16,
    'G': 17,
    'H': 18,
    'I': 19,
    'J': 20,
    'K': 21,
    'L': 23,
    'M': 24,
    'N': 25,
    'O': 26,
    'P': 27,
    'Q': 28,
    'R': 29,
    'S': 30,
    'T': 31,
    'U': 32,
    'V': 34,
    'W': 35,
    'X': 36,
    'Y': 37,
    'Z': 38,
  };

  final RegExp pattern = RegExp(r'^([A-Z]{3})([A-Z])(\d{6})(\d)$');

  final RegExp patternWithoutCheckDigit = RegExp(r'^([A-Z]{3})(U|J|Z)(\d{6})$');

  List<String> errorMessages = [];
  List<String> ownerCode = [];
  String? productGroupCode;
  List<String> registrationDigit = [];
  String? checkDigit;
  String? containerNumber;

  bool isValid(String containerNumber) {
    validate(containerNumber);
    return errorMessages.isEmpty;
  }

  List<String>? validate(String containerNumber) {
    List<String>? matches;

    if (containerNumber.isNotEmpty && containerNumber is String) {
      matches = identify(containerNumber);

      if (matches == null || matches.length != 5) {
        errorMessages.add('The container number is invalid');
      } else {
        String calculatedCheckDigit = buildCheckDigit(matches);

        if (checkDigit != calculatedCheckDigit) {
          errorMessages.add('The check digit does not match');
          matches = null;
        }
      }
    } else {
      errorMessages = ['The container number must be a string'];
    }
    return matches;
  }

  List<String> getErrorMessages() {
    return errorMessages;
  }

  List<String> getOwnerCode() {
    if (ownerCode.isEmpty) {
      errorMessages.add('You must call validate or isValid first');
    }
    return ownerCode;
  }

  String? getProductGroupCode() {
    if (productGroupCode == null) {
      errorMessages.add('You must call validate or isValid first');
    }
    return productGroupCode;
  }

  List<String> getRegistrationDigit() {
    if (registrationDigit.isEmpty) {
      errorMessages.add('You must call validate or isValid first');
    }
    return registrationDigit;
  }

  String? getCheckDigit() {
    if (checkDigit == null) {
      errorMessages.add('You must call validate or isValid first');
    }
    return checkDigit;
  }

  List<String> generate(String ownerCode, String productGroupCode, [int from = 0, int to = 999999]) {
    String alphabetCode = (ownerCode + productGroupCode).toUpperCase();
    List<String> containersNo = [];

    if (ownerCode.length == 3 && productGroupCode.length == 1) {
      if (from >= 0 && to < 1000000 && (to - from) > 0) {
        for (int i = from; i <= to; i++) {
          String currentContainerNo = alphabetCode + i.toString().padLeft(6, '0');
          String currentContainerCheckDigit = createCheckDigit(currentContainerNo);

          if (currentContainerCheckDigit == "-1") {
            errorMessages.add('Error generating container number at number $i');
            return containersNo;
          }

          containersNo.add(currentContainerNo + currentContainerCheckDigit);
        }
      } else {
        errorMessages.add('Invalid number to generate, minimal is 0 and maximal is 999999');
      }
    } else {
      errorMessages.add('Invalid owner code or product group code');
    }

    return containersNo;
  }

  String createCheckDigit(String containerNumber) {
    String checkDigit = "-1";
    if (containerNumber.isNotEmpty && containerNumber is String) {
      List<String>? matches = identify(containerNumber, true);

      if (matches == null || matches.length != 4) {
        errorMessages.add('Invalid container number');
      } else {
        checkDigit = buildCheckDigit(matches);
        if (checkDigit == "-1") {
          errorMessages.add('Invalid container number');
        }
      }
    } else {
      errorMessages.add('Container number must be a string');
    }
    return checkDigit;
  }

  void clearErrors() {
    errorMessages.clear();
  }

  String buildCheckDigit(List<String> matches) {
    if (matches[1].isNotEmpty) {
      ownerCode = matches[1].split('');
    }
    if (matches[2].isNotEmpty) {
      productGroupCode = matches[2];
    }
    if (matches[3].isNotEmpty) {
      registrationDigit = matches[3].split('');
    }
    if (matches.length > 4 && matches[4].isNotEmpty) {
      checkDigit = matches[4];
    }

    List<int> numericalOwnerCode = [];
    for (String code in ownerCode) {
      numericalOwnerCode.add(alphabetNumerical[code]!);
    }
    numericalOwnerCode.add(alphabetNumerical[productGroupCode]!);

    List<String> numericalCode = [...numericalOwnerCode.map((e) => e.toString()), ...registrationDigit];
    int sumDigit = 0;

    for (int i = 0; i < numericalCode.length; i++) {
      sumDigit += int.parse(numericalCode[i]) * pow(2, i).toInt();
    }

    int sumDigitDiff = (sumDigit / 11).floor() * 11;
    int calculatedCheckDigit = sumDigit - sumDigitDiff;
    return (calculatedCheckDigit == 10) ? "0" : calculatedCheckDigit.toString();
  }

  List<String>? identify(String containerNumber, [bool withoutCheckDigit = false]) {
    clearErrors();
    RegExp regex = withoutCheckDigit ? patternWithoutCheckDigit : pattern;
    RegExpMatch? match = regex.firstMatch(containerNumber.toUpperCase());
    if (match != null) {
      return match.groups([0, 1, 2, 3, 4]).whereType<String>().toList();
    } else {
      return null;
    }
  }
}
