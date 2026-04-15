import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:will_i_make_it/home/cubit/home_cubit.dart';
import 'package:will_i_make_it/home/cubit/home_state.dart';
import 'package:will_i_make_it/home/view/widgets/fallback_card.dart';
import 'package:will_i_make_it/home/view/widgets/gps_badge.dart';
import 'package:will_i_make_it/home/view/widgets/probability_ring.dart';
import 'package:will_i_make_it/l10n/l10n.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/shuttle/shuttle.dart';

/// Top-level "Will I make it?" screen.
///
/// Test overrides can inject a pre-built [HomeCubit] via [cubit] to bypass
/// platform GPS/Repository wiring.
class HomePage extends StatelessWidget {
  const HomePage({super.key, this.cubit});

  final HomeCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<HomeCubit>.value(
        value: cubit!,
        child: const HomeView(),
      );
    }
    return BlocProvider(
      create: (_) {
        final cubit = HomeCubit(
          locationService: const GeolocatorLocationService(),
          shuttleRepository: const HardcodedShuttleRepository(),
        );
        unawaited(cubit.start());
        return cubit;
      },
      child: const HomeView(),
    );
  }
}

@visibleForTesting
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.homeTitle)),
      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) => switch (state) {
          HomeInitial() => const Center(child: CircularProgressIndicator()),
          HomePermissionDenied() => PermissionDeniedView(state: state),
          HomeNoShuttlesToday() => _NoShuttlesView(),
          HomeTracking() => TrackingView(state: state),
        },
      ),
    );
  }
}

@visibleForTesting
class TrackingView extends StatelessWidget {
  const TrackingView({required this.state, super.key});

  final HomeTracking state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final seconds = state.schedule.secondsUntilDepartureFrom(state.now);
    final minutes = seconds <= 0 ? 0 : (seconds / 60).floor();
    final willMakeIt = state.probability >= 0.5;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 32,
              child: state.isGpsAccurate
                  ? const SizedBox.shrink()
                  : const Align(
                      alignment: Alignment.centerRight,
                      child: GpsBadge(),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.homeProbabilityLabel,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ProbabilityRing(value: state.probability, size: 220),
            ),
            const SizedBox(height: 20),
            Text(
              willMakeIt ? l10n.homeOutcomeMakeIt : l10n.homeOutcomeMissIt,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            FallbackCard(
              minutesUntilDeparture: minutes,
              stopName: state.schedule.stop.name,
            ),
          ],
        ),
      ),
    );
  }
}

@visibleForTesting
class PermissionDeniedView extends StatelessWidget {
  const PermissionDeniedView({required this.state, super.key});

  final HomePermissionDenied state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_disabled,
              size: 56,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              l10n.homePermissionDeniedTitle,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.homePermissionDeniedBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () async {
                final cubit = context.read<HomeCubit>();
                if (state.permanent) {
                  await cubit.openSystemSettings();
                } else {
                  await cubit.start();
                }
              },
              icon: const Icon(Icons.settings),
              label: Text(l10n.homePermissionRequestButton),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoShuttlesView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        context.l10n.homeNoShuttlesToday,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }
}
