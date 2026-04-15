import 'package:flutter/material.dart';
import 'package:will_i_make_it/l10n/l10n.dart';

/// Small card shown beneath the probability ring with the next shuttle's
/// ETA. Acts as the "raw timetable" fallback so users can cross-check the
/// probability against a plain number.
class FallbackCard extends StatelessWidget {
  const FallbackCard({
    required this.minutesUntilDeparture,
    required this.stopName,
    super.key,
  });

  final int minutesUntilDeparture;
  final String stopName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeFallbackTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              l10n.homeFallbackMinutes(minutesUntilDeparture),
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(stopName, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
