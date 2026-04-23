class FieldModel {
  final String id;
  final String name;
  final String type;
  final int price;
  final String imageUrl;
  final String description;
  final String status;

  FieldModel({
    required this.id,
    required this.name,
    required this.type,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.status,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      // Konversi num/double ke int
      price: (json['price_per_hour'] as num).toInt(),
      imageUrl: json['image_url'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
    );
  }
}