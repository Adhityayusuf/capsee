import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';
import 'brand_logo.dart';

class DashboardHeader extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final VoidCallback? onBack;

  const DashboardHeader({
    super.key,
    required this.title,
    this.actions = const [],
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Row(
        children: [
          if (onBack != null) ...[
            DashboardHeaderAction(
              tooltip: 'Kembali',
              icon: Icons.arrow_back_rounded,
              onPressed: onBack!,
              backgroundColor: p.surfaceAlt,
              foregroundColor: p.accent,
            ),
            const SizedBox(width: 8),
          ],
          const CapseeMark(size: 36),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Capsee',
                  style: AppText.subtitle(
                    context,
                    color: p.title,
                  ).copyWith(fontSize: 17, fontWeight: FontWeight.w800),
                ),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.micro(context, color: p.subtitle),
                ),
              ],
            ),
          ),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 5),
            actions[i],
          ],
        ],
      ),
    );
  }
}

class DashboardHeaderAction extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const DashboardHeaderAction({
    super.key,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(icon, color: foregroundColor, size: 18),
        ),
      ),
    ),
  );
}
