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
  final _descController = TextEditingController(); // Pastikan di model ada deskripsi jika perlu

  String _selectedJenis = 'Futsal';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 16, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 17, minute: 0);

  // Fungsi untuk memanggil API
  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final newMatch = MatchModel(
        id: 0, // ID akan diatur oleh database
        title: _titleController.text,
        jenis: _selectedJenis,
        tanggal: "${_selectedDate.toLocal()}".split(' ')[0], // Format YYYY-MM-DD
        startTime: _startTime.format(context),
        endTime: _endTime.format(context),
        jumlahPemain: int.parse(_jmlPemainController.text),
        jumlahBergabung: 1, // Pembuat otomatis jadi pemain pertama
        status: 'Open',
        deskripsi: _descController.text,
      );

      bool success = await MatchApi.createMatch(newMatch);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Match Berhasil Dibuat!")),
          );
          Navigator.pop(context, true); // Kembali ke list dan refresh
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gagal membuat match. Cek koneksi/server.")),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Buat Match Baru")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Judul Match"),
                validator: (v) => v!.isEmpty ? "Isi judul dulu" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: _selectedJenis,
                items: ['Futsal', 'Basket', 'Badminton'].map((e) {
                  return DropdownMenuItem(value: e, child: Text(e));
                }).toList(),
                onChanged: (val) => setState(() => _selectedJenis = val.toString()),
                decoration: const InputDecoration(labelText: "Jenis Olahraga"),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _jmlPemainController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Maksimal Pemain"),
                validator: (v) => v!.isEmpty ? "Isi jumlah pemain" : null,
              ),
              const SizedBox(height: 20),
              ListTile(
                title: Text("Tanggal: ${_selectedDate.toLocal()}".split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
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
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                child: const Text("SIMPAN MATCH"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}