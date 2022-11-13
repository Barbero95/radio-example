import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:flutter_svg/svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import 'package:radio_example/utils/styles.dart';
import 'package:radio_example/widgets/error_widget.dart';
import 'package:rive/rive.dart';

// Models
import 'package:radio_example/models/radio.dart';

// Common
import 'package:radio_example/core/app_state.dart';
import 'package:radio_example/core/logger.dart';
import 'package:radio_example/utils/colors.dart';
import 'package:radio_example/utils/util.dart';

//Página encargada de reproducir el streaming de una cadena/emisora de radio

class SelectedRadioView extends StatefulWidget {
  final RadioModel radio;

  const SelectedRadioView({super.key, required this.radio});

  @override
  State<SelectedRadioView> createState() => _SelectedRadioViewState();
}

class _SelectedRadioViewState extends State<SelectedRadioView> {
  late RiveAnimationController _controller;
  final _audioPlayer = AudioPlayer();
  late Logger _log;
  late bool _mute;
  late bool _error;

  @override
  void initState() {
    super.initState();
    // Inicializamos el logger
    _log = getLogger('Radio Selected: ${widget.radio.nombre}}');
    // Inicializamos variables
    _mute = false;
    _error = false;
    // Inicializamos el gestor del streaming de la radio
    _init();
    // Inicializamos el controlador de la animación
    _controller = SimpleAnimation('animation', autoplay: false);
    
  }

  Future<void> _init() async {
    try {
      //Cargamos la url del stream
      await _audioPlayer
          .setAudioSource(AudioSource.uri(Uri.parse(widget.radio.url)));
    } catch (e) {
      _log.d('Error loading audio source: $e');
      _error = true;
    }

    //Escuchamos todas las acciones en el stream
    _audioPlayer.playerStateStream.listen((playerState) {
      _log.d(
          "Player state: - Processing State (${playerState.processingState}) - IsPlaying (${playerState.playing})");
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      //Se ha puesto el mounted, ya que en el momento que salimos y salta el dispose del audio player,
      //no disponemos de contexto pero el listen nos da un nuevo estado y no puede acudir al provider,
      //ya que no se dispone de contexto
      if (mounted) {
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          context.read<AppState>().changeButtonState(ButtonState.loading);
        } else if (!isPlaying) {
          context.read<AppState>().changeButtonState(ButtonState.paused);
        } else if (processingState != ProcessingState.completed) {
          context.read<AppState>().changeButtonState(ButtonState.playing);
        } else {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.pause();
          _pauseAnimation();
          context.read<AppState>().changeButtonState(ButtonState.paused);
        }
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _pauseAnimation() {
    setState(() => _controller.isActive = false);
  }

  void _playAnimation() {
    setState(() => _controller.isActive = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            //Devolvemos el estado de favorito de la radio
            Navigator.of(context).pop(widget.radio.isFavorite);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text(
          widget.radio.nombre,
          style: radioNameTextStyle,
        ),
      ),
      body: Center(
        child: !_error
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  StreamBuilder<IcyMetadata?>(
                    stream: _audioPlayer.icyMetadataStream,
                    builder: (context, snapshot) {
                      return _imagenWidget;
                    },
                  ),
                  //Barra de gestión de la radio
                  _gestionWidget,
                ],
              )
            : errorWidget(context),
      ),
    );
  }

  //Imagen de la cadena y animación
  Widget get _imagenWidget => SizedBox(
        width: 250,
        height: 250,
        child: Stack(
          children: [
            //Suporponemos la animación con la imagen de la cadena de radio
            RiveAnimation.asset(
              "assets/animations/image.riv",
              controllers: [_controller],
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 3, top: 7),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(150.0),
                  child: SizedBox(
                    width: 203,
                    height: 203,
                    child: widget.radio.imageUrl != null
                        ? SizedBox(
                            width: 55,
                            height: 55,
                            child: Image.asset(
                                "assets/images/${widget.radio.imageUrl}",
                                errorBuilder: (context, error, stackTrace) =>
                                    defaultImage),
                          )
                        : defaultImage,
                  ),
                ),
              ),
            )
          ],
        ),
      );

  Widget get _gestionWidget => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  if (widget.radio.isFavorite) {
                    widget.radio.removeFavorite();
                  } else {
                    widget.radio.addFavorite();
                  }
                });
              },
              child: Icon(
                widget.radio.isFavorite
                    ? Icons.star
                    : Icons.star_border_outlined,
                size: 35,
              ),
            ),
            if (!_error)
              _buttonState()
            else
              Text(
                "Error al cargar la radio",
                style: normalTextStyle,
              ),
            GestureDetector(
              onTap: () {
                setState(() => _mute = !_mute);
                _audioPlayer.setVolume(_mute ? 0 : 1);
              },
              child: SvgPicture.asset(
                "assets/svgs/volume-${!_mute ? "xmark" : "high"}-solid.svg",
                width: 35,
                height: 35,
                color: whiteColor,
              ),
            )
          ],
        ),
      );

  Widget _buttonState() {
    switch (context.watch<AppState>().buttonNotifier) {
      case ButtonState.loading:
        return Container(
          margin: const EdgeInsets.all(8.0),
          width: 45.0,
          height: 45.0,
          child: const CircularProgressIndicator(),
        );
      case ButtonState.paused:
        return NeumorphicRadio(
          padding: const EdgeInsets.all(20),
          style: const NeumorphicRadioStyle(
            shape: NeumorphicShape.flat,
            boxShape: NeumorphicBoxShape.circle(),
          ),
          value: true,
          onChanged: (bool? state) {
            _audioPlayer.play();
            _playAnimation();
          },
          child: const Icon(
            Icons.play_arrow,
            size: 55,
          ),
        );
      case ButtonState.playing:
        return NeumorphicRadio(
          padding: const EdgeInsets.all(20),
          style: const NeumorphicRadioStyle(
              shape: NeumorphicShape.flat,
              boxShape: NeumorphicBoxShape.circle(),
              selectedColor: Colors.white70),
          value: false,
          groupValue: false,
          onChanged: (bool? state) {
            _audioPlayer.pause();
            _pauseAnimation();
          },
          child: const Icon(
            Icons.pause,
            size: 55,
            color: darkColor,
          ),
        );
    }
  }
}
