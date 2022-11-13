import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:radio_example/core/app_state.dart';
import 'package:radio_example/models/radio.dart';
import 'package:radio_example/views/error.dart';
import 'package:radio_example/views/radios.dart';
import 'package:radio_example/views/selected_radio.dart';

final Map<String, Widget Function(BuildContext)> router = {
  // Home: Lista de las radios disponibles
  radiosRoute: (context) => const RadiosView(),
  // Reproductor del stream de la radio seleccionada
  selectedRadioRoute: (context) {
    RadioModel? radio = context.read<AppState>().selectedradio;
    if (radio == null) {
      return const ErrorView();
    }
    return SelectedRadioView(radio: radio);
  },
  errorRoute: (context) => const ErrorView(),
};

const String radiosRoute = "/";
const String selectedRadioRoute = "/selected-radio";
const String errorRoute = "/error";
