import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:radio_example/core/app_state.dart';
import 'package:radio_example/core/router.dart';
import 'package:radio_example/models/radio.dart';
import 'package:radio_example/utils/styles.dart';
import 'package:radio_example/utils/util.dart';

class RadioCard extends StatelessWidget {
  final RadioModel radio;
  final Widget favoriteButton;
  final Animation<double> animation;
  final bool lastElement;
  final int index;
  final Function changeFavoriteState;

  const RadioCard({
    super.key,
    required this.radio,
    required this.favoriteButton,
    required this.animation,
    required this.lastElement,
    required this.index,
    required this.changeFavoriteState,
  });

  @override
  Widget build(BuildContext context) {
    //Efecto de entrada para la card de la cadena de radio
    //Incremento de 0 a 100% del tamaño de widget
    return SizeTransition(
      axis: Axis.vertical,
      sizeFactor: animation,
      child: Padding(
        padding: EdgeInsets.only(
            left: 8, top: 4, right: 8, bottom: lastElement ? 15 : 4),
        child: Neumorphic(
          style: NeumorphicStyle(
            depth: 3,
            intensity: 0.4,
            boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(8)),
          ),
          child: NeumorphicButton(
            padding: const EdgeInsets.all(12.0),
            onPressed: () async {
              context.read<AppState>().changeRadio(RadioModel.copy(radio));
              final result =
                  await Navigator.pushNamed(context, selectedRadioRoute);
              if (result != null) {
                await changeFavoriteState(radio, index, result);
              }
            },
            style: NeumorphicStyle(
                depth: -1,
                boxShape:
                    NeumorphicBoxShape.roundRect(BorderRadius.circular(8))),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Imagen de la cadena de radio
                Neumorphic(
                  style: const NeumorphicStyle(
                    depth: 2,
                    intensity: 0.4,
                    boxShape: NeumorphicBoxShape.circle(),
                  ),
                  child: radio.imageUrl != null
                      ? SizedBox(
                          width: 55,
                          height: 55,
                          child: Image.asset("assets/images/${radio.imageUrl}",
                              errorBuilder: (context, error, stackTrace) =>
                                  defaultImage),
                        )
                      : defaultImage,
                ),
                // Nombre de la cadena de radio
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(radio.nombre, style: radioNameTextStyle,),
                  ),
                ),
                // Favorite Button: Cargarmos el widget pasado por parámetro, para marcar o desmarcar una cadena de radio
                favoriteButton,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
