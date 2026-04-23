import 'package:flutter/material.dart';
import 'detail_screen.dart';

// Import model (sesuaikan path-nya)
// import '../models/field_model.dart'; 

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Simulasi data dari Database/API
  Future<List<Map<String, dynamic>>> fetchFields() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulasi loading internet
    return [
      {
        "name": "Badminton Smash Center",
        "price": "75.000",
        "img": "https://images.unsplash.com/photo-1521537634581-0dced2fee2ef",
        "rating": "4.9",
        "dist": "2.4 km",
        "description": "Lapangan dengan karpet standar internasional dan pencahayaan terbaik.",
        "category": "Badminton"
      },
      {
        "name": "Futsal Indramayu Sport",
        "price": "120.000",
        "img": "https://images.unsplash.com/photo-1574629810360-7efbbe195018",
        "rating": "4.7",
        "dist": "1.2 km",
        "description": "Rumput sintetis kualitas premium, cocok untuk turnamen lokal.",
        "category": "Futsal"
      },
      {
        "name": "Basket Court Karanganyar",
        "price": "50.000",
        "img": "https://images.unsplash.com/photo-1544919982-b61976f0ba43",
        "rating": "4.8",
        "dist": "3.1 km",
        "description": "Lapangan indoor dengan ring standar NBA.",
        "category": "Basket"
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchFields(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00A32A)));
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Gagal mengambil data"));
          }

          final dataFields = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text("Kategori Olahraga", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                _buildCategories(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Venue Pilihan Untukmu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                // Horizontal List Dinamis
                _buildHorizontalList(context, dataFields),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text("Rekomendasi Terdekat", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                // Vertical List Dinamis
                _buildVerticalList(dataFields),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- WIDGET HELPER (Hanya bagian List yang diubah logicnya) ---

  Widget _buildHorizontalList(BuildContext context, List<Map<String, dynamic>> fields) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: fields.length,
        itemBuilder: (context, index) {
          return _cardVenue(context, fields[index]);
        },
      ),
    );
  }

  Widget _cardVenue(BuildContext context, Map<String, dynamic> field) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(field: field))),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(field['img'], height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(field['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text("${field['dist']} dari sini", style: const TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 10),
                    Text("Rp ${field['price']} / jam", style: const TextStyle(color: Color(0xFF00A32A), fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalList(List<Map<String, dynamic>> fields) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(field['img'], width: 60, height: 60, fit: BoxFit.cover),
            ),
            title: Text(field['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("⭐ ${field['rating']} | ${field['dist']}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailScreen(field: field))),
          ),
        );
      },
    );
  }

  // Header Tetap Sama
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF00A32A),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Lokasi Kamu", style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("📍 Indramayu, ID", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: const CircleAvatar(backgroundColor: Colors.white24, child: Icon(Icons.person, color: Colors.white)),
              ),
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            decoration: InputDecoration(
              hintText: "Cari lapangan...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    // Bisa dibuat dinamis juga seperti List lapangan
    return const SizedBox(height: 100, child: Center(child: Text("Kategori Widget Di Sini")));
  }
}