import 'package:flutter/material.dart';
import 'package:penyewaan_lapangan/services/api_service.dart'; // Sesuaikan dengan nama project kamu

class CheckoutScreen extends StatefulWidget {
  final String namaLapangan;
  final String tanggal;
  final String jam;
  final String harga;

  const CheckoutScreen({
    super.key,
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
  bool _isLoading = false; // Status loading untuk tombol

  // Fungsi untuk memproses pembayaran dan hit API ke Laravel
  Future<void> _handlePayment() async {
    setState(() => _isLoading = true);

    final apiService = ApiService();
    
    // Membersihkan string harga (contoh: "Rp 150.000" menjadi 150000.0)
    double cleanPrice = double.tryParse(widget.harga.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    // Memecah jam (contoh: "08:00 - 09:00" menjadi start: 08:00 dan end: 09:00)
    List<String> timeParts = widget.jam.split(' - ');
    String startTime = timeParts.isNotEmpty ? timeParts[0] : widget.jam;
    String endTime = timeParts.length > 1 ? timeParts[1] : widget.jam;

    final result = await apiService.postBooking(
      userId: 1, // Ganti dengan ID user yang sedang login
      lapanganId: 1, // Ganti dengan ID lapangan yang dipilih
      paymentMethod: _selectedMethod,
      date: widget.tanggal,
      startTime: startTime,
      endTime: endTime,
      totalPrice: cleanPrice,
    );

    setState(() => _isLoading = false);

    if (result['status'] == true) {
      _showSuccessDialog(context);
    } else {
      // Tampilkan pesan error jika validasi gagal atau server bermasalah
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal: ${result['message']}"),
          backgroundColor: Colors.red,
        ),
      );
    }
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
            const Text("Ringkasan Pesanan",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
                  )
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
            const Text("Metode Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            _buildMethodOption("Transfer Bank (VA)", Icons.account_balance),
            _buildMethodOption("E-Wallet (Dana/OVO)", Icons.account_balance_wallet),
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: ListTile(
          leading: Icon(icon, color: isSelected ? const Color(0xFF00A32A) : Colors.grey),
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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A32A),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                "Bayar dengan $_selectedMethod",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
            const SizedBox(height: 20),
            const Icon(Icons.check_circle, color: Color(0xFF00A32A), size: 80),
            const SizedBox(height: 20),
            const Text(
              "Pembayaran Berhasil!",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "Berhasil membayar menggunakan $_selectedMethod. Silakan tunjukkan kode booking saat tiba di lokasi.",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A32A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Kembali ke Beranda", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}