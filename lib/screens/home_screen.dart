import 'package:flutter/material.dart';
import 'detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:penyewaan_lapangan/models/field_model.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<FieldModel>> futureFields;

  @override
  void initState() {
    super.initState();
    futureFields = fetchFields();
  }

  // 🔥 Ambil data dari Laravel API
  Future<List<FieldModel>> fetchFields() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.15:8000/api/fields'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['data'] as List)
            .map((json) => FieldModel.fromJson(json))
            .toList();
      } else {
        throw Exception('Gagal ambil data');
      }
    } catch (e) {
      print("Error Fetching: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<FieldModel>>(
        future: futureFields,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00A32A)),
            );
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
                  child: Text("Kategori Olahraga",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                _buildCategories(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text("Venue Pilihan Untukmu",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                _buildHorizontalList(context, dataFields),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text("Rekomendasi Terdekat",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                ),
                _buildVerticalList(dataFields),
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI =================

  Widget _buildHorizontalList(BuildContext context, List<FieldModel> fields) {
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

  Widget _cardVenue(BuildContext context, FieldModel field) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(field: field),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // KODE BARU (Benar untuk SVG)
ClipRRect(
  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
  child: SvgPicture.network(
    field.imageUrl ?? '', // Path SVG lengkap (misal: http://192.168.1.15:8000/uploads/...)
    height: 120,
    width: double.infinity,
    fit: BoxFit.cover,
    // Placeholder jika gambar loading atau error
    placeholderBuilder: (BuildContext context) => Container(
        height: 120, 
        color: Colors.grey[200], 
        child: const Center(child: CircularProgressIndicator())
    ),
  ),
),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text("Tersedia",
                        style: TextStyle(color: Colors.grey, fontSize: 11)),
                    const SizedBox(height: 10),
                    Text(
                      "Rp ${field.price} / jam",
                      style: const TextStyle(
                        color: Color(0xFF00A32A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalList(List<FieldModel> fields) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                field.imageUrl ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            title: Text(field.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${field.type} | Rp ${field.price}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(field: field),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF00A32A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Lokasi Kamu",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  Text("📍 Indramayu, ID",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white),
                ),
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return const SizedBox(
      height: 50,
      child: Center(child: Text("Sepak Bola • Futsal • Badminton")),
    );
  }
}