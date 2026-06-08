import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        _handleLogout();
        return;
      }

      final response = await http.get(
        Uri.parse('https://sportsfield.my.id/api/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = jsonDecode(response.body);
          _isLoading = false;
        });
      } else {
        _handleLogout();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Gagal memuat profil: $e", Colors.red);
    }
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text("Konfirmasi Keluar"),
          content: const Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: _handleLogout,
              child: const Text("Keluar"),
            ),
          ],
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return "U";
    final parts = name.split(" ");
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final String userName = userData?['name'] ?? "User Sporty";
    final String userEmail = userData?['email'] ?? "user@gmail.com";
    final String? userAvatarUrl =
        userData?['avatar'] ?? userData?['profile_photo_url'];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F9FF),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00A32A),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // ================= HEADER =================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 60,
                      bottom: 30,
                      left: 20,
                      right: 20,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF00A32A), Color(0xFF007A1F)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(35),
                        bottomRight: Radius.circular(35),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: 0,
                          child: IconButton(
  icon: const Icon(
    Icons.edit,
    color: Colors.white,
  ),
  onPressed: () async {
    final result = await Navigator.pushNamed(
      context,
      '/settings',
      arguments: userData, // kirim data user
    );

    if (result == true) {
      _fetchUserProfile(); // refresh setelah edit
    }
  },
),
                        ),
                        Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.white,
                              backgroundImage: userAvatarUrl != null
                                  ? NetworkImage(userAvatarUrl)
                                  : null,
                              child: userAvatarUrl == null
                                  ? Text(
                                      _getInitials(userName),
                                      style: const TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00A32A),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              userName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              userEmail,
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ================= MENU =================
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // ================= MENU AKUN =================
_buildMenuItem(
  Icons.person,
  "Ubah Profil",
  () => Navigator.pushNamed(context, '/settings'),
),

_buildMenuItem(
  Icons.lock,
  "Ubah Password",
  () => Navigator.pushNamed(context, '/change-password'),
),

const SizedBox(height: 20),

// ================= PEMBAYARAN =================

_buildMenuItem(
  Icons.receipt_long,
  "Riwayat Booking",
  () => Navigator.pushNamed(context, '/history'),
),

const SizedBox(height: 20),

// ================= VENUE =================

_buildMenuItem(
  Icons.store,
  "Tambah Venue",
  () => Navigator.pushNamed(
    context,
    '/request-admin',
  ),
),

const SizedBox(height: 20),

// ================= TENTANG =================
_buildMenuItem(
  Icons.description,
  "Syarat dan Ketentuan",
  () => Navigator.pushNamed(context, '/terms'),
),

_buildMenuItem(
  Icons.privacy_tip,
  "Kebijakan Privasi",
  () => Navigator.pushNamed(context, '/privacy'),
),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: _showLogoutDialog,
                            icon: const Icon(Icons.logout,
                                color: Colors.red),
                            label: const Text(
                              "Keluar dari Akun",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFEAEA),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4A5568)),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}