import 'package:dhakaiadine/routes/app_router.dart';
import 'package:dhakaiadine/services/rbac_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RBAC routing', () {
    test('routes admin roles to the admin dashboard', () {
      expect(RbacService.homeRouteForRole('admin'), AppRouter.adminDashboard);
      expect(RbacService.homeRouteForRole('manager'), AppRouter.adminDashboard);
      expect(RbacService.homeRouteForRole('kitchen'), AppRouter.adminDashboard);
      expect(RbacService.homeRouteForRole('counter'), AppRouter.adminDashboard);
    });

    test('routes customers to the customer home screen', () {
      expect(RbacService.homeRouteForRole('customer'), AppRouter.home);
      expect(RbacService.homeRouteForRole(null), AppRouter.home);
    });
  });
}
