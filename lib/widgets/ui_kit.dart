import 'package:flutter/material.dart';

import '../core/app_text.dart';
import '../core/app_theme.dart';

/// Komponen UI standar Capsee agar semua halaman rapi & konsisten.
///
/// - [CapseeCard]  : kartu putih/surface standar (radius 16 + border + shadow)
/// - [SectionHeader]: judul seksi + ikon + aksi opsional
/// - [EmptyState]  : tampilan kosong standar (ikon + judul + pesan + tombol)
/// - [StatusBadge] : badge status (success/error/info/warning)
// ignore: avoid_classes_with_only_static_members

/// Kartu standar seluruh aplikasi.
class CapseeCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const CapseeCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpace.card),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppSpace.radiusCard),
        border: Border.all(color: p.border.withValues(alpha: .6)),
        boxShadow: [
          BoxShadow(color: p.shadow, blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
    if (onTap == null) return card;
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpace.radiusCard),
      onTap: onTap,
      child: card,
    );
  }
}

/// Header seksi standar: ikon + judul + subjudul + tombol aksi.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: p.accentSoft,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: p.accent, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.subtitle(context)),
              if (subtitle != null)
                Text(subtitle!, style: AppText.caption(context)),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

enum BadgeKind { success, error, info, warning }

/// Badge status standar.
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeKind kind;

  const StatusBadge({super.key, required this.label, required this.kind});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    late final Color bg;
    late final Color fg;
    switch (kind) {
      case BadgeKind.success:
        bg = p.accentSoft;
        fg = p.onAccentSoft;
        break;
      case BadgeKind.error:
        bg = p.error.withValues(alpha: .12);
        fg = p.error;
        break;
      case BadgeKind.info:
        bg = Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF0F2A3A)
            : const Color(0xFFCCE5FF);
        fg = Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF7DD3FC)
            : const Color(0xFF005B8C);
        break;
      case BadgeKind.warning:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpace.radiusPill),
      ),
      child: Text(
        label,
        style: AppText.caption(context).copyWith(
          color: fg,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// Tampilan kosong standar (belum ada data).
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: p.accentSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: p.accent, size: 36),
            ),
            const SizedBox(height: AppSpace.gapMd),
            Text(title, style: AppText.title(context)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.bodySm(context),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpace.gapLg),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add, size: 18),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
