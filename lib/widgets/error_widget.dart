import 'package:flutter/material.dart';

// Common
import 'package:radio_example/core/router.dart';
import 'package:radio_example/utils/colors.dart';
import 'package:radio_example/utils/styles.dart';


//Widget encargado de avisar que se ha producido un error y proporciona la opción de volver al inicio de la aplicación

Widget errorWidget(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.radio,
          size: 40,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 15),
          child: Text(
            "Lo sentimos, ha ocurrido un error.",
            style: normalTextStyle,
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
            context,
            radiosRoute,
            (Route<dynamic> route) => false,
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: darkColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade300, width: 1.3),
          borderRadius: BorderRadius.circular(7.0),
          
        ),
          ),
          child: Text(
            "Volver al inicio",
            style: normalTextStyle,
          ),
        )
      ],
    ),
  );
}
