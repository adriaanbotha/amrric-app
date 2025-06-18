import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/config/theme.dart';
import 'package:amrric_app/config/routes.dart';
import 'package:amrric_app/screens/login_screen.dart';
import 'package:amrric_app/screens/home_screen.dart';
import 'package:amrric_app/screens/admin/animal_management_screen.dart';
import 'package:amrric_app/screens/medication_screen.dart';
import 'package:amrric_app/screens/reports_screen.dart';
import 'package:amrric_app/screens/settings_screen.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/services/council_service.dart';
import 'package:amrric_app/services/location_service.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/config/test_data.dart' as test_data;
import 'package:amrric_app/config/upstash_config.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:amrric_app/models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Hive
    final appDocumentDir = await getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
    
    // Register Hive adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserRoleAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserAdapter());
    }
    
    // Open Hive boxes
    await Hive.openBox<User>('users');
    
    // Initialize Upstash
    await UpstashConfig.initialize();
    
    runApp(const ProviderScope(child: AmrricApp()));
  } catch (e, stack) {
    debugPrint('Error during initialization: $e');
    debugPrint('Stack trace: $stack');
    runApp(const ErrorApp());
  }
}

class AmrricApp extends ConsumerStatefulWidget {
  const AmrricApp({super.key});

  @override
  ConsumerState<AmrricApp> createState() => _AmrricAppState();
}

class _AmrricAppState extends ConsumerState<AmrricApp> {
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      debugPrint('Starting app initialization...');
      setState(() {
        _isInitialized = true;
        _error = null;
      });
      debugPrint('App initialization completed successfully');
    } catch (e, stack) {
      debugPrint('Error during initialization: $e');
      debugPrint('Stack trace: $stack');
      setState(() {
        _isInitialized = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Building AmrricApp: _isInitialized=$_isInitialized, _error=$_error');
    // If there's an error, show the error screen
    if (_error != null) {
      debugPrint('Error screen branch');
      return MaterialApp(
        title: 'AMRRIC - Error',
        theme: AmrricTheme.theme,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Failed to initialize: $_error',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isInitialized = false;
                    });
                    _initializeApp();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // If not initialized, show loading screen
    if (!_isInitialized) {
      debugPrint('Loading screen branch');
      return MaterialApp(
        title: 'AMRRIC',
        theme: AmrricTheme.theme,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Initializing...', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      );
    }

    // App is initialized, show main app
    final authState = ref.watch(authStateProvider);
    debugPrint('main.dart: authState is $authState');
    if (authState == null) {
      debugPrint('Login screen branch');
    } else {
      debugPrint('Home screen branch');
    }
    return MaterialApp(
      title: 'AMRRIC',
      theme: AmrricTheme.theme,
      routes: {
        '/login': (context) => LoginScreen(),
        '/animals': (context) => RoleGuard(
          allowedRoles: [UserRole.systemAdmin, UserRole.veterinaryUser, UserRole.censusUser],
          routeName: '/animals',
          child: AnimalManagementScreen(),
        ),
        '/medications': (context) => RoleGuard(
          allowedRoles: [UserRole.systemAdmin, UserRole.veterinaryUser],
          routeName: '/medications',
          child: MedicationScreen(),
        ),
        '/reports': (context) => ReportsScreen(),
        '/settings': (context) => SettingsScreen(),
      },
      home: authState == null ? LoginScreen() : HomeScreen(),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AMRRIC - Error',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to connect to the server',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  main();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Role-based route guard
class RoleGuard extends ConsumerWidget {
  final Widget child;
  final List<UserRole> allowedRoles;
  final String routeName;

  const RoleGuard({
    super.key,
    required this.child,
    required this.allowedRoles,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    if (authState == null) {
      // User not logged in, redirect to login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!allowedRoles.contains(authState.role)) {
      // User doesn't have permission, show access denied
      return Scaffold(
        appBar: AppBar(title: const Text('Access Denied')),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'You do not have permission to access this page.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return child;
  }
}
