import 'dart:async';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:radio_example/core/local_storage_state.dart';
import 'package:rive/rive.dart';

// Models
import 'package:radio_example/models/radio.dart';

// Common
import 'package:radio_example/core/locator.dart';
import 'package:radio_example/services/radio.dart';
import 'package:radio_example/utils/styles.dart';

// Widgets
import 'package:radio_example/widgets/radio_card.dart';

//Página principal de la aplicación, se carga una vez arranca la App
// - Pide el json que contine la info necesaria de las radios
// - Ordena por favoritos

class RadiosView extends StatelessWidget {
  const RadiosView({super.key});

  Future<List<RadioModel>> _future() async {
    List<String> favorites = locator<LocalStorageState>().favorites;
    List<RadioModel> radios = await RadioService().getRadios();
    //Si en el localStorage no hay favoritos procedo a devolver la lista de radios
    if (favorites.isEmpty) return radios;
    //Recorro la lista de cadenas de radio y asigno si es o no Favorita
    radios = radios.fold(<RadioModel>[], (previousValue, element) {
      if (favorites.isNotEmpty && favorites.contains(element.nombre)) {
        element.isFavorite = true;
      }
      previousValue.add(element);
      return previousValue;
    });
    //Ordena la lista con las favoritas primero
    radios.sort((a, b) {
      if (b.isFavorite) {
        return 1;
      }
      return -1;
    });
    return radios;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      //Como no hay Appbar añado safeArea para los touch bar
      body: SafeArea(
        child: FutureBuilder<List<RadioModel>>(
          future: _future(), //Pide las cadenas de radio
          builder: (_, AsyncSnapshot<List<RadioModel>> snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  //Título de la App
                  Padding(
                    padding: const EdgeInsets.only(top: 25.0),
                    child: Text('Radio Example', style: titleTextStyle),
                  ),
                  // Subtítulo
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 10, top: 30.0, right: 10, bottom: 7),
                    child: Text(
                      "Todas las emisoras",
                      style: subtitleTextStyle,
                    ),
                  ),
                  //Cargamos la lista de cadenas de radio
                  Expanded(
                    child: _RadiosViewBody(
                      radios: snapshot.data ?? [],
                    ),
                  )
                ],
              );
            } else if (snapshot.hasError) {
              //Error al pedir las radios
              return Center(
                child: Text(
                  "Error al obtener las radios",
                  style: normalTextStyle,
                ),
              );
            }
            //Animación de carga mientras se piden las radidos
            return Center(
              child: SizedBox(
                width: size.width * 0.65,
                height: size.height * 0.65,
                child: RiveAnimation.asset(
                  "assets/animations/radio.riv",
                  controllers: [SimpleAnimation('animation')],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RadiosViewBody extends StatefulWidget {
  final List<RadioModel> radios;

  const _RadiosViewBody({required this.radios});

  @override
  State<_RadiosViewBody> createState() => _RadiosViewBodyState();
}

class _RadiosViewBodyState extends State<_RadiosViewBody> {
  final _animatedListKey = GlobalKey<AnimatedListState>();
  final _animatedListController = ScrollController();
  late List<RadioModel> _radios;

  @override
  void initState() {
    super.initState();
    _radios = [];
    _loadRadios();
  }

  // Vamos añadiendo cada 200 milisengudos las cadenas para recrear la animación en la creación de la lista
  Future<void> _loadRadios() async {
    for (RadioModel item in widget.radios) {
      await Future.delayed(const Duration(milliseconds: 200));
      _radios.add(item);
      _animatedListKey.currentState?.insertItem(_radios.length - 1);
    }
  }

  //Función encargada de hacer el scroll
  void _animateTo(double to) {
    Timer(const Duration(milliseconds: 220), () {
      _animatedListController.animateTo(
        to,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  //Widget que contiene la acción de añadir o quitar una radio de mis favoritos
  Widget _getFavoriteButton(RadioModel radio, int index) {
    return IconButton(
      onPressed: () async {
        RadioModel radioRemoved = _radios.removeAt(index);
        _animatedListKey.currentState
            ?.removeItem(index, (_, animation) => Container());
        if (radio.isFavorite) {
          await radio.removeFavorite();
          _radios.add(radioRemoved);
          _animatedListKey.currentState?.insertItem(
            _radios.length - 1,
            duration: const Duration(milliseconds: 200),
          );
          _animateTo(_animatedListController.position.maxScrollExtent);
        } else {
          await radio.addFavorite();
          _radios.insert(0, radioRemoved);
          _animatedListKey.currentState?.insertItem(
            0,
            duration: const Duration(milliseconds: 200),
          );
          _animateTo(_animatedListController.position.minScrollExtent);
        }
      },
      icon: Icon(
        radio.isFavorite ? Icons.star : Icons.star_border_outlined,
        size: 30,
      ),
    );
  }

  //Función encargada de cambiar el estado de una radio,
  //cuando se ha modificado el estado de favorito dentro de la página de reproducción de una radio (selected_radio.dart)
  //Esta función es pasada a la card de la radio, que gestiona la navegación (push y pop)
  // - radio (modelo radio en el estado actual)
  // - index (posición dentro de la lista)
  // - newState (el estado como ha quedado una vez se hace pop de la pagina de reproducción de una emisora (selected_radio.dart)))
  Future<void> changeFavoriteState(
      RadioModel radio, int index, bool newState) async {
    //Si los dos estados no son iguales, significa que el usuario a modificado el estado de favortio y se debe realizar cambios en la lista
    if (radio.isFavorite != newState) {
      RadioModel radioRemoved = _radios.removeAt(index);
      _animatedListKey.currentState
          ?.removeItem(index, (_, animation) => Container());
      switch (newState) {
        case true:
          await radio.addFavorite();
          _radios.insert(0, radioRemoved);
          _animatedListKey.currentState?.insertItem(
            0,
            duration: const Duration(milliseconds: 200),
          );
          _animateTo(_animatedListController.position.minScrollExtent);
          break;
        case false:
          await radio.removeFavorite();
          _radios.add(radioRemoved);
          _animatedListKey.currentState?.insertItem(
            _radios.length - 1,
            duration: const Duration(milliseconds: 200),
          );
          _animateTo(_animatedListController.position.maxScrollExtent);
          break;
        default:
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _animatedListKey,
      controller: _animatedListController,
      itemBuilder: (context, index, animation) {
        RadioModel radio = _radios[index];
        return RadioCard(
          radio: radio,
          favoriteButton: _getFavoriteButton(radio, index),
          animation: animation,
          lastElement: index == _radios.length - 1,
          index: index,
          changeFavoriteState: changeFavoriteState,
        );
      },
    );
  }
}
