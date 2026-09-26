import 'package:flutter/material.dart';

import '../l10n/app_strings.dart';
import '../l10n/help_content.dart';

Future<void> showHelpDialog(BuildContext context, AppStrings strings) {
  final sections = helpSectionsFor(strings.language);
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.white,
      title: Row(
        children: [
          const Icon(Icons.menu_book, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            strings.helpDialogTitle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
        ],
      ),
      content: SizedBox(
        height: 500,
        width: 600,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final section in sections) ...[
                Row(
                  children: [
                    Icon(section.icon, size: 22, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      section.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const Divider(thickness: 2),
                const SizedBox(height: 8),
                for (final entry in section.entries)
                  Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.subtitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.body,
                          style: const TextStyle(fontSize: 13, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(strings.close),
        ),
      ],
    ),
  );
}
