import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/config/theme.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/config/test_users.dart';
import 'package:amrric_app/screens/login_screen.dart';
import 'package:amrric_app/screens/home_screen.dart';
import 'package:amrric_app/services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Initialize Upstash
    await UpstashConfig.initialize();
    
    // Create test users
    await createTestUsers();
    
    runApp(
      const ProviderScope(
        child: AmrricApp(),
      ),
    );
  } catch (e) {
    print('Failed to initialize app: $e');
    // You might want to show an error screen or handle this differently
    runApp(
      const ProviderScope(
        child: ErrorApp(),
      ),
    );
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
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
              const Text(
                'Failed to connect to the server',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  // You might want to add retry logic here
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

class AmrricApp extends ConsumerWidget {
  const AmrricApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    return MaterialApp(
      title: 'AMRRIC',
      theme: AmrricTheme.theme,
      home: authState == null ? const LoginScreen() : const HomeScreen(),
    );
  }
}
