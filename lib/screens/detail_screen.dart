import 'package:flutter/material.dart';
import 'package:penyewaan_lapangan/models/field_model.dart'; // Pastikan path import benar
import 'schedule_screen.dart';

class DetailScreen extends StatelessWidget {
  final FieldModel field;

  const DetailScreen({super.key, required this.field});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- GAMBAR HEADER ---
          Stack(
            children: [
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Image.network(
                  field.imageUrl ?? "",
                  fit: BoxFit.cover,
                  errorBuilder: (context, e, s) => Container(
                    color: Colors.blueGrey[200],
                    child: const Icon(Icons.image, size: 50),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                left: 15,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: const BackButton(color: Colors.black),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  color: Colors.black54,
                  child: const Text(
                    "1/3",
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),

          // --- INFO TEKS ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    const Text(" 4.5 Rating • Kab. Indramayu"),
                  ],
                ),
                const Divider(height: 30),
                
                // --- BAGIAN FASILITAS DINAMIS LARAVEL ---
                const Text(
                  "Fasilitas",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _buildDynamicFacilities(), // Memanggil widget fasilitas dinamis
                
                const SizedBox(height: 20),
                const Text(
                  "Deskripsi",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                Text(
                  field.description ?? "Tidak ada deskripsi untuk lapangan ini.",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          const Spacer(),

          // --- BOTTOM BAR ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade300, width: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Mulai dari",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      "Rp ${field.price}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF00A32A),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleScreen(
                          id: field.id,
                          namaLapangan: field.name,
                          hargaLapangan: "Rp ${field.price}",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Pilih Jadwal",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPER UNTUK MENGURAI FASILITAS ---
  Widget _buildDynamicFacilities() {
    // DISESUAIKAN: Menggunakan field.fasilitas sesuai dengan properti di FieldModel kamu
    if (field.fasilitas == null || field.fasilitas.toString().trim().isEmpty) {
      return const Text(
        "Standard Court",
        style: TextStyle(color: Colors.grey, fontSize: 13),
      );
    }

    List<String> facilityList = [];

    // Cek jika data dari Laravel berupa List/Array JSON
    if (field.fasilitas is List) {
      facilityList = List<String>.from(field.fasilitas);
    } 
    // Cek jika data dari Laravel berupa String teks biasa (misal: "Wifi, Toilet, Parkir")
    else if (field.fasilitas is String) {
      facilityList = field.fasilitas.toString().split(',').map((e) => e.trim()).toList();
    }

    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children: facilityList.map((item) {
        return Chip(
          backgroundColor: const Color(0xFFF1F3F5),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide.none,
          avatar: Icon(_getIconForFacility(item), size: 16, color: Colors.green),
          label: Text(
            item,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        );
      }).toList(),
    );
  }

  // Memberikan icon otomatis berdasarkan kata kunci yang dikirim oleh backend Laravel
  IconData _getIconForFacility(String name) {
    String lower = name.toLowerCase();
    if (lower.contains('parkir')) return Icons.local_parking;
    if (lower.contains('toilet') || lower.contains('wc')) return Icons.wc;
    if (lower.contains('minum') || lower.contains('kantin')) return Icons.local_drink;
    if (lower.contains('makan')) return Icons.restaurant;
    if (lower.contains('wifi')) return Icons.wifi;
    if (lower.contains('mushola') || lower.contains('masjid')) return Icons.mosque;
    return Icons.check_circle_outline; // Default icon jika tidak ada kecocokan kata
  }
}