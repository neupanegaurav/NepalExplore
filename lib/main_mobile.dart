import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nepal_explore/core/config/app_config.dart';
import 'package:nepal_explore/core/database/app_document_database.dart';
import 'package:nepal_explore/core/theme/theme.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';
import 'package:nepal_explore/features/navigation/presentation/main_shell_screen.dart';
import 'package:nepal_explore/features/settings/presentation/settings_screen.dart';
import 'package:nepal_explore/features/spots/data/spots_mutation_source.dart';
import 'package:nepal_explore/features/spots/data/spots_remote_source.dart';
import 'package:nepal_explore/features/spots/data/spots_repository.dart';

Future<void> main() => mainMobile();

Future<void> mainMobile() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppTheme.init();
  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final database = await AppDocumentDatabase.open();
  final remoteSource = AppConfig.hasSupabaseConfig
      ? SupabaseRestSpotsRemoteSource()
      : JsonFeedSpotsRemoteSource();
  final mutationSource = AppConfig.hasSupabaseConfig
      ? SupabaseSpotsMutationSource(client: Supabase.instance.client)
      : null;
  final spotsRepository = SpotsRepository(
    database: database,
    remoteSource: remoteSource,
    mutationSource: mutationSource,
  );
  final initialSpots = await spotsRepository.loadSpots();

  runApp(
    ProviderScope(
      overrides: [
        remoteSourceProvider.overrideWithValue(remoteSource),
        spotsRepositoryProvider.overrideWithValue(spotsRepository),
        initialSpotsProvider.overrideWithValue(initialSpots),
      ],
      child: const NepalExploreMobileApp(),
    ),
  );
}

class NepalExploreMobileApp extends ConsumerWidget {
  const NepalExploreMobileApp({super.key});

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
