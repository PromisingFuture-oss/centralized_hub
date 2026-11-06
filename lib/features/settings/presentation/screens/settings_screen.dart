import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/app_theme.dart';

/// Settings screen with theme, data management, and tracking controls.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isTrackingRunning = false;
  String _themeMode = 'system';
  String _accentColor = '#00E5FF';
  String _tempUnit = 'celsius';
  int _sampleIntervalMs = 30000;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = ref.read(settingsRepositoryProvider);
    final tracker = ref.read(sessionTrackerServiceProvider);

    final themeMode = await settings.getThemeMode();
    final accentColor = await settings.getAccentColor();
    final tempUnit = await settings.getTempUnit();
    final sampleInterval = await settings.getSampleIntervalMs();
    final isRunning = await tracker.isRunning();

    if (mounted) {
      setState(() {
        _themeMode = themeMode;
        _accentColor = accentColor;
        _tempUnit = tempUnit;
        _sampleIntervalMs = sampleInterval;
        _isTrackingRunning = isRunning;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        children: [
          // --- Tracking ---
          _SectionHeader(title: 'Tracking'),
          SwitchListTile(
            title: const Text('Game Tracking'),
            subtitle: Text(_isTrackingRunning
                ? 'Service is running in the background'
                : 'Service is stopped'),
            secondary: Icon(
              _isTrackingRunning
                  ? Icons.play_circle_filled
                  : Icons.stop_circle_outlined,
              color: _isTrackingRunning ? colorScheme.primary : null,
            ),
            value: _isTrackingRunning,
            onChanged: (value) async {
              final tracker = ref.read(sessionTrackerServiceProvider);
              if (value) {
                await tracker.startTracking();
              } else {
                await tracker.stopTracking();
              }
              setState(() => _isTrackingRunning = value);
            },
          ),
          ListTile(
            title: const Text('Sample Interval'),
            subtitle: Text('${_sampleIntervalMs ~/ 1000} seconds'),
            leading: const Icon(Icons.timer_outlined),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _sampleIntervalMs.toDouble(),
                min: 15000,
                max: 60000,
                divisions: 9,
                label: '${_sampleIntervalMs ~/ 1000}s',
                onChanged: (value) {
                  setState(() => _sampleIntervalMs = value.toInt());
                },
                onChangeEnd: (value) async {
                  await ref
                      .read(settingsRepositoryProvider)
                      .setSampleIntervalMs(value.toInt());
                },
              ),
            ),
          ),
          const Divider(),

          // --- Appearance ---
          _SectionHeader(title: 'Appearance'),
          ListTile(
            title: const Text('Theme Mode'),
            subtitle: Text(
              _themeMode == 'amoled'
                  ? 'AMOLED Black'
                  : _themeMode[0].toUpperCase() + _themeMode.substring(1),
            ),
            leading: const Icon(Icons.palette_outlined),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'light',
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode, size: 16),
                ),
                ButtonSegment(
                  value: 'dark',
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode, size: 16),
                ),
                ButtonSegment(
                  value: 'amoled',
                  label: Text('AMOLED'),
                  icon: Icon(Icons.brightness_2, size: 16),
                ),
                ButtonSegment(
                  value: 'system',
                  label: Text('System'),
                  icon: Icon(Icons.settings_brightness, size: 16),
                ),
              ],
              selected: {_themeMode},
              onSelectionChanged: (values) async {
                final mode = values.first;
                setState(() => _themeMode = mode);
                await ref.read(settingsRepositoryProvider).setThemeMode(mode);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Gaming Accent Presets
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.color_lens_outlined, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Gaming Accent Preset',
                      style: textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: AppTheme.presets.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final preset = AppTheme.presets[index];
                      final isSelected =
                          _accentColor.toUpperCase() == preset.hex.toUpperCase();
                      return InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () async {
                          setState(() => _accentColor = preset.hex);
                          await ref
                              .read(settingsRepositoryProvider)
                              .setAccentColor(preset.hex);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? preset.primary.withValues(alpha: 0.16)
                                : colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? preset.primary
                                  : colorScheme.outlineVariant
                                      .withValues(alpha: 0.4),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: preset.primary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: preset.secondary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                preset.name,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? preset.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            title: const Text('Temperature Unit'),
            leading: const Icon(Icons.thermostat_outlined),
            trailing: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'celsius', label: Text('°C')),
                ButtonSegment(value: 'fahrenheit', label: Text('°F')),
              ],
              selected: {_tempUnit},
              onSelectionChanged: (values) async {
                final unit = values.first;
                setState(() => _tempUnit = unit);
                await ref.read(settingsRepositoryProvider).setTempUnit(unit);
              },
            ),
          ),
          const Divider(),

          // --- Data ---
          _SectionHeader(title: 'Data'),
          ListTile(
            title: const Text('Export as CSV'),
            leading: const Icon(Icons.table_chart_outlined),
            onTap: () => _export('csv'),
          ),
          ListTile(
            title: const Text('Export as JSON'),
            leading: const Icon(Icons.data_object),
            onTap: () => _export('json'),
          ),
          ListTile(
            title: const Text('Delete All Data'),
            leading: Icon(Icons.delete_forever, color: colorScheme.error),
            textColor: colorScheme.error,
            onTap: _confirmDeleteAll,
          ),
          const Divider(),

          // --- About ---
          _SectionHeader(title: 'About'),
          ListTile(
            title: const Text('Centralized Hub'),
            subtitle: const Text('v1.0.0 • All data stays on-device'),
            leading: const Icon(Icons.info_outline),
          ),
          const ListTile(
            title: Text('Platform Limitations'),
            subtitle: Text(
              'Battery temperature is read from the battery sensor and is a proxy for device heat, '
              'not the actual CPU/SoC temperature. It is typically 5-15°C lower.',
            ),
            leading: Icon(Icons.warning_amber_outlined),
            isThreeLine: true,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Future<void> _export(String format) async {
    try {
      final exportService = ref.read(exportServiceProvider);
      final content = format == 'csv'
          ? await exportService.exportSessionsCsv()
          : await exportService.exportJson();

      final dir = await getApplicationDocumentsDirectory();
      final extension = format == 'csv' ? 'csv' : 'json';
      final file = File(
          '${dir.path}/centralized_hub_export_${DateTime.now().millisecondsSinceEpoch}.$extension');
      await file.writeAsString(content);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Centralized Hub Export',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> _confirmDeleteAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: Icon(Icons.delete_forever,
            color: Theme.of(context).colorScheme.error),
        title: const Text('Delete All Data?'),
        content: const Text(
          'This will permanently delete all tracked sessions, games, and samples. '
          'Settings and dashboard layouts will be preserved. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(databaseProvider).deleteAllData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All data deleted')),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
