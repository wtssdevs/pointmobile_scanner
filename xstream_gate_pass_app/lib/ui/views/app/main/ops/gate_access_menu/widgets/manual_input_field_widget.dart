import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xstream_gate_pass_app/ui/views/app/main/ops/gate_access_menu/widgets/photo_preview_widget.dart';

class ManualInputFieldWidget extends StatelessWidget {
  const ManualInputFieldWidget({
    Key? key,
    required this.controller,
    required this.isManualEntryUsed,
    required this.isPhotoTaken,
    this.photoPath,
    required this.onManualInput,
    required this.onViewPhoto,
    required this.validateRegistration,
    this.label = 'Manual Entry',
    this.hintText = 'CA123456 or ABC123GP',
  }) : super(key: key);

  final TextEditingController controller;
  final bool isManualEntryUsed;
  final bool isPhotoTaken;
  final dynamic photoPath;
  final Function(String) onManualInput;
  final VoidCallback onViewPhoto;
  final bool Function(String) validateRegistration;
  final String label;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 10,
                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'\s')),
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  ],
                  decoration: InputDecoration(
                    labelText: label,
                    hintText: hintText,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    isDense: true,
                    counterText: '',
                    helperText: 'No spaces, letters and numbers only',
                    helperStyle: const TextStyle(fontSize: 10),
                  ),
                  onSubmitted: (val) {
                    if (validateRegistration(val)) {
                      onManualInput(val);
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isManualEntryUsed ? Colors.green : Colors.grey[300],
                ),
                child: IconButton(
                  onPressed: () {
                    final text = controller.text;
                    if (validateRegistration(text)) {
                      onManualInput(text);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid format. Use: CA123456 or ABC123GP'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    Icons.check,
                    color: isManualEntryUsed ? Colors.white : Colors.grey[600],
                    size: 20,
                  ),
                  iconSize: 20,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(),
                  tooltip: 'Save',
                ),
              ),
            ],
          ),
          if (isManualEntryUsed && isPhotoTaken && photoPath != null)
            PhotoPreviewWidget(
              imagePath: photoPath!.path,
              onTap: onViewPhoto,
            ),
        ],
      ),
    );
  }
}