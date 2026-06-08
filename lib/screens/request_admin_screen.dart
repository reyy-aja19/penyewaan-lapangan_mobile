import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RequestAdminScreen extends StatefulWidget {
  const RequestAdminScreen({super.key});

  @override
  State<RequestAdminScreen> createState() => _RequestAdminScreenState();
}

class _RequestAdminScreenState extends State<RequestAdminScreen> {
  final venueController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final reasonController = TextEditingController();
  bool isLoading = false;

  Future<void> submitRequest() async {
    setState(() {
      isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('user_id');

      if (userId == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User belum login")),
        );
        return;
      }

      // Berikan '/' di akhir URL untuk menghindari auto-redirect 301 dari web server
      final url = Uri.parse('https://sportsfield.my.id/api/request-admin');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
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

      if (!mounted) return;
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Pengajuan berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );

        // Bersihkan form setelah sukses
        venueController.clear();
        addressController.clear();
        phoneController.clear();
        reasonController.clear();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'Gagal mengirim pengajuan'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    venueController.dispose();
    addressController.dispose();
    phoneController.dispose();
    reasonController.dispose();
    super.dispose();
  }

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
              keyboardType: TextInputType.phone,
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
                onPressed: isLoading
                    ? null
                    : () async {
                        if (venueController.text.isEmpty ||
                            phoneController.text.isEmpty ||
                            reasonController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Semua field wajib diisi"),
                            ),
                          );
                          return;
                        }
                        await submitRequest();
                      },
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text("Kirim Pengajuan"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}