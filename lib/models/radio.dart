import 'package:shared_preferences/shared_preferences.dart';

class RadioModel {
  late String nombre;
  late String url;
  String? imageUrl;
  bool isFavorite = false;

  RadioModel(
    this.nombre,
    this.url,
    this.imageUrl,
  );

  RadioModel.fromJson(Map<dynamic, dynamic> json) {
    if (json.isNotEmpty) {
      nombre = json['nombre'];
      url = json['url'];
      imageUrl = json['image'];
    }
  }

  RadioModel.copy(RadioModel radio) {
    nombre = radio.nombre;
    url = radio.url;
    imageUrl = radio.imageUrl;
    isFavorite = radio.isFavorite;
  }

  Future<void> addFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> favorites =
        Set<String>.from(prefs.getStringList("favorites") ?? []);
    isFavorite = true;
    favorites.add(nombre);
    await prefs.setStringList("favorites", favorites.toList());
  }

  Future<void> removeFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Set<String> favorites =
        Set<String>.from(prefs.getStringList("favorites") ?? []);
    isFavorite = false;
    favorites.remove(nombre);
    await prefs.setStringList("favorites", favorites.toList());
  }
}
