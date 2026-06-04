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

  String paymentMethod = "Midtrans Full"; // default

  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    final apiService = ApiService();
    final prefs = await SharedPreferences.getInstance();

    final String? userRaw = prefs.getString('user');
    int userId = 0;

    if (userRaw != null) {
      userId = jsonDecode(userRaw)['id'] ?? 0;
    }

    double cleanPrice =
        double.tryParse(widget.harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

   List<String> listJam = widget.jam
    .split(',')
    .map((e) => e.trim())
    .where((e) => e.isNotEmpty)
    .toList();

if (listJam.isEmpty) {
  throw Exception("Jam tidak valid");
}

    String jamMulai = listJam.first;

    String jamTerakhir = listJam.last;
    int hourEnd = int.parse(jamTerakhir.split(':').first);
    String jamSelesai =
        "${(hourEnd + 1).toString().padLeft(2, '0')}:00";

    try {
      final result = await apiService.postBooking(
        userId: userId,
        lapanganId: widget.lapanganId,
        paymentMethod: paymentMethod, // 🔥 FIXED
        date: widget.tanggal,
        startTime: jamMulai,
        endTime: jamSelesai,
        totalPrice: cleanPrice,
        hours: listJam.length,
      );

      if (result['status'] == true) {
        if (mounted) {
          // =========================
          // CASH / OFFLINE
          // =========================
          if (paymentMethod == "Cash") {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/history',
              (route) => route.isFirst,
            );
            return;
          }

          // =========================
          // MIDTRANS (FULL / DP)
          // =========================
          if (result['redirect_url'] != null) {
            final payResult = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PaymentScreen(
                  paymentUrl: result['redirect_url'],
                ),
              ),
            );

            if (payResult != null && payResult == true) {
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/history',
                  (route) => route.isFirst,
                );
              }
            }
          } else {
            _showSnackBar("URL pembayaran tidak ditemukan", Colors.red);
          }
        }
      } else {
        _showSnackBar("Gagal: ${result['message']}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Koneksi error!", Colors.red);
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
              ),
              child: Column(
                children: [
                  _rowInfo("Lapangan", widget.namaLapangan),
                  const Divider(),
                  _rowInfo("Tanggal", widget.tanggal),
                  const Divider(),
                  _rowInfo("Jam", widget.jam),
                  const Divider(),
                  _rowInfo("Total", widget.harga, isPrice: true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Pilih Metode Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),

            RadioListTile(
              value: "Midtrans Full",
              groupValue: paymentMethod,
              title: const Text("Full Payment (Midtrans)"),
              onChanged: (v) {
                setState(() => paymentMethod = v.toString());
              },
            ),

            RadioListTile(
              value: "DP",
              groupValue: paymentMethod,
              title: const Text("DP 50%"),
              onChanged: (v) {
                setState(() => paymentMethod = v.toString());
              },
            ),

            RadioListTile(
              value: "Cash",
              groupValue: paymentMethod,
              title: const Text("Bayar di Tempat"),
              onChanged: (v) {
                setState(() => paymentMethod = v.toString());
              },
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _handlePayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A32A),
            minimumSize: const Size(double.infinity, 55),
          ),
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  "Bayar Sekarang",
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }

  Widget _rowInfo(String label, String value, {bool isPrice = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isPrice ? Colors.green : Colors.black,
          ),
        ),
      ],
    );
  }
}