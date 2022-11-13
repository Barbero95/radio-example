import 'package:flutter/material.dart';

bool verificationString(dynamic value) {
  return value != null && value is String && value.trim().isNotEmpty;
}

Widget get defaultImage => const Padding(
      padding: EdgeInsets.all(12),
      child: Icon(
        Icons.image_rounded,
        size: 20,
      ),
    );
