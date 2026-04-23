import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // --- FUNGSI POP-UP PERINGATAN LOGOUT ---
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Text("Konfirmasi Keluar"),
          content: const Text("Apakah Anda yakin ingin keluar dari akun?"),
          actions: [
            // Tombol Batal
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            // Tombol Ya, Keluar
            TextButton(
              onPressed: () async {
                // 1. Logout dari Firebase & Google
                await FirebaseAuth.instance.signOut();
                await GoogleSignIn().signOut();

                // 2. Tendang ke halaman Login dan hapus semua history route
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                }
              },
              child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Profil Saya", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER PROFIL ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const CircleAvatar(
                        radius: 50,
                        backgroundColor: Color(0xFF00A32A),
                        child: Icon(Icons.person, size: 60, color: Colors.white),
                      ),
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: Colors.orange,
                        child: const Icon(Icons.edit, size: 15, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    "User Sporty",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    "user@gmail.com",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- MENU LIST ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Akun", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  _buildMenuItem(Icons.person_outline, "Edit Profil", () {}),
                  _buildMenuItem(Icons.history, "Riwayat Transaksi", () {
                    Navigator.pushNamed(context, '/history');
                  }),
                  _buildMenuItem(Icons.notifications_none, "Notifikasi", () {}),
                  
                  const SizedBox(height: 20),
                  const Text("Lainnya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 10),
                  _buildMenuItem(Icons.help_outline, "Pusat Bantuan", () {}),
                  _buildMenuItem(Icons.info_outline, "Tentang Aplikasi", () {}),
                  
                  const SizedBox(height: 30),
                  
                  // Tombol Logout
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showLogoutDialog(context), // Panggil Dialog
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Keluar Akun", style: TextStyle(color: Colors.red)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget Helper untuk item menu
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5, offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: const Color(0xFF00A32A)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      ),
    );
  }
}