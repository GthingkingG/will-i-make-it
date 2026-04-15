import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:will_i_make_it/l10n/l10n.dart';
import 'package:will_i_make_it/location/location.dart';
import 'package:will_i_make_it/settings/cubit/settings_cubit.dart';
import 'package:will_i_make_it/settings/cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, this.cubit});

  final SettingsCubit? cubit;

  @override
  Widget build(BuildContext context) {
    if (cubit != null) {
      return BlocProvider<SettingsCubit>.value(
        value: cubit!,
        child: const SettingsView(),
      );
    }
    return BlocProvider(
      create: (_) {
        final c = SettingsCubit(
          locationService: const GeolocatorLocationService(),
        );
        unawaited(c.refresh());
        return c;
      },
      child: const SettingsView(),
    );
  }
}

@visibleForTesting
class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 사용자가 OS 설정에서 권한을 바꾸고 돌아왔을 때 상태 재동기화.
    if (state == AppLifecycleState.resumed) {
      unawaited(context.read<SettingsCubit>().refresh());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) => switch (state) {
          SettingsLoading() => const Center(child: CircularProgressIndicator()),
          SettingsLoaded() => _LocationCard(status: state.locationStatus),
        },
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.status});

  final LocationPermissionStatus status;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final cubit = context.read<SettingsCubit>();

    final (String statusText, Color statusColor) = switch (status) {
      LocationPermissionStatus.granted => (
        l10n.settingsLocationStatusGranted,
        theme.colorScheme.primary,
      ),
      LocationPermissionStatus.denied => (
        l10n.settingsLocationStatusDenied,
        theme.colorScheme.error,
      ),
      LocationPermissionStatus.deniedForever => (
        l10n.settingsLocationStatusDeniedForever,
        theme.colorScheme.error,
      ),
      LocationPermissionStatus.serviceDisabled => (
        l10n.settingsLocationStatusServiceDisabled,
        theme.colorScheme.error,
      ),
    };

    final canRequest = status == LocationPermissionStatus.denied;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.settingsLocationStatusHeader,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                l10n.settingsLocationDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text(
                    statusText,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (canRequest)
                FilledButton.icon(
                  key: const ValueKey('settings-request-permission'),
                  onPressed: cubit.requestPermission,
                  icon: const Icon(Icons.lock_open),
                  label: Text(l10n.settingsLocationActionRequest),
                )
              else if (status != LocationPermissionStatus.granted)
                FilledButton.icon(
                  key: const ValueKey('settings-open-os'),
                  onPressed: () async {
                    await cubit.openSystemSettings();
                  },
                  icon: const Icon(Icons.settings),
                  label: Text(l10n.settingsLocationActionOpenSettings),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
