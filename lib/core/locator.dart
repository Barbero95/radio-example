import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:radio_example/core/local_storage_state.dart';

import 'logger.dart';

final GetIt locator = GetIt.instance;

class LocatorInjector {
  static Future<void> setUpLocator() async {
    Logger log = getLogger('Locator Injector');
    log.d('Registering Local Storage State');
    final localStorageState = LocalStorageState();
    await localStorageState.init();
    locator.registerLazySingleton(() => localStorageState);
  }
}
