class MatchModel {
  final int id;
  final String title;
  final String jenis;
  final String tanggal;
  final String startTime;
  final String endTime;
  final int jumlahPemain;
  final int jumlahBergabung;
  final String status;
  final String deskripsi; // 1. PASTIKAN ADA BARIS INI

  MatchModel({
    required this.id,
    required this.title,
    required this.jenis,
    required this.tanggal,
    required this.startTime,
    required this.endTime,
    required this.jumlahPemain,
    required this.jumlahBergabung,
    required this.status,
    required this.deskripsi, // 2. PASTIKAN ADA BARIS INI
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      title: json['title'] ?? '',
      jenis: json['jenis'] ?? '',
      tanggal: json['tanggal'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      jumlahPemain: json['jumlah_pemain'] ?? 0,
      jumlahBergabung: json['jumlah_bergabung'] ?? 0,
      status: json['status'] ?? 'Open',
      deskripsi: json['deskripsi'] ?? '', // 3. PASTIKAN ADA BARIS INI
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'jenis': jenis,
      'tanggal': tanggal,
      'start_time': startTime,
      'end_time': endTime,
      'jumlah_pemain': jumlahPemain,
      'jumlah_bergabung': jumlahBergabung,
      'status': status,
      'deskripsi': deskripsi, // 4. PASTIKAN ADA BARIS INI
    };
  }
}
