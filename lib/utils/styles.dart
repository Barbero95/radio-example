

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:radio_example/utils/colors.dart';

final titleTextStyle = GoogleFonts.openSans(
  fontSize: 40,
  fontWeight: FontWeight.bold,
  shadows: [
    const Shadow(
            offset: Offset(3, 3),
            color: darkColor,
            blurRadius: 10),
        Shadow(
            offset: const Offset(-1, -1),
            color: shadowLightColor.withOpacity(0.85),
            blurRadius: 10)
  ],
  color: Colors.grey.shade300,
);

final subtitleTextStyle = GoogleFonts.openSans(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: Colors.grey.shade300,
);

final radioNameTextStyle = GoogleFonts.openSans(
  fontSize: 20,
  color: Colors.grey.shade300,
);

final normalTextStyle = GoogleFonts.openSans(
  fontSize: 14,
  color: Colors.grey.shade300,
);