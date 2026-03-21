import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nepal_explore/features/admin/data/admin_access_service.dart';
import 'package:nepal_explore/features/admin/presentation/admin_dashboard_screen.dart';
import 'package:nepal_explore/features/admin/presentation/admin_login_screen.dart';

class AdminRootScreen extends StatelessWidget {
  const AdminRootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final accessService = AdminAccessService(client: client);

    return StreamBuilder<AuthState>(
      stream: client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session ?? client.auth.currentSession;

        if (session == null &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (session == null) {
          return const AdminLoginScreen();
        }

        return FutureBuilder<bool>(
          future: accessService.hasAdminAccess(),
          builder: (context, accessSnapshot) {
            if (accessSnapshot.connectionState != ConnectionState.done) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (accessSnapshot.hasError) {
              return _AdminAccessMessageScreen(
                title: 'Admin Check Failed',
                description:
                    'The app could not verify your admin access. Please confirm that the latest SQL was applied in Supabase and try again.',
                details: accessSnapshot.error.toString(),
                primaryActionLabel: 'Retry',
                onPrimaryAction: () {
                  (context as Element).markNeedsBuild();
                },
              );
            }

            if (accessSnapshot.data == true) {
              return const AdminDashboardScreen();
            }

            final currentUser = client.auth.currentUser;
            return _AdminAccessMessageScreen(
              title: 'Admin Access Not Granted',
              description:
                  'You are signed in, but this account is not registered in public.admin_users, so pending and rejected submissions stay hidden by RLS.',
              details:
                  'Signed in as: ${currentUser?.email ?? 'unknown'}\nUser id: ${currentUser?.id ?? 'unknown'}',
              primaryActionLabel: 'Sign Out',
              onPrimaryAction: () {
                client.auth.signOut();
              },
            );
          },
        );
      },
    );
  }
}

class _AdminAccessMessageScreen extends StatelessWidget {
  const _AdminAccessMessageScreen({
    required this.title,
    required this.description,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.details,
  });

  final String title;
  final String description;
  final String? details;
  final String primaryActionLabel;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(title, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: 10),
                  Text(description, style: theme.textTheme.bodyMedium),
                  if (details != null) ...[
                    const SizedBox(height: 16),
                    SelectableText(details!, style: theme.textTheme.bodySmall),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: onPrimaryAction,
                    child: Text(primaryActionLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
