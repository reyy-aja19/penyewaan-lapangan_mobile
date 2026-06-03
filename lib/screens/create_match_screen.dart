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
  String _startTimeString = '';
  String _endTimeString = '';
  int _bookingId = 0;

  @override
  void initState() {
    super.initState();
    // Inisialisasi data otomatis jika mendapat lemparan data dari HistoryScreen
    if (widget.bookingData != null) {
      _bookingId = widget.bookingData['id'] ?? 0;
      
      // 1. Deteksi Jenis Olahraga otomatis dari data booking
      String namaLapangan = (widget.bookingData['lapangan']?['nama_lapangan'] ?? 
                             widget.bookingData['nama_lapangan'] ?? 
                             widget.bookingData['lapangan_nama'] ?? 
                             "").toString().toLowerCase();

      if (namaLapangan.contains('futsal')) {
        _selectedJenis = 'Futsal';
      } else if (namaLapangan.contains('badminton')) {
        _selectedJenis = 'Badminton';
      } else {
        _selectedJenis = widget.bookingData['lapangan']?['jenis'] ?? 'Futsal';
      }
      
      // 2. Parsing Tanggal sesuai data booking
      String rawDate = widget.bookingData['booking_date'] ?? widget.bookingData['tanggal'] ?? '';
      _bookingDateString = rawDate.length >= 10 ? rawDate.substring(0, 10) : rawDate;
      
      // 3. AMBIL JAM ASLI SESUAI DATA BOOKING USER
      // Memotong string ke 5 karakter pertama (HH:MM) agar formatnya rapi tanpa detik (HH:MM:SS)
      String rawStart = widget.bookingData['start_time'] ?? '';
      String rawEnd = widget.bookingData['end_time'] ?? '';
      
      _startTimeString = rawStart.length >= 5 ? rawStart.substring(0, 5) : rawStart;
      _endTimeString = rawEnd.length >= 5 ? rawEnd.substring(0, 5) : rawEnd;
    } else {
      _bookingDateString = "${DateTime.now().toLocal()}".split(' ')[0];
      _startTimeString = '08:00';
      _endTimeString = '09:00';
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
        id: _bookingId, 
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
          Navigator.pop(context, true); 
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

              // Input Jenis Olahraga (Dinamis & ReadOnly)
              TextFormField(
                key: Key("jenis_$_selectedJenis"), 
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

              // Input Tanggal (Dinamis & ReadOnly)
              TextFormField(
                key: Key("tanggal_$_bookingDateString"), 
                initialValue: "Tanggal Main: $_bookingDateString",
                readOnly: true,
                decoration: _inputDecoration("Tanggal", Icons.calendar_today, enabled: false),
              ),
              const SizedBox(height: 15),

              // Tampilan Jam (Otomatis Mengikuti Variabel _startTimeString & _endTimeString)
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: Key("start_$_startTimeString"),
                      initialValue: _startTimeString,
                      readOnly: true,
                      decoration: _inputDecoration("Mulai", Icons.access_time, enabled: false),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TextFormField(
                      key: Key("end_$_endTimeString"),
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