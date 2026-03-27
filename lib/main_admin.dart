import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nepal_explore/core/config/app_config.dart';
import 'package:nepal_explore/core/theme/theme.dart';
import 'package:nepal_explore/features/admin/presentation/desktop_portal_root_screen.dart';

Future<void> main() => mainAdmin();

Future<void> mainAdmin() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.init();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: NepalExploreAdminApp()));
}

class NepalExploreAdminApp extends StatelessWidget {
  const NepalExploreAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NepalExplore Portal',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const DesktopPortalRootScreen(),
    );
  }
}
