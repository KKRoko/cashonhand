import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import '../../data/database/database.dart';
import 'package:flutter/foundation.dart';
import 'injection.config.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() => getIt.init();

@module
abstract class DatabaseModule {
  @singleton
  Database provideDatabase() => Database();
}