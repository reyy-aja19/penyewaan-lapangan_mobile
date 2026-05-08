import 'package:flutter/material.dart';
import '../models/match_model.dart';
import '../services/match_api.dart';

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _jmlPemainController = TextEditingController();
  final _descController = TextEditingController();

  String _selectedJenis = 'Futsal';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  // Custom styling "CSS" di variabel agar kode lebih bersih
  final _inputDecoration = (String label, IconData icon) => InputDecoration(
    labelText: label,
    prefixIcon: Icon(icon, color: Colors.green),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Colors.green, width: 2),
    ),
  );

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final newMatch = MatchModel(
        id: 0,
        title: _titleController.text,
        jenis: _selectedJenis,
        tanggal: "${_selectedDate.toLocal()}".split(' ')[0],
        startTime: _startTime.format(context),
        endTime: _endTime.format(context),
        jumlahPemain: int.parse(_jmlPemainController.text),
        jumlahBergabung: 1,
        status: 'Open',
        deskripsi: _descController.text,
      );

      bool success = await MatchApi.createMatch(newMatch);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Match Berhasil Dibuat!")),
          );
          Navigator.pop(context, true);
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
        // Biar keyboard gak nutupin input
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Detail Pertandingan",
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

              // Dropdown Jenis Olahraga
              DropdownButtonFormField(
                value: _selectedJenis,
                decoration: _inputDecoration(
                  "Jenis Olahraga",
                  Icons.sports_soccer,
                ),
                items: ['Futsal', 'Basket', 'Badminton'].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) =>
                    setState(() => _selectedJenis = val.toString()),
              ),
              const SizedBox(height: 15),

              // Input Jumlah Pemain
              TextFormField(
                controller: _jmlPemainController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Maksimal Pemain", Icons.groups),
                validator: (v) => v!.isEmpty ? "Isi jumlah pemain" : null,
              ),
              const SizedBox(height: 15),

              // Input Deskripsi
              TextFormField(
                controller: _descController,
                maxLines: 3,
                decoration: _inputDecoration("Deskripsi", Icons.description),
              ),
              const SizedBox(height: 20),

              // Picker Tanggal (Styling pake Container biar kayak tombol bagus)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_today,
                    color: Colors.green,
                  ),
                  title: Text(
                    "Tanggal: ${_selectedDate.toLocal()}".split(' ')[0],
                  ),
                  onTap: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2027),
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
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
                    elevation: 5,
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
