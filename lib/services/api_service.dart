import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // WAJIB ADA

class ApiService {
  static const String baseUrl = "https://sportsfield.my.id/api";

  /*
  |--------------------------------------------------------------------------
  | 1. POST BOOKING (Untuk Checkout)
  |--------------------------------------------------------------------------
  |*/
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
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token'); // Ambil token login

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // SURAT IZIN MASUK
        },
        body: jsonEncode({
          'user_id': userId,
          'lapangan_id': lapanganId,
          'payment_method': paymentMethod,
          'date': date, // REVISI: Diubah dari 'booking_date' menjadi 'date' agar pas dengan validasi Laravel
          'start_time': startTime,
          'end_time': endTime,
          'total_price': totalPrice,
          'hours': hours,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        // REVISI: Langsung return 'decoded' secara utuh (tidak dibungkus ke dalam objek 'data')
        // Agar properti 'status', 'redirect_url', dan 'current_points' terbaca langsung oleh CheckoutScreen
        return decoded;
      } else if (response.statusCode == 401) {
        return {'status': false, 'message': 'Sesi habis, silakan login ulang'};
      } else {
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
  |*/
  Future<List<dynamic>> getBookingHistory(int userId) async {
    final url = Uri.parse('$baseUrl/bookings');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token'); // Ambil token login

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // SURAT IZIN MASUK
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
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

  /*
  |--------------------------------------------------------------------------
  | 3. GET BOOKED SLOTS (Untuk Warnain Jam Merah)
  |--------------------------------------------------------------------------
  |*/
  Future<List<String>> getBookedSlots(int lapanganId, String tanggal) async {
    final url = Uri.parse(
      '$baseUrl/booked-slots?lapangan_id=$lapanganId&tanggal=$tanggal',
    );
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded['status'] == true) {
          List data = decoded['data'];
          return data.map((e) {
            String time = e['start_time'].toString();
            return time.length >= 5 ? time.substring(0, 5) : time;
          }).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error ambil jadwal: $e");
      return [];
    }
  }
}