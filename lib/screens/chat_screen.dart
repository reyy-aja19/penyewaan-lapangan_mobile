import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/match_api.dart';

class ChatScreen extends StatefulWidget {
  final int matchId;
  final String matchTitle;

  const ChatScreen({
    super.key,
    required this.matchId,
    required this.matchTitle,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  List<dynamic> _messages = [];
  bool _isLoading = true;
  String _currentUserName = "";
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchChatInitial();
    // Jalankan polling: Ambil data chat baru setiap 3 detik secara berkala
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchChatSilent();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); // Hentikan timer saat keluar dari halaman chat
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Mengambil nama user yang login untuk membedakan chat kanan/kiri
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    // Pastikan key 'name' sesuai dengan nama key saat kamu simpan data login di shared_prefs
    setState(() {
      _currentUserName = prefs.getString('user_name') ?? prefs.getString('name') ?? "";
    });
  }

  // Load chat pertama kali dengan loading spinner
  Future<void> _fetchChatInitial() async {
    try {
      final data = await MatchApi.fetchMessages(widget.matchId);
      setState(() {
        _messages = data;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar("Gagal memuat chat: $e", Colors.red);
    }
  }

  // Ambil chat di latar belakang (tanpa memicu loading spinner agar tidak berkedip)
  Future<void> _fetchChatSilent() async {
    try {
      final data = await MatchApi.fetchMessages(widget.matchId);
      if (data.length != _messages.length) {
        setState(() {
          _messages = data;
        });
        _scrollToBottom();
      }
    } catch (e) {
      print("Gagal sinkronisasi chat otomatis: $e");
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    bool success = await MatchApi.sendMessage(widget.matchId, text);
    if (success) {
      _fetchChatSilent(); // Refresh data chat langsung setelah berhasil kirim
    } else {
      _showSnackBar("Pesan gagal dikirim", Colors.red);
    }
  }

  void _showSnackBar(String msg, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: color),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              widget.matchTitle,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
            ),
            const Text(
              "Grup Koordinasi Match",
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF00A32A)))
          : Column(
              children: [
                Expanded(
                  child: _messages.isEmpty
                      ? const Center(
                          child: Text(
                            "Belum ada obrolan.\nYuk, sapa anggota match lainnya! 👋",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(15),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final chat = _messages[index];
                            final String senderName = chat['user']?['name'] ?? 'Anonim';
                            final String text = chat['message'] ?? '';
                            final bool isMe = senderName.toLowerCase() == _currentUserName.toLowerCase();

                            return _buildChatBubble(senderName, text, isMe);
                          },
                        ),
                ),
                _buildChatInput(),
              ],
            ),
    );
  }

  Widget _buildChatBubble(String sender, String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFF00A32A) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMe ? const Radius.circular(12) : const Radius.circular(0),
            bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 5,
              offset: const Offset(0, 2),
            )
          ],
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Text(
                sender,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF00A32A),
                ),
              ),
            if (!isMe) const SizedBox(height: 3),
            Text(
              text,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      color: Colors.white,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: "Tulis pesan di sini...",
                  hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: const Color(0xFFF4F6F8),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
            ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF00A32A),
              radius: 22,
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white, size: 18),
                onPressed: _handleSend,
              ),
            )
          ],
        ),
      ),
    );
  }
}