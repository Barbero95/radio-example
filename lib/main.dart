import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:provider/provider.dart';
import 'package:radio_example/core/app_state.dart';
import 'package:radio_example/core/locator.dart';
import 'package:radio_example/core/router.dart';
import 'package:radio_example/utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //Inizializo Singleton
  await LocatorInjector.setUpLocator();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: const NeumorphicThemeData(
        baseColor: darkColor,
        shadowLightColor: shadowLightColor,
        lightSource: LightSource.topLeft,
        depth: 4,
        iconTheme: IconThemeData(color: whiteColor),
      ),
      title: 'Radio Example',
      initialRoute: radiosRoute,
      routes: router,
    );
  }
}
