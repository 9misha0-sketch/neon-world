import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const checkoutUrl = String.fromEnvironment('CHECKOUT_URL', defaultValue: '');

void main() => runApp(const NeonBetApp());

class NeonBetApp extends StatelessWidget {
  const NeonBetApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEON BET',
      theme: ThemeData.dark(useMaterial3: true),
      home: const MembershipGate(),
    );
  }
}

class MembershipGate extends StatefulWidget {
  const MembershipGate({super.key});
  @override
  State<MembershipGate> createState() => _MembershipGateState();
}

class _MembershipGateState extends State<MembershipGate> {
  bool active = false;

  Future<void> _subscribe() async {
    if (checkoutUrl.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('הסליקה עדיין לא מחוברת'),
          content: Text('מסך המנוי מוכן. כדי לחייב 30₪ בחודש צריך לחבר חשבון סליקה וכתובת Checkout מאובטחת.'),
        ),
      );
      return;
    }
    final uri = Uri.parse(checkoutUrl);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (active) return const HomePage();
    return Scaffold(
      backgroundColor: const Color(0xFF050817),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2A155F), Color(0xFF07394C), Color(0xFF050817)],
          ),
        ),
        child: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.workspace_premium, size: 78, color: Color(0xFFFFD166)),
                  const SizedBox(height: 20),
                  const Text('NEON BET CLUB', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  const Text('מנוי חודשי', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, color: Color(0xFF6EE7F5), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('30₪ / חודש', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 22),
                  const Text('המנוי מעניק גישה לאפליקציה ולמשחקי Play Money בלבד. אין הפקדות, משיכות או זכיות בכסף אמיתי.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFBCC5D8))),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _subscribe,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C4CFF), padding: const EdgeInsets.all(18)),
                    child: const Text('הצטרף ב־30₪ לחודש', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: () => setState(() => active = true),
                    child: const Text('מצב בדיקה למפתח'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
