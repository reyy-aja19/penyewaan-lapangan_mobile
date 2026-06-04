import 'package:flutter/material.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Kebijakan Privasi")),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            "Kebijakan Privasi:\n\n"
            "Kami menghargai privasi pengguna aplikasi ini.\n\n"
            "1. Data pengguna disimpan dengan aman.\n"
            "2. Kami tidak membagikan data ke pihak ketiga tanpa izin.\n"
            "3. Data hanya digunakan untuk layanan booking.\n"
            "4. Pengguna dapat meminta penghapusan data kapan saja.\n\n"
            "Dengan menggunakan aplikasi ini, Anda menyetujui kebijakan privasi ini.",
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ),
    );
  }
}