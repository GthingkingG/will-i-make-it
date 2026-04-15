import 'package:flutter/material.dart';
import 'package:will_i_make_it/l10n/l10n.dart';

/// Pill-shaped badge that warns the user when the current GPS fix is
/// unreliable (accuracy > 50m). Surfacing this is a requirement of the
/// probability formula in DESIGN_v0.md.
class GpsBadge extends StatelessWidget {
  const GpsBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gps_off, size: 14, color: cs.onErrorContainer),
          const SizedBox(width: 6),
          Text(
            context.l10n.homeGpsInaccurateBadge,
            style: TextStyle(
              color: cs.onErrorContainer,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
