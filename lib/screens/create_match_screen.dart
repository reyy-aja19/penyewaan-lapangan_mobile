import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/match_api.dart';

class CreateMatchScreen extends StatefulWidget {
  // Menerima data booking dari HistoryScreen
  final dynamic bookingData;

  const CreateMatchScreen({super.key, this.bookingData});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _jmlPemainController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedJenis = 'Futsal';
  String _bookingDateString = '';
  String _startTimeString = '16:00';
  String _endTimeString = '17:00';
  int _bookingId = 0;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data otomatis jika mendapat lemparan data dari HistoryScreen
    if (widget.bookingData != null) {
      _bookingId = widget.bookingData['id'] ?? 0;
      
      // ==================== FIX DETEKSI OTOMATIS DI SINI ====================
      // Ambil nama lapangan secara kasar (bisa dari relasi atau teks langsung)
      String namaLapangan = (widget.bookingData['lapangan']?['nama_lapangan'] ?? 
                             widget.bookingData['nama_lapangan'] ?? 
                             widget.bookingData['lapangan_nama'] ?? 
                             "").toString().toLowerCase();

      // Cek apakah nama lapangannya mengandung kata 'futsal'
      if (namaLapangan.contains('futsal')) {
        _selectedJenis = 'Futsal';
      } else if (namaLapangan.contains('badminton')) {
        _selectedJenis = 'Badminton';
      } else {
        // Jika tidak ketemu keduanya, balik ke default relasi awal lu
        _selectedJenis = widget.bookingData['lapangan']?['jenis'] ?? 'Futsal';
      }
      // =====================================================================
      
      // Parsing aman string tanggal
      String rawDate = widget.bookingData['booking_date'] ?? widget.bookingData['tanggal'] ?? '';
      _bookingDateString = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
      
      // Ambil jam sewa
      _startTimeString = widget.bookingData['start_time'] ?? '16:00';
      _endTimeString = widget.bookingData['end_time'] ?? '17:00';
    } else {
      _bookingDateString = "${DateTime.now().toLocal()}".split(' ')[0];
    }
  }

  // Custom styling "CSS" di variabel agar kode lebih bersih
  final _inputDecoration = (String label, IconData icon, {bool enabled = true}) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: enabled ? Colors.green : Colors.grey),
        fillColor: enabled ? Colors.white : Colors.grey.shade100,
        filled: !enabled,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: enabled ? Colors.green : Colors.grey, width: 2),
        ),
      );

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      if (_bookingId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error: ID Booking tidak valid."), backgroundColor: Colors.red),
        );
        return;
      }

      final newMatch = MatchModel(
        id: _bookingId, // Mengirim booking_id sesuai validasi backend Laravel
        title: _titleController.text,
        jenis: _selectedJenis,
        tanggal: _bookingDateString,
        startTime: _startTimeString,
        endTime: _endTimeString,
        jumlahPemain: int.parse(_jmlPemainController.text),
        jumlahBergabung: 1,
        status: 'Open',
        deskripsi: _descController.text,
      );

      bool success = await MatchApi.createMatch(newMatch);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Match Berhasil Dibuat!"), backgroundColor: Colors.green),
          );
          Navigator.pop(context, true); // Kembali ke HistoryScreen & refresh data
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal membuat match. Cek kembali status booking kamu."), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Buat Match Baru",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detail Pertandingan (Otomatis Terisi)",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),

              // Input Judul
              TextFormField(
                controller: _titleController,
                decoration: _inputDecoration("Judul Match", Icons.title),
                validator: (v) => v!.isEmpty ? "Isi judul dulu" : null,
              ),
              const SizedBox(height: 15),

              // Dropdown Jenis Olahraga (Disabled/ReadOnly karena otomatis dari booking)
              TextFormField(
                initialValue: _selectedJenis,
                readOnly: true,
                decoration: _inputDecoration("Jenis Olahraga", Icons.sports_soccer, enabled: false),
              ),
              const SizedBox(height: 15),

              // Input Jumlah Pemain
              TextFormField(
                controller: _jmlPemainController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Maksimal Pemain (Kebutuhan)", Icons.groups),
                validator: (v) => v!.isEmpty ? "Isi jumlah pemain" : null,
              ),
              const SizedBox(height: 15),

              // Input Deskripsi
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDecoration("Deskripsi Tambahan / Catatan", Icons.description),
              ),
              const SizedBox(height: 15),

              // Tampilan Tanggal Otomatis (ReadOnly)
              TextFormField(
                initialValue: "Tanggal Main: $_bookingDateString",
                readOnly: true,
                decoration: _inputDecoration("Tanggal", Icons.calendar_today, enabled: false),
              ),
              const SizedBox(height: 15),

              // Tampilan Jam Otomatis (ReadOnly)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _startTimeString,
                      readOnly: true,
                      decoration: _inputDecoration("Mulai", Icons.access_time, enabled: false),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      initialValue: _endTimeString,
                      readOnly: true,
                      decoration: _inputDecoration("Selesai", Icons.access_time, enabled: false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Tombol Simpan
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    "SIMPAN MATCH",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}