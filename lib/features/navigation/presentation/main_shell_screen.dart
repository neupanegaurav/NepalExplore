import 'package:flutter/material.dart';
import 'package:nepal_explore/core/layout/adaptive_layout.dart';
import 'package:nepal_explore/features/admin/presentation/admin_root_screen.dart';
import 'package:nepal_explore/features/map/presentation/map_screen.dart';
import 'package:nepal_explore/features/destinations/presentation/featured_destinations_screen.dart';
import 'package:nepal_explore/features/spots/presentation/add_spot_screen.dart';
import 'package:nepal_explore/features/settings/presentation/settings_screen.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    this.showAdminWorkspace = false,
    this.initialIndex = 0,
  });

  final bool showAdminWorkspace;
  final int initialIndex;

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tabs = <Widget>[
      const MapScreen(),
      const FeaturedDestinationsScreen(),
      const AddSpotScreen(),
      const SettingsScreen(),
      if (widget.showAdminWorkspace) const AdminRootScreen(),
    ];
    final destinations = <(IconData, IconData, String)>[
      (Icons.explore_outlined, Icons.explore, 'Explore'),
      (Icons.star_outline, Icons.star, 'Featured'),
      (Icons.add_circle_outline, Icons.add_circle, 'Post'),
      (Icons.settings_outlined, Icons.settings, 'Settings'),
      if (widget.showAdminWorkspace)
        (
          Icons.admin_panel_settings_outlined,
          Icons.admin_panel_settings,
          'Admin',
        ),
    ];
    final currentIndex = _currentIndex >= tabs.length ? 0 : _currentIndex;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useTabletLayout = AppAdaptiveLayout.useTabletLayout(
          context,
          width: constraints.maxWidth,
        );
        final useExtendedRail = AppAdaptiveLayout.useDesktopLayout(
          context,
          width: constraints.maxWidth,
        );

        if (!useTabletLayout) {
          return Scaffold(
            body: IndexedStack(index: currentIndex, children: tabs),
            bottomNavigationBar: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              destinations: destinations
                  .map(
                    (item) => NavigationDestination(
                      icon: Icon(item.$1),
                      selectedIcon: Icon(item.$2),
                      label: item.$3,
                    ),
                  )
                  .toList(),
            ),
          );
        }

        return Scaffold(
          body: Row(
            children: [
              Container(
                width: useExtendedRail ? 220 : 88,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(right: BorderSide(color: theme.dividerColor)),
                ),
                child: SafeArea(
                  child: NavigationRail(
                    extended: useExtendedRail,
                    minExtendedWidth: 220,
                    selectedIndex: currentIndex,
                    onDestinationSelected: (index) {
                      setState(() => _currentIndex = index);
                    },
                    labelType: useExtendedRail
                        ? null
                        : NavigationRailLabelType.all,
                    leading: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 12, 8, 20),
                      child: useExtendedRail
                          ? Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.12,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.terrain,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'NepalExplore',
                                        style: theme.textTheme.titleMedium,
                                      ),
                                      Text(
                                        'Responsive Layout',
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          : Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.terrain,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                    ),
                    destinations: destinations
                        .map(
                          (item) => NavigationRailDestination(
                            icon: Icon(item.$1),
                            selectedIcon: Icon(item.$2),
                            label: Text(item.$3),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                child: IndexedStack(index: currentIndex, children: tabs),
              ),
            ],
          ),
        );
      },
    );
  }
}
