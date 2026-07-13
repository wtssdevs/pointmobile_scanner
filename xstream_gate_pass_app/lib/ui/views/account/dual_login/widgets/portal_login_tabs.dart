import 'package:flutter/material.dart';
import 'package:xstream_gate_pass_app/core/enums/auth_portal.dart';
import 'package:xstream_gate_pass_app/ui/shared/style/app_colors.dart';

class PortalLoginTabs extends StatelessWidget {
  const PortalLoginTabs({
    Key? key,
    required this.selectedPortal,
    required this.onPortalSelected,
  }) : super(key: key);

  final AuthPortal selectedPortal;
  final ValueChanged<AuthPortal> onPortalSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _PortalTabButton(
            portal: AuthPortal.xac,
            selected: selectedPortal == AuthPortal.xac,
            onPressed: onPortalSelected,
          ),
          _PortalTabButton(
            portal: AuthPortal.cms,
            selected: selectedPortal == AuthPortal.cms,
            onPressed: onPortalSelected,
          ),
        ],
      ),
    );
  }
}

class _PortalTabButton extends StatelessWidget {
  const _PortalTabButton({
    Key? key,
    required this.portal,
    required this.selected,
    required this.onPressed,
  }) : super(key: key);

  final AuthPortal portal;
  final bool selected;
  final ValueChanged<AuthPortal> onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onPressed(portal),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? kcPrimaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            portal.shortLabel,
            style: TextStyle(
              color: selected ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}