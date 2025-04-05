// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:amrric_app/main.dart';
import 'dart:io';

void main() {
  setUpAll(() async {
    final envFile = File('.env');
    if (!await envFile.exists()) {
      throw Exception('Environment file (.env) not found in root directory');
    }
    await dotenv.load(fileName: '.env');
  });

  testWidgets('App initializes correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const AmrricApp());
    
    // Initially, we should see the loading indicator
    expect(find.text('Initializing...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for the initialization to complete
    await tester.pumpAndSettle();
    
    // After initialization, we should see the login screen
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Login'), findsOneWidget);
  });
}
