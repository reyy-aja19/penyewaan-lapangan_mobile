import 'package:flutter/material.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  void submit() {
    if (newPassword.text != confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password tidak cocok")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password berhasil diubah (dummy)")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ubah Password")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: oldPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password Lama"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: newPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password Baru"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: confirmPassword,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Konfirmasi Password"),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: submit,
                child: const Text("Simpan"),
              ),
            )
          ],
        ),
      ),
    );
  }
}