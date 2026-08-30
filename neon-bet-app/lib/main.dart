import 'package:flutter/material.dart';

void main() => runApp(const NeonBetApp());

class NeonBetApp extends StatelessWidget {
  const NeonBetApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEON BET',
      theme: ThemeData.dark(useMaterial3: true),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  final pages = const [HomeContent(), GamesPage(), BonusPage(), ProfilePage()];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050817),
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF0B1020),
        indicatorColor: const Color(0xFF6C4CFF),
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'בית'),
          NavigationDestination(icon: Icon(Icons.casino_outlined), selectedIcon: Icon(Icons.casino), label: 'משחקים'),
          NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'בונוס'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'פרופיל'),
        ],
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFF27155E), Color(0xFF07384B), Color(0xFF050817)], stops: [0, .42, .78]),
      ),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('NEON BET', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11), decoration: BoxDecoration(color: const Color(0xFF11182A), borderRadius: BorderRadius.circular(18)), child: const Text('25,000 🪙', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            ]),
            const SizedBox(height: 65),
            const Text('SOCIAL CASINO • PLAY MONEY ONLY', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF24D9E7), fontWeight: FontWeight.w800, letterSpacing: 1.4)),
            const SizedBox(height: 18),
            const Text('הדור הבא של\nמשחקי הקזינו', textAlign: TextAlign.center, style: TextStyle(fontSize: 46, height: 1.12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            const Text('חוויה מהירה עם מטבעות וירטואליים בלבד.\nללא הפקדות, ללא משיכות וללא הימורים בכסף אמיתי.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB7BED0), fontSize: 17, height: 1.55)),
            const SizedBox(height: 28),
            FilledButton(onPressed: () {}, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C4CFF), padding: const EdgeInsets.all(18)), child: const Text('שחק עכשיו', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(17)), child: const Text('🎁 בונוס יומי', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 28),
            Card(color: const Color(0xFF10182A), child: Padding(padding: const EdgeInsets.all(28), child: Column(children: const [Text('NEON JACKPOT', style: TextStyle(color: Color(0xFFFFD66B), fontWeight: FontWeight.bold, fontSize: 18)), SizedBox(height: 15), Text('8,472,221', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900)), SizedBox(height: 8), Text('מטבעות וירטואליים', style: TextStyle(color: Color(0xFFB7BED0), fontSize: 16))]))),
          ]),
        ),
      ),
    );
  }
}

class GamesPage extends StatelessWidget {
  const GamesPage({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('🎰 משחקים', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)));
}
class BonusPage extends StatelessWidget {
  const BonusPage({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('🎁 בונוס יומי', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)));
}
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('👤 פרופיל', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)));
}
