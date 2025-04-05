import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/config/theme.dart';
import 'package:amrric_app/config/routes.dart';
import 'package:amrric_app/screens/login_screen.dart';
import 'package:amrric_app/screens/home_screen.dart';
import 'package:amrric_app/services/auth_service.dart';
import 'package:amrric_app/services/council_service.dart';
import 'package:amrric_app/services/location_service.dart';
import 'package:amrric_app/services/animal_service.dart';
import 'package:amrric_app/config/test_data.dart' as test_data;
import 'package:amrric_app/config/upstash_config.dart';
import 'package:flutter/foundation.dart';

void main() async {
  try {
    debugPrint('Environment loaded successfully');
    await dotenv.load(fileName: ".env");
    debugPrint('Starting app initialization...');
    await UpstashConfig.initialize();
    debugPrint('Redis initialized successfully');
    debugPrint('Starting test data creation...');
    await test_data.createTestData();
    debugPrint('Test data created successfully');
    
    debugPrint('App initialization completed successfully');
    runApp(const ProviderScope(child: AmrricApp()));
  } catch (e) {
    debugPrint('Error during initialization: $e');
    rethrow;
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
      
      // Initialize Redis
      await UpstashConfig.initialize();
      debugPrint('Redis initialized successfully');
      
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
    // If there's an error, show the error screen
    if (_error != null) {
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
    return MaterialApp(
      title: 'AMRRIC',
      theme: AmrricTheme.theme,
      routes: routes,
      home: authState == null ? const LoginScreen() : const HomeScreen(),
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
