import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:radio_example/core/logger.dart';
import 'package:radio_example/models/radio.dart';

// Los distintos estados del botón de reproducción
enum ButtonState { paused, playing, loading }

class AppState with ChangeNotifier {
  RadioModel? _selectedradio;
  late ButtonState buttonNotifier;
  late Logger _log;

  RadioModel? get selectedradio => _selectedradio;

  AppState() {
    _log = getLogger('App State');
    buttonNotifier = ButtonState.loading;
  }

  void changeRadio(RadioModel radio) {
    _log.d('Change Radio: ${radio.nombre}');
    _selectedradio = radio;
     buttonNotifier = ButtonState.loading;
  }

  void changeButtonState(ButtonState newState) {
    _log.d('Change Button state: $newState');
    buttonNotifier = newState;
    notifyListeners();
  }
}
