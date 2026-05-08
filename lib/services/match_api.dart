import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/match_model.dart';

class MatchApi {
  static const String baseUrl = 'https://sportsfield.cicd.my.id/api';

  // Ambil semua data match
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

  // Langkah 1: Create Match
  static Future<bool> createMatch(MatchModel match) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/matches'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        // Mengirimkan data dalam bentuk JSON menggunakan toJson() yang kita buat tadi
        body: jsonEncode(match.toJson()),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else {
        print('Error status: ${response.statusCode}');
        print('Error body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception saat create match: $e');
      return false;
    }
  }

  // Langkah 2: Join Match
  static Future<bool> joinMatch(int matchId) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/matches/$matchId/join'),
        headers: {
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Gagal join: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exception saat join match: $e');
      return false;
    }
  }
}