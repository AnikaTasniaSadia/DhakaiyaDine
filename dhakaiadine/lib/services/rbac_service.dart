import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_service.dart';

class RbacService {
  RbacService._();

  static final RbacService instance = RbacService._();

  static const Set<String> adminRoles = {
    'admin',
    'manager',
    'kitchen',
    'counter',
  };

  static bool canAccessAdmin(String? role) {
    return role != null && adminRoles.contains(role.toLowerCase());
  }

  static String homeRouteForRole(String? role) {
    return canAccessAdmin(role) ? '/admin-dashboard' : '/home';
  }

  Future<String?> resolveRole({String? userId}) async {
    // ── Static test user: return customer role directly ──────────────────
    if (AuthService.instance.isStaticUser) {
      return 'customer';
    }
    // ────────────────────────────────────────────────────────────────────

    final currentUserId = userId ?? AuthService.instance.currentUserId;
    if (currentUserId == null) {
      return null;
    }

    // Local registered users are always 'customer'
    if (currentUserId.startsWith('local-')) {
      return 'customer';
    }

    final response = await Supabase.instance.client
        .from('users')
        .select('role')
        .eq('id', currentUserId)
        .maybeSingle();

    return response?['role']?.toString();
  }
}

