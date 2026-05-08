import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/match_api.dart';
import 'create_match_screen.dart'; // Pastikan import screen input kamu

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late Future<List<MatchModel>> futureMatches;

  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  // Langkah 4: Fungsi untuk Refresh data
  void _refreshData() {
    setState(() {
      futureMatches = MatchApi.fetchMatches();
    });
  }

  // Langkah 2: Fungsi Join Match
  void _handleJoin(int matchId) async {
    bool success = await MatchApi.joinMatch(matchId);
    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Berhasil bergabung ke match!")),
        );
        _refreshData(); // Refresh list setelah join
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal join. Mungkin sudah penuh atau masalah server.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Cari Lawan",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          )
        ],
      ),
      body: FutureBuilder<List<MatchModel>>(
        future: futureMatches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Terjadi kesalahan: ${snapshot.error}"));
          }
          final matches = snapshot.data ?? [];
          if (matches.isEmpty) {
            return const Center(child: Text("Belum ada open match"));
          }
          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: matches.length,
              itemBuilder: (context, index) {
                return _matchCard(matches[index]);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          // Menuju halaman buat match dan tunggu hasilnya
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMatchScreen()),
          );
          
          // Jika berhasil buat (result true), refresh list
          if (result == true) {
            _refreshData();
          }
        },
        backgroundColor: const Color(0xFF00A32A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Buat Match", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _matchCard(MatchModel match) {
    bool isFull = match.status.toLowerCase() == 'full' || 
                  match.jumlahBergabung >= match.jumlahPemain;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      // Gunakan Material & InkWell agar ada efek riak (ripple) saat diklik
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _showMatchDetail(match), // Fungsi Detail Match (Langkah 5)
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            match.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "${match.tanggal.substring(0, 10)} • ${match.startTime}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                          Text(
                            "Jenis: ${match.jenis}",
                            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(isFull, match),
                  ],
                ),
                const Divider(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isFull ? null : () => _handleJoin(match.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(isFull ? "MATCH PENUH" : "JOIN MATCH"),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi pembantu untuk menampilkan Detail (Modal)
  void _showMatchDetail(MatchModel match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            Text(match.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(match.jenis, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w500)),
            const Divider(height: 30),
            _detailRow(Icons.calendar_today, "Tanggal", match.tanggal.substring(0, 10)),
            _detailRow(Icons.access_time, "Waktu", "${match.startTime} - ${match.endTime}"),
            _detailRow(Icons.group, "Kuota", "${match.jumlahBergabung} / ${match.jumlahPemain} Pemain"),
            const SizedBox(height: 20),
            const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              match.deskripsi.isEmpty ? "Tidak ada deskripsi tambahan." : match.deskripsi,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 15),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isFull, MatchModel match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          "${match.jumlahBergabung}/${match.jumlahPemain}",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isFull ? Colors.red : Colors.green,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isFull ? Colors.red.shade50 : Colors.green.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            match.status.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isFull ? Colors.red : Colors.green),
          ),
        ),
      ],
    );
  }
}