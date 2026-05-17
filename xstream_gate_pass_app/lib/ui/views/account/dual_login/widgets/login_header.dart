import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 88,
          width: 88,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(14),
          child: Image.asset('assets/wtssgrplogo.png', fit: BoxFit.contain),
        ),
        const SizedBox(height: 18),
        const Text(
          'Xstream Portal Access',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black87,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sign in to XAC or CMS without losing either session.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 4,
          width: 48,
          decoration: BoxDecoration(
            color: kcPrimaryColor.withOpacity(0.18),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}