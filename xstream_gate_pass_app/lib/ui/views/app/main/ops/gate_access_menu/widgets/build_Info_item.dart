// import 'package:flutter/material.dart';

// class BuildInfoItem extends StatelessWidget {
//   final String label;
//   final String value;
//   const BuildInfoItem({super.key, required this.label, required this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 140,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w600,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';

class BuildInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final ValidationStatus? validationStatus;
  final String? validationMessage;

  const BuildInfoItem({
    required this.label,
    required this.value,
    this.validationStatus,
    this.validationMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Expanded(child: Text(value)),
                if (validationStatus != null)
                  Icon(
                    validationStatus == ValidationStatus.failed ? Icons.error : Icons.check_circle,
                    color: validationStatus == ValidationStatus.failed ? Colors.red : Colors.green,
                    size: 18,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum ValidationStatus { passed, failed }
