import 'dart:convert' as convert;

import 'package:flutter_dotenv/flutter_dotenv.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;
import 'package:leggo/model/google_place.dart';
import 'package:leggo/model/place_search.dart';

class PlacesRepository {
  var mag = dotenv.get('GOOGLE_PLACES_API_KEY');

  Future<List<PlaceSearch>> getAutoComplete(String search) async {
    // &types=(cities)
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=establishment&key=$mag');

    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((e) => PlaceSearch.fromJson(e)).toList();
  }

  Future<List<PlaceSearch>> getAutoCompleteRegionsAndCities(
      String search) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$search&types=(regions)&types=(cities)&key=$mag');

    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['predictions'] as List;
    return jsonResults.map((e) => PlaceSearch.fromJson(e)).toList();
  }

  Future<GooglePlace> getPlace(String placeId) async {
    var url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/details/json?key=$mag&place_id=$placeId');

    var response = await http.get(url);
    var json = convert.jsonDecode(response.body);
    var jsonResults = json['result'] as Map<String, dynamic>;
    return GooglePlace.fromJson(jsonResults);
  }
}
