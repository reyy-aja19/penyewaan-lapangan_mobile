import 'package:flutter/material.dart';

class SuccessAuthScreen extends StatefulWidget {
  const SuccessAuthScreen({super.key});

  @override
  State<SuccessAuthScreen> createState() => _SuccessAuthScreenState();
}

class _SuccessAuthScreenState extends State<SuccessAuthScreen> {
  @override
  void initState() {
    super.initState();
    // Otomatis pindah ke home setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 120,
                color: Color(0xFF00A32A),
              ),
              const SizedBox(height: 30),
              const Text(
                "Registrasi Berhasil!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B5E20),
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                "Akun kamu telah terdaftar. Kamu akan diarahkan ke Dashboard dalam beberapa detik...",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 50),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00A32A)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
