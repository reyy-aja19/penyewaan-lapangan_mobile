import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL VPS kamu
  static const String baseUrl = "https://sportsfield.cicd.my.id/api";

  /*
  |--------------------------------------------------------------------------
  | 1. POST BOOKING (Untuk Checkout)
  |--------------------------------------------------------------------------
  */
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

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'status': true, 'data': decoded};
      } else {
        // Mengambil pesan error dari Laravel jika ada (misal: jadwal bentrok)
        String errorMessage = decoded['message'] ?? 'Gagal booking';
        return {'status': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'status': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /*
  |--------------------------------------------------------------------------
  | 2. GET HISTORY (Untuk HistoryScreen)
  |--------------------------------------------------------------------------
  */
  Future<List<dynamic>> getBookingHistory(int userId) async {
    // Sesuai hasil route:list dan Postman tadi, rutenya adalah /bookings
    final url = Uri.parse('$baseUrl/bookings'); 

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        // Laravel mengembalikan status: true dan data: [...]
        if (decoded['status'] == true) {
          return decoded['data'] ?? [];
        }
        return [];
      } else {
        print("Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Koneksi Gagal: $e");
      return [];
    }
  }
}

