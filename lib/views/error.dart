import 'package:flutter/material.dart';

// Common
import 'package:radio_example/widgets/error_widget.dart';

//Página de Error

class ErrorView extends StatelessWidget {
  const ErrorView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: errorWidget(context)
    );
  }
}
