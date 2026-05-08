import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://sportsfield.cicd.my.id/api";

  // 1. POST BOOKING (Untuk Checkout)
  Future<Map<String, dynamic>> postBooking({
    required int userId,
    required int lapanganId,
    required String paymentMethod,
    required String date,
    required String startTime,
    required String endTime,
    required double totalPrice,
    required int hours,
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
          'hours': hours,
        }),
      );

      // Kita bungkus response-nya agar UI tahu ini sukses atau tidak
      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        return {'status': true, 'data': decoded};
      } else {
        return {'status': false, 'message': 'Gagal booking: ${response.statusCode}'};
      }
    } catch (e) {
      return {'status': false, 'message': 'Koneksi gagal: $e'};
    }
  }

  // 2. GET HISTORY (Untuk HistoryScreen)
  Future<List<dynamic>> getBookingHistory(int userId) async {
    final url = Uri.parse('$baseUrl/bookings?user_id=$userId');

    try {
      final response = await http.get(
        url,
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Pastikan key 'data' sesuai dengan JSON dari Laravel kamu
        return decoded['data'] ?? [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error Fetch History: $e");
      return [];
    }
  }
}