import 'package:flutter/material.dart';
import '../services/database_api.dart'; // Import file API Database kamu

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00A32A),
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Colors.white)
      ),
      body: Column(
        children: [
          const Text("Total Pembayaran", style: TextStyle(color: Colors.white, fontSize: 16)),
          const Text("Rp 90.000", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: const BoxDecoration(
                color: Colors.white, 
                borderRadius: BorderRadius.vertical(top: Radius.circular(30))
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Metode Pembayaran", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _paymentMethod("Virtual Account", false),
                  _paymentMethod("Alfamart", false),
                  _paymentMethod("Gopay", true),
                  const Spacer(),
                  
                  // --- TOMBOL BAYAR DENGAN LOGIKA API ---
                  ElevatedButton(
                    onPressed: () async {
                      // 1. Jalankan API Simpan ke Firestore
                      await DatabaseApi().simpanBooking(
                        namaUser: "User Tester", // Nanti bisa ambil dari FirebaseAuth
                        namaLapangan: "Lapangan Badminton A",
                        tanggal: "24 Mei 2026",
                        jam: "10:00 - 12:00",
                        totalHarga: 90000,
                      );

                      // 2. Tampilkan Dialog Sukses (Context dijamin aman setelah await)
                      if (context.mounted) {
                        _showSuccessDialog(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A32A),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                    ),
                    child: const Text("Bayar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _paymentMethod(String name, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!), 
        borderRadius: BorderRadius.circular(10)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
          Icon(
            isSelected ? Icons.radio_button_checked : Icons.radio_button_off, 
            color: isSelected ? Colors.green : Colors.grey
          ),
        ],
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
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 20),
            const Text(
              "selamat Pembayaran kamu berhasil", 
              textAlign: TextAlign.center, 
              style: TextStyle(fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.popUntil(context, ModalRoute.withName('/home')),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black),
              child: const Text("kembali", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      ),
    );
  }
}