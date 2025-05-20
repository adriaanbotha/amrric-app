import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:upstash_redis/upstash_redis.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

Future<RedisConnection> setupTestRedis() async {
  return RedisConfig.redis;
} 