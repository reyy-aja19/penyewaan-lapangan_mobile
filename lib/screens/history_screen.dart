import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Riwayat Sewa", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Color(0xFF00A32A),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF00A32A),
            tabs: [
              Tab(text: "Aktif"),
              Tab(text: "Selesai"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildActiveList(),
            _buildFinishedList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _historyCard(
          "Futsal Indramayu Sport",
          "10 April 2026",
          "19:00 - 20:00",
          "Menunggu Main",
          const Color(0xFF00A32A),
        ),
      ],
    );
  }

  Widget _buildFinishedList() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _historyCard(
          "Badminton Smash Center",
          "05 April 2026",
          "16:00 - 17:00",
          "Selesai",
          Colors.grey,
        ),
      ],
    );
  }

  Widget _historyCard(String title, String date, String time, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(date, style: const TextStyle(color: Colors.grey)),
              const SizedBox(width: 20),
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(time, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}