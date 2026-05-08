import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/field_model.dart';

class FieldService { // Ganti jadi FieldService biar sinkron sama HomeScreen
  static const String baseUrl = 'https://sportsfield.cicd.my.id/api';

  Future<List<FieldModel>> getFields() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/fields/read.php'));

      if (response.statusCode == 200) {
        List data = json.decode(response.body);
        return data.map((item) => FieldModel.fromJson(item)).toList();
      } else {
        print("Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error koneksi: $e");
      return [];
    }
  }
}