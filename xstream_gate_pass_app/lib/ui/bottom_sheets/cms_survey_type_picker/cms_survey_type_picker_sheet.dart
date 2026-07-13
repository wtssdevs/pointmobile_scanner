import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:xstream_gate_pass_app/core/enums/cms_survey_type.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class CmsSurveyTypePickerSheet extends StatelessWidget {
  const CmsSurveyTypePickerSheet({
    super.key,
    required this.completer,
    required this.request,
  });

  final Function(SheetResponse)? completer;
  final SheetRequest request;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              request.title ?? 'New survey',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              request.description ?? 'Choose the survey workflow you need to capture.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            _TypeOption(
              icon: Icons.inventory_2_outlined,
              title: 'Container survey',
              description: 'Survey tied to a container record.',
              color: kcPrimaryColor,
              onTap: () => _complete(CmsSurveyType.container),
            ),
            const SizedBox(height: 12),
            _TypeOption(
              icon: Icons.local_shipping_outlined,
              title: 'Gate pass survey',
              description: 'Survey tied to a gate pass container movement.',
              color: Colors.deepOrange,
              onTap: () => _complete(CmsSurveyType.gatePass),
            ),
          ],
        ),
      ),
    );
  }

  void _complete(CmsSurveyType surveyType) {
    completer?.call(
      SheetResponse<CmsSurveyType>(confirmed: true, data: surveyType),
    );
  }
}

class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
