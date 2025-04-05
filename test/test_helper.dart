import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:upstash_redis/upstash_redis.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'dart:io';

Future<Redis> setupTestRedis() async {
  // Load environment variables
  final envFile = File('.env');
  if (!await envFile.exists()) {
    throw Exception('Environment file (.env) not found in root directory');
  }
  await dotenv.load(fileName: '.env');
  
  // Initialize Redis
  return await UpstashConfig.initialize();
} 