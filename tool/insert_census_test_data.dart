import 'package:amrric_app/config/test_data.dart';
import 'package:amrric_app/config/upstash_config.dart';
import 'dart:async';

Future<void> main() async {
  await UpstashConfig.initialize();
  await createTestCensusAnimals();
  print('Inserted 19 census animal records into Upstash.');
} 