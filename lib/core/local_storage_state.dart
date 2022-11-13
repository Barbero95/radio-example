import 'package:logger/logger.dart';
import 'package:radio_example/core/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageState {
  late List<String> _favorites;
  late Logger _log;

  List<String> get favorites => _favorites;

  LocalStorageState() {
    _log = getLogger('Local Storage State');
    _favorites = [];
  }

  Future<void> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _favorites = prefs.getStringList("favorites") ?? [];
    _log.d('Favorites Radios: $_favorites');
  }
}
