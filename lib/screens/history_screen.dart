import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'create_match_screen.dart'; // WAJIB IMPORT HALAMAN FORM MATCH KAMU

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
        itemCount: bookings.length, // Baris onDestroy sudah dihapus aman di sini
        itemBuilder: (context, index) {
          final b = bookings[index];

          // Logika Warna Status
          Color statusColor = const Color(0xFF00A32A);
          if (b['status'] == 'pending') statusColor = Colors.orange;
          if (b['status'] == 'Batal') statusColor = Colors.red;
          if (b['status'] == 'Selesai') statusColor = Colors.grey;

          return _historyCard(b, statusColor);
        },
      ),
    );
  }

  Widget _historyCard(dynamic booking, Color statusColor) {
    String status = booking['status'] ?? 'pending';
    String title = booking['lapangan']?['nama_lapangan'] ?? "Lapangan";
    
    // Penanganan substring aman untuk parsing tanggal dari database
    String fullDate = booking['booking_date'] ?? booking['tanggal'] ?? "2026-01-01";
    String dateParsed = fullDate.length >= 10 ? fullDate.substring(0, 10) : fullDate;

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
                dateParsed,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(width: 20),
              const Icon(Icons.access_time, size: 14, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                "${booking['start_time']} - ${booking['end_time'] ?? ''}",
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),

          // --- KUNCI INTEGRASI: JIKA STATUS LUNAS, MUNCULKAN TOMBOL OPEN MATCH ---
          if (status.toLowerCase() == 'lunas') ...[
            const Divider(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  // Arahkan ke CreateMatchScreen dengan melempar data Map Booking ini
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CreateMatchScreen(bookingData: booking),
                    ),
                  );
                  if (result == true) {
                    _refreshData();
                  }
                },
                icon: const Icon(Icons.sports_soccer, size: 18, color: Colors.white),
                label: const Text(
                  "BUAT OPEN MATCH",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A32A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ]
        ],
      ),
    );
  }
}