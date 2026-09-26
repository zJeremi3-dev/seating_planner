import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_language.dart';
import '../state/providers.dart';

Future<void> showSettingsDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const Dialog(child: _SettingsDialogContent()),
  );
}

class _SettingsDialogContent extends ConsumerWidget {
  const _SettingsDialogContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          ],
        ),
      ),
    );
  }
}
