import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestAdminScreen extends StatefulWidget {
  const RequestAdminScreen({super.key});

  @override
  State<RequestAdminScreen> createState() =>
      _RequestAdminScreenState();
}

class _RequestAdminScreenState
    extends State<RequestAdminScreen> {
      Future<void> submitRequest() async {
  try {
    final prefs = await SharedPreferences.getInstance();

    final userId = prefs.getInt('user_id');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("User belum login"),
        ),
      );
      return;
    }

    final response = await http.post(
  Uri.parse('https://sportsfield.my.id/api/request-admin'),
  headers: {
    'Content-Type': 'application/json',
    'Accept': 'application/json', // 🔥 penting
  },
  body: jsonEncode({
    'user_id': userId,
    'venue_name': venueController.text,
    'phone': phoneController.text,
    'reason': reasonController.text,
  }),
);
print("STATUS: ${response.statusCode}");
print("BODY: ${response.body}");
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Pengajuan berhasil dikirim',
          ),
        ),
      );

      venueController.clear();
      addressController.clear();
      phoneController.clear();
      reasonController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            data['message'] ?? 'Gagal mengirim pengajuan',
          ),
        ),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Error: $e',
        ),
      ),
    );
  }
}

  final venueController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final reasonController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengajuan Pengelola Venue"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            TextField(
              controller: venueController,
              decoration: const InputDecoration(
                labelText: "Nama Venue",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Alamat Venue",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: "Nomor HP",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: "Alasan Pengajuan",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {

  if (venueController.text.isEmpty ||
      phoneController.text.isEmpty ||
      reasonController.text.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Semua field wajib diisi",
        ),
      ),
    );

    return;
  }

  await submitRequest();
},
                child: const Text(
                  "Kirim Pengajuan",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}