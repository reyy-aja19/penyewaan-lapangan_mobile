import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Syarat & Ketentuan")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            "Syarat dan Ketentuan Penggunaan Aplikasi:\n\n"
            "1. Pengguna wajib menggunakan aplikasi dengan itikad baik.\n"
            "2. Dilarang menyalahgunakan layanan booking lapangan.\n"
            "3. Semua transaksi mengikuti kebijakan platform.\n"
            "4. Pihak pengelola berhak mengubah ketentuan sewaktu-waktu.\n\n"
            "Dengan menggunakan aplikasi ini, Anda dianggap menyetujui semua syarat di atas.",
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ),
    );
  }
}