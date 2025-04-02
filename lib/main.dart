import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:amrric_app/config/theme.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'package:amrric_app/config/test_data.dart';
import 'package:amrric_app/screens/login_screen.dart';
import 'package:amrric_app/screens/home_screen.dart';
import 'package:amrric_app/services/auth_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');
  
  try {
    // Initialize Upstash
    await UpstashConfig.initialize();
    
    runApp(
      const ProviderScope(
        child: AmrricApp(),
      ),
    );
  } catch (e, stackTrace) {
    print('Failed to initialize app: $e');
    print('Stack trace: $stackTrace');
    runApp(
      const ProviderScope(
        child: ErrorApp(),
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
