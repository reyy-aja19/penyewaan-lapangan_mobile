import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:penyewaan_lapangan/services/api_service.dart';

class PointScreen extends StatefulWidget {
  const PointScreen({super.key});

  @override
  State<PointScreen> createState() => _PointScreenState();
}

class _PointScreenState extends State<PointScreen> {
  final ApiService _apiService = ApiService();
  int _userPoints = 0;
  List<dynamic> _rewards = [];
  bool _isLoadingRewards = true;
  bool _isProcessingRedeem = false;

  @override
  void initState() {
    super.initState();
    _loadUserPoints();
    _fetchRewardsFromApi();
  }

  // 1. Ambil poin user dari lokal data pencatatan login
 Future<void> _loadUserPoints() async {
  try {
    final result = await _apiService.getUserProfile();

    if (result != null && result['status'] == true) {
      final serverUser = result['data'];

      setState(() {
        _userPoints = serverUser['points'] ?? 0;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', jsonEncode(serverUser));
    } else {
      print("API user gagal / format salah: $result");
    }
  } catch (e) {
    print("Error load user points: $e");
  }
}
  // 2. Ambil list reward sesuai yang diinput di Web Admin
  Future<void> _fetchRewardsFromApi() async {
    try {
      final result = await _apiService.getRewards(); 
      if (result['status'] == true) {
        setState(() {
          // Memastikan mengambil data reward yang statusnya 'Aktif' saja
          _rewards = result['data'] ?? [];
          _isLoadingRewards = false;
        });
      } else {
        _showSnackBar("Gagal memuat daftar reward", Colors.red);
        setState(() => _isLoadingRewards = false);
      }
    } catch (e) {
      print("Error fetch rewards: $e");
      _showSnackBar("Gagal terhubung ke server admin", Colors.red);
      setState(() => _isLoadingRewards = false);
    }
  }

  // 3. Proses penukaran poin & memunculkan Bukti Klaim (Kode Redeem/QR)
  Future<void> _handleRedeem(int rewardId, int pointsCost, String rewardName) async {
    setState(() => _isProcessingRedeem = true);
    
    try {
      final result = await _apiService.redeemReward(rewardId: rewardId);

      if (result['status'] == true) {
        // Ambil data kode redeem atau link QR dari response backend Laravel
        String redeemCode = result['kode_redeem'] ?? 'KODE-REDEEM-OK';
        String? qrUrl = result['qr_url']; 

        // Update SharedPreferences lokal dengan sisa poin terbaru dari server
        final prefs = await SharedPreferences.getInstance();
        final String? userRaw = prefs.getString('user');
        if (userRaw != null) {
          Map<String, dynamic> userData = jsonDecode(userRaw);
          userData['points'] = result['current_points'] ?? (_userPoints - pointsCost);
          await prefs.setString('user', jsonEncode(userData));
        }

        // Refresh poin di UI aplikasi
        await _loadUserPoints();

        // Tampilkan dialog sukses beserta kode klaim untuk diserahkan ke admin
        if (mounted) {
          _showSuccessDialog(rewardName, redeemCode, qrUrl);
        }
      } else {
        _showSnackBar(result['message'] ?? "Gagal menukarkan poin", Colors.red);
      }
    } catch (e) {
      print("Error redeem: $e");
      _showSnackBar("Terjadi kesalahan sistem penukaran", Colors.red);
    } finally {
      if (mounted) setState(() => _isProcessingRedeem = false);
    }
  }

  

  // Dialog sukses yang menampilkan Kode Redeem / QR sesuai tabel web admin
  void _showSuccessDialog(String rewardName, String code, String? qrUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: const Column(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF00A32A), size: 60),
              SizedBox(height: 10),
              Text("Penukaran Berhasil", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Kamu berhasil menukarkan poin dengan:\n$rewardName",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              const Text("KODE REDEEM KAMU:", style: TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  code,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                ),
              ),
              if (qrUrl != null) ...[
                const SizedBox(height: 15),
                Image.network(qrUrl, height: 120, width: 120, errorBuilder: (c, e, s) => const Icon(Icons.qr_code, size: 100)),
              ]
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Selesai", style: TextStyle(color: Color(0xFF00A32A), fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          "Poin Saya",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Card Poin Dinamis Atas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00A32A), Color(0xFF00D136)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00A32A).withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Poin Kamu",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "$_userPoints Poin",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    "Tukarkan dengan voucher di bawah sebelum hangus!",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Daftar Reward",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 15),

            // Membaca data dinamis dari Admin Web Laravel
            _isLoadingRewards
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Color(0xFF00A32A)),
                    ),
                  )
                : _rewards.isEmpty
                    ? const Center(
                        child: Text("Tidak ada reward aktif saat ini."),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _rewards.length,
                        itemBuilder: (context, index) {
                          final item = _rewards[index];
                          
                          // Pastikan penamaan key JSON sesuai dengan response API Laravel kamu
                          // Contoh: item['poin'] atau item['points_required']
                          return _rewardTile(
                            id: item['id'] ?? 0,
                            title: item['name'] ?? item['title'] ?? '',
                            costValue: item['points'] ?? item['points_required'] ?? 0,
                            imagePath: item['image_url'], // jika admin mengirim url image dari public/storage
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }

  Widget _rewardTile({
    required int id,
    required String title,
    required int costValue,
    String? imagePath,
  }) {
    bool canRedeem = _userPoints >= costValue;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: imagePath != null
              ? Image.network(
                  imagePath,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => _fallbackIcon(title),
                )
              : _fallbackIcon(title),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(
          "$costValue Poin",
          style: const TextStyle(
            color: Color(0xFF00A32A),
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: (canRedeem && !_isProcessingRedeem)
              ? () => _handleRedeem(id, costValue, title)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00A32A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 15),
          ),
          child: _isProcessingRedeem 
              ? const SizedBox(
                  width: 15,
                  height: 15,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text("Tukar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Jika URL Gambar dari backend kosong, otomatis pakai icon penunjang berdasarkan judul di Admin
  Widget _fallbackIcon(String title) {
    IconData icon = Icons.card_giftcard;
    if (title.toLowerCase().contains('minuman')) {
      icon = Icons.local_drink;
    } else if (title.toLowerCase().contains('diskon') || title.toLowerCase().contains('%')) {
      icon = Icons.confirmation_number_outlined;
    } else if (title.toLowerCase().contains('jam') || title.toLowerCase().contains('sewa')) {
      icon = Icons.access_time_filled;
    }

    return Container(
      width: 50,
      height: 50,
      color: Colors.green.withOpacity(0.1),
      child: Icon(icon, color: const Color(0xFF00A32A)),
    );
  }
}