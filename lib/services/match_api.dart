import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Tambahin ini
import '../models/match_model.dart';

class MatchApi {
  static const String baseUrl = 'https://sportsfield.my.id/api';

  // Ambil semua data match
  static Future<List<MatchModel>> fetchMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(
      'token',
    ); // Ambil token yang lo simpen pas login

    final response = await http.get(
      Uri.parse('$baseUrl/matches'),
      headers: {
        'Authorization':
            'Bearer $token', // WAJIB ADA karena rute ini diproteksi Sanctum
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Sesuaikan dengan response Laravel lo (apakah dibungkus key 'data' atau langsung list)
      final List listData = (data is Map) ? data['data'] : data;

      return listData.map((json) => MatchModel.fromJson(json)).toList();
    } else {
      throw Exception('Gagal mengambil data match: ${response.statusCode}');
    }
  }

  // Create Match
  static Future<bool> createMatch(MatchModel match) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/matches'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Tambahin token juga di sini
        },
        body: jsonEncode(match.toJson()),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Exception saat create match: $e');
      return false;
    }
  }

  // Join Match
  static Future<bool> joinMatch(int matchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/matches/$matchId/join'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Tambahin token juga di sini
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Exception saat join match: $e');
      return false;
    }
  }
}
