import 'package:flutter/material.dart';
import 'detail_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:penyewaan_lapangan/models/field_model.dart';
import '../models/notification_model.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onProfileTap;
  const HomeScreen({super.key, this.onProfileTap});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<FieldModel>> futureFields;
  late Future<List<NotificationModel>> futureNotifications;
  List<FieldModel> allFields = [];
  List<FieldModel> filteredFields = [];
  String selectedCategory = "Semua";

  @override
  void initState() {
    super.initState();
    futureFields = fetchFields();
    futureNotifications = fetchNotifications();
  }

  // 🔥 Ambil data dari Laravel API
  Future<List<FieldModel>> fetchFields() async {
    try {
      final response = await http.get(
        Uri.parse('https://sportsfield.my.id/api/fields'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<FieldModel> fields = (data['data'] as List)
            .map((json) => FieldModel.fromJson(json))
            .toList();

        setState(() {
          allFields = fields;
          filteredFields = fields;
        });

        return fields;
      } else {
        throw Exception('Gagal ambil data');
      }
    } catch (e) {
      print("Error Fetching: $e");
      return [];
    }
  }

  Future<List<NotificationModel>> fetchNotifications() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://sportsfield.my.id/api/notifications/1',
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return (data['data'] as List)
            .map((e) => NotificationModel.fromJson(e))
            .toList();
      }
    } catch (e) {
      print(e);
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<List<FieldModel>>(
        future: futureFields,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00A32A)),
            );
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Gagal mengambil data"));
          }

          // FIX: Variabel ini kita manfaatkan untuk list di bawahnya agar tidak mubazir 🚀
          final dataFields = filteredFields;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    "Kategori Olahraga",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                _buildCategories(),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Text(
                    "Venue Pilihan Untukmu",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                _buildHorizontalList(context, dataFields), // <-- Diubah menggunakan dataFields
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  child: Text(
                    "Rekomendasi Terdekat",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
                _buildVerticalList(dataFields), // <-- Diubah menggunakan dataFields
              ],
            ),
          );
        },
      ),
    );
  }

  // ================= UI =================

  Widget _buildHorizontalList(BuildContext context, List<FieldModel> fields) {
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: fields.length,
        itemBuilder: (context, index) {
          return _cardVenue(context, fields[index]);
        },
      ),
    );
  }

  Widget _cardVenue(BuildContext context, FieldModel field) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 15, bottom: 10),
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailScreen(field: field)),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  field.imageUrl ?? '', 
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      height: 120,
                      color: Colors.grey[100],
                      child: const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Color(0xFF00A32A),
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 120,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.image, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Tersedia",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Rp ${field.price} / jam",
                      style: const TextStyle(
                        color: Color(0xFF00A32A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalList(List<FieldModel> fields) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: fields.length,
      itemBuilder: (context, index) {
        final field = fields[index];

        return Card(
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                field.imageUrl ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            title: Text(
              field.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${field.type} | Rp ${field.price}"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailScreen(field: field),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: Color(0xFF00A32A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Lokasi Kamu",
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  Text(
                    "📍 Indramayu, ID",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  FutureBuilder<List<NotificationModel>>(
                    future: futureNotifications,
                    builder: (context, snapshot) {
                      final count = snapshot.data?.length ?? 0;

                      return Stack(
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.notifications,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => NotificationScreen(
                                    notifications: snapshot.data ?? [],
                                  ),
                                ),
                              );
                            },
                          ),
                          if (count > 0)
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  "$count",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: widget.onProfileTap,
                    child: const CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 25),
          TextField(
            onChanged: (value) {
              setState(() {
                filteredFields = allFields.where((item) {
                  return item.name.toLowerCase().contains(value.toLowerCase());
                }).toList();
              });
            },
            decoration: InputDecoration(
              hintText: "Cari venue...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategories() {
    List<String> categories = [
      "Semua",
      "Futsal",
      "Badminton",
    ];

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isActive = selectedCategory == cat;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategory = cat;

                if (cat == "Semua") {
                  filteredFields = allFields;
                } else {
                  filteredFields =
                      allFields.where((e) => e.type == cat).toList();
                }
              });
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding:
                  const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFF00A32A) : Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}