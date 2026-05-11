import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PointScreen extends StatefulWidget {
  const PointScreen({super.key});

  @override
  State<PointScreen> createState() => _PointScreenState();
}

class _PointScreenState extends State<PointScreen> {
  int _userPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
  }

  // Tarik poin dari data user yang tersimpan di lokal
  Future<void> _loadUserPoints() async {
    final prefs = await SharedPreferences.getInstance();
    final String? userRaw = prefs.getString('user');
    if (userRaw != null) {
      final userData = jsonDecode(userRaw);
      setState(() {
        // Pastikan di Laravel data user punya kolom 'points'
        _userPoints = userData['points'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Poin Saya", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card Saldo Poin Dinamis
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00A32A), Color(0xFF00D136)]),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF00A32A).withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                ],
              ),
              child: Column(
                children: [
                  const Text("Total Poin Kamu", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(
                    "$_userPoints Poin", // Nampilin poin asli
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  const Text("1 Booking = 5 Poin", style: TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft, 
              child: Text("Tukar Reward", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))
            ),
            const SizedBox(height: 15),
            _rewardTile("Diskon Sewa Rp 20rb", "1000 Poin", Icons.confirmation_number_outlined),
            _rewardTile("Minuman Dingin Gratis", "500 Poin", Icons.local_drink),
            _rewardTile("Sewa Raket Gratis", "800 Poin", Icons.sports_tennis),
          ],
        ),
      ),
    );
  }

  Widget _rewardTile(String title, String cost, IconData icon) {
    // Parsing harga poin buat validasi tombol
    int costValue = int.parse(cost.split(' ')[0]);
    bool canRedeem = _userPoints >= costValue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.orange.withOpacity(0.1), 
          child: Icon(icon, color: Colors.orange)
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(cost, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
        trailing: ElevatedButton(
          onPressed: canRedeem ? () {
            // Logic tukar poin di sini
          } : null, // Tombol mati kalau poin gak cukup
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A32A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          child: const Text("Tukar", style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}