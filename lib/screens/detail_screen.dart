import 'package:flutter/material.dart';
import 'package:penyewaan_lapangan/models/field_model.dart'; // Pastikan path import benar
import 'schedule_screen.dart'; 

class DetailScreen extends StatelessWidget {
  // SEKARANG: Menggunakan FieldModel, bukan Map lagi
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
                  field.imageUrl ?? "", // Menggunakan properti dari FieldModel
                  fit: BoxFit.cover,
                  errorBuilder: (context, e, s) => Container(
                    color: Colors.blueGrey[200], 
                    child: const Icon(Icons.image, size: 50)
                  ),
                ),
              ),
              Positioned(
                top: 40, 
                left: 15, 
                child: CircleAvatar(
                  backgroundColor: Colors.white, 
                  child: const BackButton(color: Colors.black)
                )
              ),
              Positioned(
                bottom: 10, 
                right: 15, 
                child: Container(
                  padding: const EdgeInsets.all(5), 
                  color: Colors.black54, 
                  child: const Text("1/3", style: TextStyle(color: Colors.white, fontSize: 12))
                )
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
                  field.name, // Menggunakan field.name
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    // Catatan: Jika FieldModel belum ada rating, bisa hardcode dulu atau tambah ke model
                    const Text(" 4.5 Rating • Kab. Indramayu") 
                  ],
                ),
                const Divider(height: 30),
                const Text("Fasilitas", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                const Text("🚲 parkir mobil/motor      🥤 jual minuman\n🚽 toilet               🍔 jual makanan\n🎾 jual peralatan olahraga"),
                const SizedBox(height: 20),
                const Text("Deskripsi", style: TextStyle(fontWeight: FontWeight.bold)),
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
              border: Border(top: BorderSide(color: Colors.grey.shade300, width: 0.5))
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Mulai dari", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      "Rp ${field.price}", // Menggunakan field.price
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF00A32A))
                    )
                  ],
                ),
                ElevatedButton(
                  onPressed: () {
                    // Pindah ke ScheduleScreen membawa data dari FieldModel
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ScheduleScreen(
                          namaLapangan: field.name,
                          hargaLapangan: "Rp ${field.price}",
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black, 
                    padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  child: const Text("Pilih Jadwal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}