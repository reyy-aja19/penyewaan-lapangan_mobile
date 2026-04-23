import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Import Screens
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/payment_screen.dart';
import 'screens/history_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/point_screen.dart';
import 'screens/match_screen.dart';

// Catatan: ScheduleScreen dan CheckoutScreen tidak di-import di sini 
// karena sudah tidak dipakai di routing statis (MaterialApp routes).

void main() async {
  // Wajib tambahin ini kalau pakai async di main
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SportsFieldApp());
}

class SportsFieldApp extends StatelessWidget {
  const SportsFieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sports Field Rental',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00A32A),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const MainNavigation(),
        // REVISI: Route /schedule dan /checkout dihapus dari sini 
        // karena sekarang menggunakan Navigator.push manual untuk kirim data.
        '/history': (context) => const HistoryScreen(),
        '/payment': (context) => const PaymentScreen(),
      },
    );
  }
}

// --- Wrapper untuk Bottom Navigation ---
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 2; // Default ke Home (index ke-2)

  @override
  Widget build(BuildContext context) {
    // List halaman untuk navigasi bawah
    final List<Widget> _pages = [
      const HistoryScreen(),
      const PointScreen(),
      HomeScreen(
        onProfileTap: () {
          setState(() {
            _index = 4; // Berpindah ke tab Profil (index 4)
          });
        },
      ),
      const MatchScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (val) {
          setState(() {
            _index = val;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF00A32A),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white60,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_outlined), 
            activeIcon: Icon(Icons.calendar_month),
            label: 'Booking',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined), 
            activeIcon: Icon(Icons.monetization_on),
            label: 'Poin',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined), 
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_tennis_outlined), 
            activeIcon: Icon(Icons.sports_tennis),
            label: 'Match',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), 
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}