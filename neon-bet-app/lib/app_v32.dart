import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart' as core;
import 'video_chat.dart';

const supabaseUrl = 'https://orxnuxqhsqedetspjfov.supabase.co';
const supabaseKey = 'sb_publishable_uiFqR9SCnKiPssCj_1Vldg_ll7HkGJP';
const checkoutUrl = String.fromEnvironment('CHECKOUT_URL', defaultValue: '');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const NeonBetV32());
}

class NeonBetV32 extends StatelessWidget {
  const NeonBetV32({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NEON BET',
        theme: ThemeData.dark(useMaterial3: true),
        home: const MembershipGateV32(),
      );
}

class MembershipGateV32 extends StatefulWidget {
  const MembershipGateV32({super.key});
  @override
  State<MembershipGateV32> createState() => _MembershipGateV32State();
}

class _MembershipGateV32State extends State<MembershipGateV32> {
  bool active = false;

  Future<void> _subscribe() async {
    if (checkoutUrl.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('הסליקה עדיין לא מחוברת'),
          content: Text('המנוי הוא עבור גישה לאפליקציה ולתכני Play Money בלבד. כדי לחייב 30₪ בחודש יש לחבר כתובת Checkout של ספק סליקה מאושר.'),
        ),
      );
      return;
    }
    await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (active) return const MainShellV32();
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
                  const Text('30₪ / חודש', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 18),
                  const Text('מנוי גישה ל־Play Money ולווידאו צ׳אט 18+. אין הפקדות, משיכות או זכיות בכסף אמיתי.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFBCC5D8))),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: _subscribe,
                    style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C4CFF), padding: const EdgeInsets.all(18)),
                    child: const Text('הצטרף ב־30₪ לחודש', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: () => setState(() => active = true), child: const Text('מצב בדיקה למפתח')),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShellV32 extends StatefulWidget {
  const MainShellV32({super.key});
  @override
  State<MainShellV32> createState() => _MainShellV32State();
}

class _MainShellV32State extends State<MainShellV32> {
  int index = 0;
  int balance = 25000;
  bool bonusClaimed = false;

  void changeBalance(int delta) => setState(() => balance = max(0, balance + delta));

  void claimBonus() {
    if (bonusClaimed) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('כבר אספת את הבונוס בסשן הזה')));
      return;
    }
    setState(() {
      balance += 2500;
      bonusClaimed = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🎁 קיבלת 2,500 מטבעות וירטואליים')));
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      core.HomeContent(balance: balance, onPlay: () => setState(() => index = 1), onBonus: claimBonus),
      core.GamesPage(balance: balance, onBalance: changeBalance),
      const VideoChatPage(),
      core.BonusPage(balance: balance, claimed: bonusClaimed, onClaim: claimBonus),
      core.ProfilePage(balance: balance),
    ];
    return Scaffold(
      backgroundColor: const Color(0xFF050817),
      body: SafeArea(child: pages[index]),
      bottomNavigationBar: NavigationBar(
        height: 70,
        backgroundColor: const Color(0xFF0B1020),
        indicatorColor: const Color(0xFF6C4CFF),
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'בית'),
          NavigationDestination(icon: Icon(Icons.casino_outlined), selectedIcon: Icon(Icons.casino), label: 'משחקים'),
          NavigationDestination(icon: Icon(Icons.video_call_outlined), selectedIcon: Icon(Icons.video_call), label: 'וידאו 18+'),
          NavigationDestination(icon: Icon(Icons.card_giftcard), label: 'בונוס'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'פרופיל'),
        ],
      ),
    );
  }
}
