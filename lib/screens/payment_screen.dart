import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class PaymentScreen extends StatefulWidget {
  final String paymentUrl;

  const PaymentScreen({
    super.key,
    required this.paymentUrl,
  });

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

  // 🔥 DETEKSI MIDTRANS SUCCESS
  if (url.contains("status_code=200") ||
      url.contains("transaction_status=settlement")) {
    Navigator.pop(context, true); // SUCCESS
  }

  // ❌ jika gagal / close
  if (url.contains("transaction_status=deny") ||
      url.contains("transaction_status=cancel") ||
      url.contains("transaction_status=expire")) {
    Navigator.pop(context, false);
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
        title: const Text("Apakah anda ingin keluar?"),
        content: const Text("Apakah kamu yakin ingin keluar? Kamu bisa mengecek status pembayaranmu nanti di halaman riwayat."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tidak", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Keluar dari PaymentScreen
            },
            child: const Text("Ya, Keluar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}