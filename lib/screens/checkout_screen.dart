import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:penyewaan_lapangan/services/api_service.dart';
import 'package:penyewaan_lapangan/screens/payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final int lapanganId;
  final String namaLapangan;
  final String tanggal;
  final String jam;
  final String harga;

  const CheckoutScreen({
    super.key,
    required this.lapanganId,
    required this.namaLapangan,
    required this.tanggal,
    required this.jam,
    required this.harga,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    final apiService = ApiService();
    final prefs = await SharedPreferences.getInstance();

    final String? userRaw = prefs.getString('user');
    int userId = 0;
    if (userRaw != null) {
      userId = jsonDecode(userRaw)['id'] ?? 0;
    }

    // Bersihkan harga: Rp 180.000 -> 180000
    double cleanPrice =
        double.tryParse(widget.harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    // ==================== FIX LOGIKA JAM DI SINI ====================
    // Pisahkan string "08:00, 09:00" menjadi List ['08:00', '09:00']
    List<String> listJam = widget.jam.split(',').map((e) => e.trim()).toList();
    
    String jamMulai = listJam.first; // Mengambil jam paling awal (Contoh: "08:00")
    String jamSelesai = "";

    if (listJam.length > 1) {
      // Jika booking lebih dari 1 jam, ambil jam terakhir (Contoh: "09:00") 
      // Lalu asumsikan durasinya sampai jam berikutnya (Contoh: "10:00")
      String jamTerakhir = listJam.last;
      int hour = int.parse(jamTerakhir.split(':').first);
      jamSelesai = "${(hour + 1).toString().padLeft(2, '0')}:00"; 
    } else {
      // Jika cuma booking 1 jam
      int hour = int.parse(jamMulai.split(':').first);
      jamSelesai = "${(hour + 1).toString().padLeft(2, '0')}:00";
    }
    // ================================================================

    try {
      final result = await apiService.postBooking(
        userId: userId,
        lapanganId: widget.lapanganId,
        paymentMethod: "Midtrans", 
        date: widget.tanggal,
        startTime: jamMulai,      // Hasil perbaikan: "08:00"
        endTime: jamSelesai,      // Hasil perbaikan: "10:00"
        totalPrice: cleanPrice,
        hours: listJam.length,    // Jumlah durasi jam
      );

      if (result['status'] == true) {
        if (userRaw != null) {
          Map<String, dynamic> userData = jsonDecode(userRaw);
          userData['points'] =
              result['current_points'] ?? (userData['points'] ?? 0) + 5;
          await prefs.setString('user', jsonEncode(userData));
        }

        if (mounted) {
          if (result['redirect_url'] != null) {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PaymentScreen(
                  paymentUrl: result['redirect_url'],
                ),
              ),
            );

            if (mounted) {
              Navigator.pushNamedAndRemoveUntil(
                context, 
                '/history', 
                (route) => route.isFirst,
              );
            }
          } else {
            _showSnackBar("URL Pembayaran tidak ditemukan.", Colors.red);
          }
        }
      } else {
        _showSnackBar("Gagal: ${result['message']}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Koneksi Error!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Pesanan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ringkasan Pesanan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _rowInfo("Lapangan", widget.namaLapangan),
                  const Divider(height: 30),
                  _rowInfo("Tanggal", widget.tanggal),
                  const Divider(height: 30),
                  _rowInfo("Jam", widget.jam),
                  const Divider(height: 30),
                  _rowInfo("Total Bayar", widget.harga, isPrice: true),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Pilih metode pembayaran favoritmu di halaman selanjutnya.",
                      style: TextStyle(fontSize: 13, color: Colors.blueAccent),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildPayButton(context),
    );
  }

  Widget _rowInfo(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isPrice ? 18 : 14,
              color: isPrice ? const Color(0xFF00A32A) : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A32A),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                "Lanjut ke Pembayaran",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}