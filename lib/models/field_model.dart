class FieldModel {
  final int id;
  final String name;
  final String type;
  final int price;
  final String? imageUrl; // Menambahkan ? agar boleh null
  final String? description; // Menambahkan ? agar boleh null
  final String status;

  FieldModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    this.imageUrl, // Kata kunci 'required' dihapus karena boleh null
    this.description, // Kata kunci 'required' dihapus karena boleh null
    required this.status,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    // Ganti IP dengan IP Laptop/Server Laravelmu yang benar
    String baseUrl = "https://sportsfield.cicd.my.id/";

    return FieldModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['nama'] ?? 'Tanpa Nama',
      type: json['jenis'] ?? 'Umum',
      price: (json['harga'] as num?)?.toInt() ?? 0,

      // Gabungkan baseUrl dengan path 'foto' dari JSON
      imageUrl: json['foto'] != null ? baseUrl + json['foto'] : null,

      description: json['deskripsi'] ?? 'Tidak ada deskripsi',
      status: json['status'] ?? 'available',
    );
  }
}
