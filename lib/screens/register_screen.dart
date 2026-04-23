import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.sports_soccer, size: 80, color: Color(0xFF1B5E20)),
            const SizedBox(height: 50),
            _inputField("email/no.hp"),
            const SizedBox(height: 20),
            _inputField("masukan password", isPassword: true),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/success_auth'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A32A),
                minimumSize: const Size(150, 45),
                shape: const StadiumBorder()
              ),
              child: const Text("konfirmasi", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 25),
            const Text("atau"),
            const SizedBox(height: 20),
            _googleButton(),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Text("Sudah punya akun? Masuk"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[300],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _googleButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.g_mobiledata, color: Colors.red, size: 30),
          Text(" Daftar Dengan Google", style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}