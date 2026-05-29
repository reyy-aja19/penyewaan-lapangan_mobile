import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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

  /*
  |--------------------------------------------------------------------------
  | POST CREATE OPEN MATCH
  |--------------------------------------------------------------------------
  |*/
  Future<Map<String, dynamic>> createOpenMatch({
    required int bookingId,
    required String title,
    required String jenis,
    required String tanggal,
    required int jumlahPemain,
    String? startTime,
    String? endTime,
    String? deskripsi,
  }) async {
    final url = Uri.parse('$baseUrl/open-match'); // Sesuaikan dengan route API kamu
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'booking_id': bookingId,
          'title': title,
          'jenis': jenis,
          'tanggal': tanggal,
          'jumlah_pemain': jumlahPemain,
          'start_time': startTime ?? '',
          'end_time': endTime ?? '',
          'deskripsi': deskripsi ?? '',
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return decoded; // Berhasil dibuat
      } else {
        String errorMessage = decoded['message'] ?? 'Gagal membuat open match';
        return {'status': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'status': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /*
  |--------------------------------------------------------------------------
  | 4. REWARDS MANAGEMENT (Untuk PointScreen)
  |--------------------------------------------------------------------------
  |*/
  
  /// Ambil daftar reward dari database Laravel
  Future<Map<String, dynamic>> getRewards() async {
    final url = Uri.parse('$baseUrl/rewards');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Membawa token user yang login
        },
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return decoded;
      } else {
        String errorMessage = decoded['message'] ?? 'Gagal mengambil daftar reward';
        return {'status': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'status': false, 'message': 'Terjadi kesalahan koneksi: $e'};
    }
  }

  /// Post klaim penukaran reward ke backend Laravel
  Future<Map<String, dynamic>> redeemReward({required int rewardId}) async {
    final url = Uri.parse('$baseUrl/rewards/redeem');
    final prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token', // Membawa token user yang login
        },
        body: jsonEncode({
          'reward_id': rewardId,
        }),
      );

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return decoded;
      } else {
        String errorMessage = decoded['message'] ?? 'Gagal menukarkan reward';
        return {'status': false, 'message': errorMessage};
      }
    } catch (e) {
      return {'status': false, 'message': 'Terjadi kesalahan koneksi saat menukar: $e'};
    }
  }
}