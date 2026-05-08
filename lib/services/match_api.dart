import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/match_model.dart';

class MatchApi {
  static const String baseUrl = 'https://sportsfield.cicd.my.id/api';

  static Future<List<MatchModel>> fetchMatches() async {
    final response = await http.get(Uri.parse('$baseUrl/matches'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      return (data['data'] as List)
          .map((json) => MatchModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Gagal mengambil data match');
    }
  }
}
