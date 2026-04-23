import 'package:flutter/material.dart';
import 'checkout_screen.dart';

class ScheduleScreen extends StatefulWidget {
  final String namaLapangan;
  final String hargaLapangan;

  const ScheduleScreen({
    super.key, 
    required this.namaLapangan, 
    required this.hargaLapangan,
  });

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  // Daftar jam tersedia
  final List<String> _timeSlots = [
    "08:00", "09:00", "10:00", "11:00", "13:00", 
    "14:00", "15:00", "16:00", "19:00", "20:00", "21:00"
  ];

  // List untuk menampung jam yang dipilih (Maksimal 2)
  List<String> _selectedTimes = [];

  @override
  Widget build(BuildContext context) {
    // Tanggal tetap ada di sini
    String tanggalBooking = "10 April 2026"; 

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pilih Jadwal", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        leading: const BackButton(color: Colors.black),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info Nama Lapangan & Limit
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Text(
              "${widget.namaLapangan} • Pilih Maksimal 2 Jam",
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),

          // --- BAGIAN TANGGAL (TETAP DIJAGA) ---
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text("Tanggal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF00A32A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: const Color(0xFF00A32A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFF00A32A)),
                const SizedBox(width: 15),
                Text(
                  tanggalBooking, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Text("Pilih Jam", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),

          // Grid Jam
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _timeSlots.length,
              itemBuilder: (context, index) {
                String time = _timeSlots[index];
                bool isSelected = _selectedTimes.contains(time);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedTimes.remove(time);
                      } else {
                        if (_selectedTimes.length < 2) {
                          _selectedTimes.add(time);
                          _selectedTimes.sort(); // Mengurutkan jam agar rapi
                        } else {
                          // SnackBar jika lebih dari 2 jam
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Cukup 2 jam saja, jangan maruk Bujang!"),
                              duration: Duration(seconds: 1),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      }
                    });
                  },
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF00A32A) : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF00A32A) : Colors.grey.shade300
                      ),
                    ),
                    child: Text(
                      time,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Tombol Konfirmasi
          Container(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: _selectedTimes.isEmpty 
                ? null 
                : () {
                    // Logika Hitung Harga
                    // Menghapus 'Rp ' dan titik ribuan
                    int hargaSatuan = int.parse(widget.hargaLapangan.replaceAll(RegExp(r'[^0-9]'), ''));
                    int totalHarga = hargaSatuan * _selectedTimes.length;
                    
                    // Format kembali ke Rupiah
                    String hargaFinal = "Rp ${totalHarga.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')}";

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(
                          namaLapangan: widget.namaLapangan,
                          tanggal: tanggalBooking,
                          jam: _selectedTimes.join(", "), // Menggabungkan jam, misal: "08:00, 09:00"
                          harga: hargaFinal,
                        ),
                      ),
                    );
                  },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00A32A),
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: Text(
                _selectedTimes.isEmpty 
                    ? "Pilih Jam" 
                    : "Konfirmasi ${_selectedTimes.length} Jam", 
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)
              ),
            ),
          ),
        ],
      ),
    );
  }
}