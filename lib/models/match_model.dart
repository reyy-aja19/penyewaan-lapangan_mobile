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
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'],
      title: json['title'],
      jenis: json['jenis'],
      tanggal: json['tanggal'],
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      jumlahPemain: json['jumlah_pemain'],
      jumlahBergabung: json['jumlah_bergabung'],
      status: json['status'],
    );
  }
}