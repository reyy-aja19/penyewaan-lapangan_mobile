import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DatabaseApi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // API 1: Simpan Data Booking (Digunakan saat tombol Bayar ditekan)
  Future<void> simpanBooking({
    required String namaUser,
    required String namaLapangan,
    required String tanggal,
    required String jam,
    required int totalHarga,
  }) async {
    try {
      await _firestore.collection('bookings').add({
        'user': namaUser,
        'lapangan': namaLapangan,
        'tanggal': tanggal,
        'jam': jam,
        'total': totalHarga,
        'status': 'Berhasil',
        'waktu_transaksi': FieldValue.serverTimestamp(),
      });
      debugPrint("Data Berhasil Tersimpan di API Firestore");
    } catch (e) {
      debugPrint("Gagal simpan data: $e");
    }
  }

  // API 2: Ambil Data Lapangan untuk ditampilkan di Home Screen
  Stream<QuerySnapshot> getDaftarLapangan() {
    return _firestore.collection('fields').snapshots();
  }
}