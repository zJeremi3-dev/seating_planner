import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/home_page.dart';
import 'state/providers.dart';

void main() {
  runApp(const ProviderScope(child: SeatingPlannerApp()));
}

class SeatingPlannerApp extends ConsumerWidget {
  const SeatingPlannerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: strings.appTitle,
      home: const HomePage(),
    );
  }
}
