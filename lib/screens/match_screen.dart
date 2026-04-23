import 'package:flutter/material.dart';

class MatchScreen extends StatelessWidget {
  const MatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(title: const Text("Cari Lawan", style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _matchCard("Futsal Fun", "Malam Ini", "19:00", "3/10 Orang", Colors.blue),
          _matchCard("Mabar Badminton", "Besok", "08:00", "1/4 Orang", Colors.orange),
          _matchCard("Basket 3on3", "12 April", "16:00", "5/6 Orang", Colors.red),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF00A32A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Buat Match", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _matchCard(String title, String day, String time, String slot, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border(left: BorderSide(color: color, width: 5))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 5),
              Text("$day • $time", style: const TextStyle(color: Colors.grey)),
            ],
          ),
          Column(
            children: [
              Text(slot, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
              const Text("Tersedia", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}