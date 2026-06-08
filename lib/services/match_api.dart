import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_model.dart';

class MatchApi {
  static const String baseUrl = 'https://sportsfield.my.id/api';

  /*
  |--------------------------------------------------------------------------
  | GET ALL OPEN MATCHES
  |--------------------------------------------------------------------------
  |*/
  static Future<List<MatchModel>> fetchMatches() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('$baseUrl/matches'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Menangani response jika dibungkus dalam key 'data' atau berbentuk list langsung
        final List listData = (data is Map) ? data['data'] : data;

        return listData.map((json) => MatchModel.fromJson(json)).toList();
      } else {
        throw Exception('Gagal mengambil data match: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception saat fetch matches: $e');
      rethrow;
    }
  }

  /*
  |--------------------------------------------------------------------------
  | CREATE OPEN MATCH
  |--------------------------------------------------------------------------
  |*/
  static Future<bool> createMatch(MatchModel match) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/matches'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(match.toJson()),
      );

      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      print('Exception saat create match: $e');
      return false;
    }
  }

  /*
  |--------------------------------------------------------------------------
  | JOIN AN OPEN MATCH (Menangkap Response Pesan Dinamis dari Backend)
  |--------------------------------------------------------------------------
  |*/
  static Future<Map<String, dynamic>> joinMatch(int matchId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.post(
        Uri.parse('$baseUrl/matches/$matchId/join'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Mengubah string JSON dari body response menjadi Map
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Berhasil bergabung ke dalam match!',
        };
      } else {
        // Mengembalikan pesan error spesifik yang dikirim oleh Controller Laravel
        return {
          'success': false,
          'message': data['message'] ?? 'Gagal bergabung ke match.',
        };
      }
    } catch (e) {
      print('Exception saat join match: $e');
      return {
        'success': false,
        'message': 'Terjadi kesalahan koneksi atau server: $e',
      };
    }
  }
}