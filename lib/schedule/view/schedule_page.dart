import 'package:flutter/material.dart';
import 'package:will_i_make_it/l10n/l10n.dart';
import 'package:will_i_make_it/shuttle/repository/seed_data.dart';

/// 전체 셔틀 시간표. 상행/하행 두 탭.
///
/// [now]는 "지나간 / 다음 / 미래" 구분에 사용. 테스트에서는 고정값을 주입.
/// 프로덕션에서는 홈 화면이 진입 시점에 `DateTime.now()`를 넘겨 고정.
class SchedulePage extends StatelessWidget {
  const SchedulePage({required this.now, super.key});

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.scheduleTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.scheduleTabUpbound),
              Tab(text: l10n.scheduleTabDownbound),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _ScheduleTab(
              stopId: jiseokmyoStop.id,
              routeLabel: l10n.scheduleRouteUpbound,
              now: now,
            ),
            _ScheduleTab(
              stopId: inmunGyeongsangStop.id,
              routeLabel: l10n.scheduleRouteDownbound,
              now: now,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({
    required this.stopId,
    required this.routeLabel,
    required this.now,
  });

  final String stopId;
  final String routeLabel;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isWeekend =
        now.weekday == DateTime.saturday || now.weekday == DateTime.sunday;
    final inService = isWithinServicePeriod(now) && !isWeekend;
    final departures = inService
        ? departuresForStop(stopId, now)
        : const <DateTime>[];

    // 다음 출발: now 이후 첫 시각. 없으면 null.
    DateTime? nextDeparture;
    for (final d in departures) {
      if (d.isAfter(now)) {
        nextDeparture = d;
        break;
      }
    }

    if (departures.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                routeLabel,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.scheduleEmpty,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            routeLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: departures.length,
            itemBuilder: (context, index) {
              final d = departures[index];
              final isPast = !d.isAfter(now);
              final isNext = d == nextDeparture;
              return _DepartureRow(
                time: d,
                isPast: isPast,
                isNext: isNext,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _DepartureRow extends StatelessWidget {
  const _DepartureRow({
    required this.time,
    required this.isPast,
    required this.isNext,
  });

  final DateTime time;
  final bool isPast;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final hh = time.hour.toString().padLeft(2, '0');
    final mm = time.minute.toString().padLeft(2, '0');

    final baseStyle = theme.textTheme.titleLarge;
    final color = isNext
        ? theme.colorScheme.primary
        : isPast
        ? theme.colorScheme.onSurface.withValues(alpha: 0.38)
        : theme.colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: isNext
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : null,
        border: Border(
          bottom: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            '$hh:$mm',
            style: baseStyle?.copyWith(
              color: color,
              fontWeight: isNext ? FontWeight.w600 : FontWeight.w400,
              decoration: isPast ? TextDecoration.lineThrough : null,
            ),
          ),
          const Spacer(),
          if (isNext)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.scheduleNextBadge,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
