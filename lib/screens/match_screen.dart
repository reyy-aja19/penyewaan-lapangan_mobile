import 'package:flutter/material.dart';

import '../models/match_model.dart';
import '../services/match_api.dart';

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
    futureMatches = MatchApi.fetchMatches();
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
      ),

      body: FutureBuilder<List<MatchModel>>(
        future: futureMatches,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final matches = snapshot.data ?? [];

          if (matches.isEmpty) {
            return const Center(child: Text("Belum ada open match"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: matches.length,

            itemBuilder: (context, index) {
              final match = matches[index];

              return _matchCard(match);
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: const Color(0xFF00A32A),

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text("Buat Match", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _matchCard(MatchModel match) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),

        border: const Border(left: BorderSide(color: Colors.green, width: 5)),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Column(
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
            ],
          ),

          Column(
            children: [
              Text(
                "${match.jumlahBergabung}/${match.jumlahPemain}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              Text(
                match.status,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
