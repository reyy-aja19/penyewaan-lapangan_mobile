import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    _historyFuture = _fetchBookingHistory(); // Panggil fungsi fetch data
  }

  // --- FUNGSI AMBIL DATA DARI API (PAKAI TOKEN) ---
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // FIX DISINI: Kalau Laravel lo ngembaliin { "data": [...] }
        if (data is Map && data.containsKey('data')) {
          return data['data'] as List<dynamic>;
        }

        // Kalau Laravel lo langsung ngembaliin [...]
        return data as List<dynamic>;
      } else {
        throw Exception("Gagal load data: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Koneksi Error: $e");
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
          title: const Text(
            "Riwayat Sewa",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh, color: Colors.black),
            ),
          ],
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
        body: FutureBuilder<List<dynamic>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00A32A)),
              );
            }
            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text("Belum ada riwayat booking."));
            }

            final allBookings = snapshot.data!;

            // Filter Status
            final activeBookings = allBookings
                .where(
                  (b) =>
                      b['status'] == 'pending' ||
                      b['status'] == 'Lunas' ||
                      b['status'] == 'DP',
                )
                .toList();

            final finishedBookings = allBookings
                .where(
                  (b) => b['status'] == 'Selesai' || b['status'] == 'Batal',
                )
                .toList();

            return TabBarView(
              children: [
                _buildList(activeBookings, "Tidak ada penyewaan aktif"),
                _buildList(finishedBookings, "Belum ada riwayat selesai"),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildList(List<dynamic> bookings, String emptyMessage) {
    if (bookings.isEmpty) {
      return Center(
        child: Text(emptyMessage, style: const TextStyle(color: Colors.grey)),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _refreshData(),
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final b = bookings[index];

          // Logika Warna Status
          Color statusColor = const Color(0xFF00A32A);
          if (b['status'] == 'pending') statusColor = Colors.orange;
          if (b['status'] == 'Batal') statusColor = Colors.red;
          if (b['status'] == 'Selesai') statusColor = Colors.grey;

          return _historyCard(
            b['lapangan']?['nama_lapangan'] ?? "Lapangan",
            b['booking_date'].toString().substring(0, 10),
            "${b['start_time']} - ${b['end_time']}",
            b['status'],
            statusColor,
          );
        },
      ),
    );
  }

  Widget _historyCard(
    String title,
    String date,
    String time,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 25),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                date,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                time,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
