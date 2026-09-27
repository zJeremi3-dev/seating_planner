import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_language.dart';
import '../state/providers.dart';

import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../services/update_checker.dart';
import '../services/self_updater.dart';

Future<void> showSettingsDialog(
  BuildContext context, {
  UpdateInfo? updateInfo,
}) {
  return showDialog(
    context: context,
    builder: (context) =>
        Dialog(child: _SettingsDialogContent(updateInfo: updateInfo)),
  );
}

class _SettingsDialogContent extends ConsumerStatefulWidget {
  final UpdateInfo? updateInfo;

  const _SettingsDialogContent({this.updateInfo});

  @override
  ConsumerState<_SettingsDialogContent> createState() =>
      _SettingsDialogContentState();
}

class _SettingsDialogContentState
    extends ConsumerState<_SettingsDialogContent> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _appVersion = info.version);
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = ref.watch(settingsControllerProvider);
    final strings = ref.watch(appStringsProvider);

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.settings, color: Colors.blueGrey),
                const SizedBox(width: 8),
                Text(
                  strings.settingsTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const Divider(),
            if (widget.updateInfo != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.system_update_alt,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Update to v${widget.updateInfo!.latestVersion} available',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        final info = widget.updateInfo!;
                        if (Platform.isWindows &&
                            info.windowsDownloadUrl != null) {
                          await downloadAndInstall(info.windowsDownloadUrl!);
                        } else {
                          launchUrl(Uri.parse(info.releaseUrl));
                        }
                      },
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              strings.settingsLanguageSection,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<AppLanguage>(
              segments: [
                ButtonSegment(
                  value: AppLanguage.german,
                  label: Text(strings.settingsGerman),
                ),
                ButtonSegment(
                  value: AppLanguage.english,
                  label: Text(strings.settingsEnglish),
                ),
              ],
              selected: {settingsController.language},
              onSelectionChanged: (selection) {
                settingsController.setLanguage(selection.first);
              },
            ),
            const SizedBox(height: 20),
            Text(
              strings.settingsDisplaySection,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              strings.settingsDisplayHint,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(strings.settingsDarkModeLabel),
              subtitle: Text(strings.settingsDarkModeComingSoon),
              secondary: const Icon(Icons.dark_mode_outlined),
              value: false,
              onChanged: null,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 300,
              height: 35,
              child: OutlinedButton.icon(
                onPressed: () => showLicensePage(
                  context: context,
                  applicationName: 'Seating-Planner',
                  applicationVersion: _appVersion,
                ),
                icon: Icon(Icons.description_outlined),
                label: Text("Licenses", style: TextStyle(fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
