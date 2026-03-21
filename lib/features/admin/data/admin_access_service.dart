import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAccessService {
  AdminAccessService({required SupabaseClient client}) : _client = client;

  final SupabaseClient _client;

  Future<bool> hasAdminAccess() async {
    final currentUser = _client.auth.currentUser;
    if (currentUser == null) {
      return false;
    }

    final rows = await _client
        .from('admin_users')
        .select('user_id, is_active')
        .eq('user_id', currentUser.id)
        .eq('is_active', true)
        .limit(1);

    return rows.isNotEmpty;
  }
}
