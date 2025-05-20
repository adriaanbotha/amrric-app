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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  
  // Initialize Upstash
  await UpstashConfig.initialize();
  
  runApp(const ProviderScope(child: AmrricApp()));
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
        '/animals': (context) => AnimalManagementScreen(),
        '/medications': (context) => MedicationScreen(),
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
