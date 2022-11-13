import 'dart:convert';

import 'package:radio_example/models/radio.dart';
import 'package:http/http.dart' as http;
import 'package:radio_example/utils/util.dart';

class RadioService {
  Future<List<RadioModel>> getRadios() async {
    final url = Uri.parse('https://academiavoleibolbcn.web.app/radios.json');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = json.decode(response.body);
      if (body != null &&
          body["error"] == false &&
          body["data"] != null &&
          body["data"].isNotEmpty) {
        List<RadioModel> radios =
            body["data"].fold(<RadioModel>[], (previousValue, element) {
          if (element.containsKey("nombre") &&
              verificationString(element["nombre"]) &&
              element.containsKey("url") &&
              verificationString(element["url"])) {
            previousValue.add(RadioModel.fromJson(element));
          }
          return previousValue;
        });
        return Future.delayed(const Duration(seconds: 4), () {
          return radios;
        });
      }
    }

    return [];
  }
}
