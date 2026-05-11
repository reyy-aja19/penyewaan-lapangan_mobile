import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:penyewaan_lapangan/services/api_service.dart';

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
  String _selectedMethod = "Transfer Bank (VA)";
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

    // --- DEBUGGING LOG ---
    print("--- DEBUG CHECKOUT ---");
    print("Lapangan ID: ${widget.lapanganId}");
    print("Tanggal: ${widget.tanggal}");
    print("Jam (Raw): ${widget.jam}");
    print("Total Harga: $cleanPrice");
    print("----------------------");

    try {
      // KIRIM JAM APA ADANYA ("08:00, 09:00")
      // Laravel lo butuh string ini utuh buat di-explode
      final result = await apiService.postBooking(
        userId: userId,
        lapanganId: widget.lapanganId,
        paymentMethod: _selectedMethod,
        date: widget.tanggal,
        startTime: widget.jam, // Jangan di-split di sini, kirim utuh!
        endTime: "", // Laravel bakal hitung otomatis per jam
        totalPrice: cleanPrice,
        hours: widget.jam.split(',').length,
      );

      if (result['status'] == true) {
        // Update poin di memori lokal (opsional kalau lo mau lgsg refresh dari API)
        if (userRaw != null) {
          Map<String, dynamic> userData = jsonDecode(userRaw);
          // Ambil poin terbaru dari response API jika ada, atau tambah manual +5
          userData['points'] =
              result['current_points'] ?? (userData['points'] ?? 0) + 5;
          await prefs.setString('user', jsonEncode(userData));
        }

        if (mounted) _showSuccessDialog(context);
      } else {
        _showSnackBar("Gagal: ${result['message']}", Colors.red);
      }
    } catch (e) {
      print("Error Payment: $e");
      _showSnackBar("Koneksi Error!", Colors.red);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Konfirmasi Pembayaran",
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
                  _rowInfo("Total Harga", widget.harga, isPrice: true),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Metode Pembayaran",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 15),
            _buildMethodOption("Transfer Bank (VA)", Icons.account_balance),
            _buildMethodOption(
              "E-Wallet (Dana/OVO)",
              Icons.account_balance_wallet,
            ),
            _buildMethodOption("Tunai di Tempat", Icons.payments_outlined),
          ],
        ),
      ),
      bottomNavigationBar: _buildPayButton(context),
    );
  }

  Widget _buildMethodOption(String title, IconData icon) {
    bool isSelected = _selectedMethod == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF00A32A) : Colors.transparent,
            width: 2,
          ),
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: isSelected ? const Color(0xFF00A32A) : Colors.grey,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF00A32A) : Colors.black87,
            ),
          ),
          trailing: Icon(
            isSelected ? Icons.check_circle : Icons.circle_outlined,
            color: isSelected ? const Color(0xFF00A32A) : Colors.grey,
          ),
        ),
      ),
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
            : Text(
                "Bayar dengan $_selectedMethod",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF00A32A), size: 80),
            const SizedBox(height: 20),
            const Text(
              "Pembayaran Berhasil!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            const Text(
              "Poin kamu bertambah +5!",
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Silakan tunjukkan kode booking saat tiba.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A32A),
                ),
                child: const Text(
                  "Kembali ke Beranda",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
