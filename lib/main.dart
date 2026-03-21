import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_explore/core/theme/theme.dart';
import 'package:nepal_explore/features/navigation/presentation/main_shell_screen.dart';
import 'package:nepal_explore/features/settings/presentation/settings_screen.dart';

void main() {
  AppTheme.init();
  runApp(
    const ProviderScope(
      child: NepalExploreApp(),
    ),
  );
}

class NepalExploreApp extends ConsumerWidget {
  const NepalExploreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'ExploreNepal',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      home: const MainShellScreen(),
    );
  }
}
