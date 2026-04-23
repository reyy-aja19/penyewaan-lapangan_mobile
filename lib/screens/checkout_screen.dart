import 'package:flutter/material.dart';

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
  // Variabel untuk menyimpan metode yang dipilih
  String _selectedMethod = "Transfer Bank (VA)"; 

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
            // 1. Ringkasan Pesanan
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

            // 2. Metode Pembayaran
            const Text("Metode Pembayaran",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 15),
            
            // Opsi-opsi pembayaran
            _buildMethodOption("Transfer Bank (VA)", Icons.account_balance),
            _buildMethodOption("E-Wallet (Dana/OVO)", Icons.account_balance_wallet),
            _buildMethodOption("Tunai di Tempat", Icons.payments_outlined),
          ],
        ),
      ),
      bottomNavigationBar: _buildPayButton(context),
    );
  }

  // Widget untuk membuat pilihan metode pembayaran
  Widget _buildMethodOption(String title, IconData icon) {
    bool isSelected = _selectedMethod == title;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = title; // Update status pilihan
        });
      },
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
          leading: Icon(
            icon, 
            color: isSelected ? const Color(0xFF00A32A) : Colors.grey
          ),
          title: Text(
            title, 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSelected ? const Color(0xFF00A32A) : Colors.black87
            )
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
        onPressed: () {
          _showSuccessDialog(context);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00A32A),
          minimumSize: const Size(double.infinity, 55),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        child: Text(
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