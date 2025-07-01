import '../screens/admin/location_management_screen.dart';
import '../screens/clinical_templates_screen.dart';

final routes = {
  // ... existing routes ...
  '/admin/locations': (context) => const LocationManagementScreen(),
  '/clinical-templates': (context) => const ClinicalTemplatesScreen(),
  // ... existing code ...
}; 