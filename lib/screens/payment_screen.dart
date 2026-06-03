import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:penyewaan_lapangan/screens/history_screen.dart'; // Pastikan path import ini sesuai dengan struktur folder lu, atau gunakan named route jika ada

class PaymentScreen extends StatefulWidget {
  final String paymentUrl;

  // Menerima redirect_url dari CheckoutScreen
  const PaymentScreen({super.key, required this.paymentUrl});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Inisialisasi WebViewController untuk memuat halaman Midtrans Snap
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);

            // DETEKSI STRING REDIRECT DARI MIDTRANS/BACKEND JIKA SUKSES
            // Jika URL mengandung kata finish, atau success, langsung tendang ke History
            if (url.contains('finish') || url.contains('success') || url.contains('status-pembayaran')) {
              _redirectToHistory();
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Izinkan WebView berpindah ke halaman pembayaran Midtrans
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  // --- LOGIKA UTAMA: REDIRECT PAKSA KE HISTORY SCREEN ---
  void _redirectToHistory() {
    if (mounted) {
      // Opsi 1: Jika lu mendaftarkan route '/history' di main.dart
      Navigator.pushNamedAndRemoveUntil(context, '/history', (route) => route.isFirst);

      // Opsi 2: Cadangan jika Opsi 1 ga jalan (panggil class screen-nya langsung)
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(builder: (context) => const HistoryScreen()),
      //   (route) => route.isFirst,
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Pembayaran",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: Colors.black,
          onPressed: () {
            // Konfirmasi jika user ingin keluar dari halaman pembayaran
            _showCancelDialog(context);
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF00A32A),
              ),
            ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Apakah anda ingin keluar?", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Apakah kamu yakin ingin keluar? Kamu bisa mengecek status pembayaranmu nanti di halaman riwayat."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tidak", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog konfirmasi
              _redirectToHistory();   // Pindahkan user langsung ke halaman riwayat
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              elevation: 0,
            ),
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}