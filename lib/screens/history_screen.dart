import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_match_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<List<dynamic>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _historyFuture = _fetchBookingHistory();
  }

  Future<List<dynamic>> _fetchBookingHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('https://sportsfield.my.id/api/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      final data = jsonDecode(response.body);

      if (data is Map && data.containsKey('data')) {
        return data['data'];
      }

      return data;
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  void _refreshData() {
    setState(() {
      _historyFuture = _fetchBookingHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: AppBar(
          title: const Text("Riwayat Sewa"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "Aktif"),
              Tab(text: "Selesai"),
            ],
          ),
        ),
        body: FutureBuilder<List<dynamic>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final all = snapshot.data!;

            final active = all.where((b) =>
                b['status'] == 'pending' ||
                b['status'] == 'Lunas' ||
                b['status'] == 'DP').toList();

            final done = all.where((b) =>
                b['status'] == 'Selesai' ||
                b['status'] == 'Batal').toList();

            return TabBarView(
              children: [
                _buildList(active),
                _buildList(done),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List bookings) {
    if (bookings.isEmpty) {
      return const Center(child: Text("Tidak ada data"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, i) {
        final b = bookings[i];

        Color statusColor = Colors.green;
        if (b['status'] == 'pending') statusColor = Colors.orange;
        if (b['status'] == 'Batal') statusColor = Colors.red;
        if (b['status'] == 'Selesai') statusColor = Colors.grey;

        return _historyCard(b, statusColor);
      },
    );
  }

  Widget _historyCard(dynamic booking, Color statusColor) {
    String status = booking['status'] ?? 'pending';

    String namaLapangan =
        booking['lapangan']?['nama'] ??
        booking['lapangan']?['nama_lapangan'] ??
        "Lapangan";

    String date = booking['booking_date'] ?? "-";
    String start = booking['start_time'] ?? "-";
    String end = booking['end_time'] ?? "-";
    String total = booking['total_price']?.toString() ?? "0";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  namaLapangan,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 11),
                ),
              )
            ],
          ),

          const SizedBox(height: 10),

          Text("📅 $date"),
          Text("⏰ $start - $end"),
          Text("💰 Rp $total"),
          
          const SizedBox(height: 10),

          if (status.toLowerCase() == 'lunas' &&
              start != '-' &&
              end != '-')
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CreateMatchScreen(bookingData: booking),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  "BUAT OPEN MATCH",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            )
        ],
      ),
    );
  }
}