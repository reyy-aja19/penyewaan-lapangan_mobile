import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_model.dart';
import '../services/match_api.dart';
import 'create_match_screen.dart';

class MatchScreen extends StatefulWidget {
  const MatchScreen({super.key});

  @override
  State<MatchScreen> createState() => _MatchScreenState();
}

class _MatchScreenState extends State<MatchScreen> {
  late Future<List<MatchModel>> futureMatches;
  String? userToken;

  @override
  void initState() {
    super.initState();
    _checkAuthAndFetch();
  }

  // Cek token dulu sebelum fetch data
  Future<void> _checkAuthAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userToken = prefs.getString('token');
      futureMatches = MatchApi.fetchMatches();
    });
  }

  void _refreshData() {
    setState(() {
      futureMatches = MatchApi.fetchMatches();
    });
  }

  void _handleJoin(int matchId) async {
    // Tampilkan loading sebentar
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    bool success = await MatchApi.joinMatch(matchId);
    
    if (mounted) Navigator.pop(context); // Tutup loading

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Berhasil bergabung ke match! 🔥"),
            backgroundColor: Colors.green,
          ),
        );
        _refreshData(); // Refresh list agar jumlah pemain update
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Gagal join. Mungkin match penuh atau sudah bergabung."),
            backgroundColor: Colors.red,
          ),
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
          "Cari Lawan (Open Match)",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF00A32A)),
            onPressed: _refreshData,
          )
        ],
      ),
      body: FutureBuilder<List<MatchModel>>(
        future: futureMatches,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00A32A)));
          }
          
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text("Waduh! ${snapshot.error}"),
                  TextButton(onPressed: _refreshData, child: const Text("Coba Lagi")),
                ],
              ),
            );
          }

          final matches = snapshot.data ?? [];
          if (matches.isEmpty) {
            return const Center(
              child: Text("Belum ada yang buka match nih, coy!"),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _refreshData(),
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
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
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateMatchScreen()),
          );
          if (result == true) _refreshData();
        },
        backgroundColor: const Color(0xFF00A32A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Buat Match", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _matchCard(MatchModel match) {
    bool isFull = match.jumlahBergabung >= match.jumlahPemain;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showMatchDetail(match),
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
                            Text(match.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(match.jenis, style: const TextStyle(color: Colors.blueGrey, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text("${match.tanggal.substring(0, 10)} • ${match.startTime}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                          ],
                        ),
                      ),
                      _buildStatusBadge(isFull, match),
                    ],
                  ),
                  const Divider(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isFull ? null : () => _handleJoin(match.id),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00A32A),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(isFull ? "MATCH PENUH" : "JOIN SEKARANG"),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMatchDetail(MatchModel match) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Text(match.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(match.jenis, style: const TextStyle(color: Color(0xFF00A32A), fontWeight: FontWeight.bold)),
            const Divider(height: 30),
            _detailRow(Icons.calendar_today, "Tanggal", match.tanggal.substring(0, 10)),
            _detailRow(Icons.access_time, "Waktu", "${match.startTime} - ${match.endTime}"),
            _detailRow(Icons.group, "Kebutuhan", "${match.jumlahBergabung} / ${match.jumlahPemain} Pemain"),
            const SizedBox(height: 15),
            const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 5),
            Text(match.deskripsi.isEmpty ? "No Description" : match.deskripsi, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
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
        Text("${match.jumlahBergabung}/${match.jumlahPemain}", 
             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isFull ? Colors.red : const Color(0xFF00A32A))),
        Text(isFull ? "FULL" : "OPEN", 
             style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isFull ? Colors.red : const Color(0xFF00A32A))),
      ],
    );
  }
}