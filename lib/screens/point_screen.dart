import 'package:flutter/material.dart';

class PointScreen extends StatelessWidget {
  const PointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text("Poin Saya", style: TextStyle(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card Saldo Poin
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00A32A), Color(0xFF00D136)]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: const [
                  Text("Total Poin Kamu", style: TextStyle(color: Colors.white70)),
                  SizedBox(height: 10),
                  Text("2,450 Poin", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Align(alignment: Alignment.centerLeft, child: Text("Tukar Reward", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.orange.withOpacity(0.1), child: Icon(icon, color: Colors.orange)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(cost, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
        trailing: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00A32A)), child: const Text("Tukar", style: TextStyle(color: Colors.white))),
      ),
    );
  }
}