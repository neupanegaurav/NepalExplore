import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nepal_explore/core/theme/theme.dart';
import 'package:nepal_explore/features/map/presentation/providers/map_provider.dart';

// Theme mode provider
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;
  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeModeProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // iOS-style large title
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text('Settings', style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 28, fontWeight: FontWeight.bold)),
              expandedTitleScale: 1.0,
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Appearance Section
                  _SectionLabel(label: 'APPEARANCE', color: AppTheme.primaryColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _ThemeOption(
                          label: 'System',
                          subtitle: 'Match device',
                          icon: Icons.brightness_auto,
                          iconColor: AppTheme.primaryColor,
                          selected: currentTheme == ThemeMode.system,
                          onTap: () => ref.read(themeModeProvider.notifier).set(ThemeMode.system),
                          showDivider: true,
                        ),
                        _ThemeOption(
                          label: 'Light',
                          subtitle: 'Always light',
                          icon: Icons.light_mode,
                          iconColor: AppTheme.accentOrange,
                          selected: currentTheme == ThemeMode.light,
                          onTap: () => ref.read(themeModeProvider.notifier).set(ThemeMode.light),
                          showDivider: true,
                        ),
                        _ThemeOption(
                          label: 'Dark',
                          subtitle: 'Always dark',
                          icon: Icons.dark_mode,
                          iconColor: AppTheme.accentIndigo,
                          selected: currentTheme == ThemeMode.dark,
                          onTap: () => ref.read(themeModeProvider.notifier).set(ThemeMode.dark),
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Data Management Section
                  _SectionLabel(label: 'DATA MANAGEMENT', color: AppTheme.accentTeal),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppTheme.accentTeal.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.sync, color: AppTheme.accentTeal, size: 20),
                          ),
                          title: const Text('Sync Data'),
                          subtitle: const Text('Fetch latest spots from online database'),
                          trailing: const Icon(Icons.chevron_right, size: 16),
                          onTap: () async {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing data from online database...'), duration: Duration(seconds: 1)));
                            await ref.read(spotsProvider.notifier).syncSpots(context);
                          },
                        );
                      }
                    ),
                  ),
                  const SizedBox(height: 24),

                  // General Section
                  _SectionLabel(label: 'GENERAL', color: AppTheme.secondaryColor),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.cardTheme.color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppTheme.accentPurple.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.language, color: AppTheme.accentPurple, size: 20),
                          ),
                          title: const Text('Language'),
                          subtitle: const Text('English'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: AppTheme.accentTeal.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                            child: const Text('Soon', style: TextStyle(color: AppTheme.accentTeal, fontSize: 11, fontWeight: FontWeight.w600)),
                          ),
                        ),
                        Divider(height: 0, indent: 56, color: theme.dividerColor),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.info_outline, color: AppTheme.primaryColor, size: 20),
                          ),
                          title: const Text('About ExploreNepal'),
                          subtitle: const Text('Version 3.0'),
                        ),
                        Divider(height: 0, indent: 56, color: theme.dividerColor),
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: AppTheme.accentOrange.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.star_outline, color: AppTheme.accentOrange, size: 20),
                          ),
                          title: const Text('Rate this App'),
                          trailing: const Icon(Icons.open_in_new, size: 16),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Exit Button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Exit App'),
                            content: const Text('Are you sure you want to exit?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                              TextButton(
                                onPressed: () => SystemNavigator.pop(),
                                child: const Text('Exit', style: TextStyle(color: AppTheme.accentRed)),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text('Exit App'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.accentRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _SectionLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final bool selected;
  final VoidCallback onTap;
  final bool showDivider;

  const _ThemeOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.selected,
    required this.onTap,
    required this.showDivider,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          title: Text(label),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 13, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
          trailing: selected
              ? const Icon(Icons.check_circle, color: AppTheme.primaryColor, size: 22)
              : Icon(Icons.circle_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.2), size: 22),
          onTap: onTap,
        ),
        if (showDivider) Divider(height: 0, indent: 56, color: theme.dividerColor),
      ],
    );
  }
}
