import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // --- FUNGSI LOGIN GOOGLE DENGAN PEMILIHAN AKUN ---
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    try {
      // Inisialisasi GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // LOGIKA UTAMA: Logout dulu supaya jendela "Pilih Akun" selalu muncul
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      // 1. Trigger proses pilih akun Google
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) return; // User membatalkan login

      // 2. Ambil detail autentikasi
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Buat kredensial untuk Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Sign in ke Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Jika berhasil, arahkan ke Home
      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/home'); 
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal Login Google: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 80),
            // Logo Utama
            const Icon(Icons.sports_soccer, size: 100, color: Color(0xFF1B5E20)),
            const Text(
              'SPORTS FIELD RENTAL',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B5E20),
              ),
            ),
            const SizedBox(height: 50),

            // Input Fields
            _inputField("Email / No. HP"),
            const SizedBox(height: 20),
            _inputField("Masukkan Password", isPassword: true),
            
            const SizedBox(height: 30),

            // Tombol Login Manual
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A32A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              child: const Text(
                "LOGIN",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 25),
            const Text("atau", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),

            // Tombol Google (Logo Asli + Logika Pilih Akun)
            _googleButton(context),

            const SizedBox(height: 40),

            // Link Daftar
            _buildRegisterLink(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, {bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ),
        TextField(
          obscureText: isPassword,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),
      ],
    );
  }

  Widget _googleButton(BuildContext context) {
    return OutlinedButton(
      onPressed: () => _handleGoogleSignIn(context),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 22,
            width: 22,
            child: Image.network(
              'https://www.gstatic.com/images/branding/product/2x/googleg_48dp.png', // URL lebih stabil
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.g_mobiledata, color: Colors.red);
              },
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            "Masuk Dengan Google",
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun? "),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(
              color: Color(0xFF00A32A),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}