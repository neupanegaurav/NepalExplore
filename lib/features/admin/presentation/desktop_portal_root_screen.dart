import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:nepal_explore/features/admin/data/admin_access_service.dart';
import 'package:nepal_explore/features/admin/presentation/admin_login_screen.dart';
import 'package:nepal_explore/features/navigation/presentation/main_shell_screen.dart';

class DesktopPortalRootScreen extends StatelessWidget {
  const DesktopPortalRootScreen({super.key});

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
              return _DesktopAccessErrorScreen(
                details: accessSnapshot.error.toString(),
              );
            }

            final isAdmin = accessSnapshot.data ?? false;
            return MainShellScreen(
              showAdminWorkspace: isAdmin,
              initialIndex: isAdmin ? 4 : 0,
            );
          },
        );
      },
    );
  }
}

class _DesktopAccessErrorScreen extends StatelessWidget {
  const _DesktopAccessErrorScreen({required this.details});

  final String details;

  @override
  Widget build(BuildContext context) {
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
                  Text(
                    'Portal Access Check Failed',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'The desktop/web app could not verify whether this signed-in user is an admin. Please make sure your latest Supabase SQL is applied.',
                  ),
                  const SizedBox(height: 16),
                  SelectableText(details),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                    },
                    child: const Text('Sign Out'),
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
