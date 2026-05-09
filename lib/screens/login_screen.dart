import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. Tambahkan Controller untuk menangkap input teks
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // --- FUNGSI LOGIN MANUAL (PEMPERBAIKI BIANG KEROK) ---
  Future<void> _handleLoginManual() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Validasi input kosong
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Email dan Password tidak boleh kosong!", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // TODO: Ganti bagian ini dengan panggil ApiService().login(email, password)
      // Ini simulasi pengecekan ke database Laravel/VPS kamu
      await Future.delayed(const Duration(seconds: 1)); // Simulasi loading network

      if (email == "admin@gmail.com" && password == "admin123") {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } else {
        _showSnackBar("Email atau Password salah!", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Terjadi kesalahan: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- FUNGSI LOGIN GOOGLE ---
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      _showSnackBar("Gagal Login Google: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  void dispose() {
    // Bersihkan controller saat screen ditutup
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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

            // Input Fields dengan Controller
            _inputField("Email / No. HP", _emailController),
            const SizedBox(height: 20),
            _inputField("Masukkan Password", _passwordController, isPassword: true),

            const SizedBox(height: 30),

            // Tombol Login Manual
            ElevatedButton(
              onPressed: _isLoading ? null : _handleLoginManual,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A32A),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "LOGIN",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
            ),

            const SizedBox(height: 25),
            const Text("atau", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 25),

            _googleButton(),

            const SizedBox(height: 40),
            _buildRegisterLink(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, {bool isPassword = false}) {
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
          controller: controller, // Menghubungkan controller
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

  Widget _googleButton() {
    return OutlinedButton(
      onPressed: _handleGoogleSignIn,
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
          Image.asset('assets/images/logo_google.png', height: 22),
          const SizedBox(width: 12),
          const Text(
            "Masuk Dengan Google",
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Belum punya akun? "),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: const Text(
            "Daftar Sekarang",
            style: TextStyle(color: Color(0xFF00A32A), fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}