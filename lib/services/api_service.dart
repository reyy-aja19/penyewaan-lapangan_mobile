import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "http://192.168.1.15:8000/api";

  Future<Map<String, dynamic>> postBooking({
    required int userId,
    required int lapanganId,
    required String paymentMethod,
    required String date,
    required String startTime,
    required String endTime,
    required double totalPrice,
  }) async {
    final url = Uri.parse('$baseUrl/booking');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'lapangan_id': lapanganId,
          'payment_method': paymentMethod,
          'booking_date': date,
          'start_time': startTime,
          'end_time': endTime,
          'total_price': totalPrice,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {'status': false, 'message': 'Koneksi gagal: $e'};
    }
  }
}

