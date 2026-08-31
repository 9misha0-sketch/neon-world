import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'main.dart' as core;
import 'video_chat.dart';

const supabaseUrl = 'https://orxnuxqhsqedetspjfov.supabase.co';
const supabaseKey = 'sb_publishable_uiFqR9SCnKiPssCj_1Vldg_ll7HkGJP';
const checkoutUrl = String.fromEnvironment('CHECKOUT_URL', defaultValue: '');

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeonBetV33());
}

class NeonBetV33 extends StatefulWidget {
  const NeonBetV33({super.key});
  @override
  State<NeonBetV33> createState() => _NeonBetV33State();
}

class _NeonBetV33State extends State<NeonBetV33> {
  bool backendReady = false;
  bool backendLoading = true;
  String? backendError;

  @override
  void initState() {
    super.initState();
    _initBackend();
  }

  Future<void> _initBackend() async {
    if (mounted) {
      setState(() {
        backendLoading = true;
        backendError = null;
      });
    }
    try {
      await Supabase.initialize(url: supabaseUrl, publishableKey: supabaseKey);
      final client = Supabase.instance.client;
      if (client.auth.currentUser == null) {
        await client.auth.signInAnonymously();
      }
      if (!mounted) return;
      setState(() {
        backendReady = true;
        backendLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        backendReady = false;
        backendLoading = false;
        backendError = 'הווידאו צ׳אט לא התחבר לשרת. המשחקים עדיין זמינים.';
      });
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NEON BET',
        theme: ThemeData.dark(useMaterial3: true),
        home: MembershipGateV33(
          backendReady: backendReady,
          backendLoading: backendLoading,
          backendError: backendError,
          onRetryBackend: _initBackend,
        ),
      );
}

class MembershipGateV33 extends StatefulWidget {
  final bool backendReady;
  final bool backendLoading;
  final String? backendError;
  final Future<void> Function() onRetryBackend;

  const MembershipGateV33({
    super.key,
    required this.backendReady,
    required this.backendLoading,
    required this.backendError,
    required this.onRetryBackend,
  });

  @override
  State<MembershipGateV33> createState() => _MembershipGateV33State();
}

class _MembershipGateV33State extends State<MembershipGateV33> {
  bool active = false;

  Future<void> _subscribe() async {
    if (checkoutUrl.isEmpty) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('המנוי מוכן לחיבור'),
          content: Text('המנוי הוא עבור גישה ל־Play Money ולווידאו צ׳אט בלבד. כדי לבצע חיוב חודשי של 30₪ יש לחבר כתובת Checkout של ספק סליקה מאושר.'),
        ),
      );
      return;
    }
    final uri = Uri.tryParse(checkoutUrl);
    if (uri == null || !await canLaunchUrl(uri)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('לא ניתן לפתוח כרגע את עמוד התשלום')));
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (active) {
      return MainShellV33(
        backendReady: widget.backendReady,
        backendLoading: widget.backendLoading,
        backendError: widget.backendError,
        onRetryBackend: widget.onRetryBackend,
      );
    }

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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 90),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(Icons.workspace_premium, size: 78, color: Color(0xFFFFD166)),
                    const SizedBox(height: 20),
                    const Text('NEON BET CLUB', textAlign: TextAlign.center, style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 10),
                    const Text('30₪ / חודש', textAlign: TextAlign.center, style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 14),
                    const Text('מנוי גישה ל־Play Money ולווידאו צ׳אט 18+. אין הפקדות, משיכות או זכיות בכסף אמיתי.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.5, color: Color(0xFFBCC5D8))),
                    const SizedBox(height: 18),
                    _BackendBadge(ready: widget.backendReady, loading: widget.backendLoading, error: widget.backendError),
                    const SizedBox(height: 22),
                    FilledButton(
                      onPressed: _subscribe,
                      style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C4CFF), padding: const EdgeInsets.all(18)),
                      child: const Text('הצטרף ב־30₪ לחודש', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(onPressed: () => setState(() => active = true), child: const Text('כניסה למצב בדיקה')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MainShellV33 extends StatefulWidget {
  final bool backendReady;
  final bool backendLoading;
  final String? backendError;
  final Future<void> Function() onRetryBackend;

  const MainShellV33({
    super.key,
    required this.backendReady,
    required this.backendLoading,
    required this.backendError,
    required this.onRetryBackend,
  });

  @override
  State<MainShellV33> createState() => _MainShellV33State();
}

class _MainShellV33State extends State<MainShellV33> {
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
    final videoPage = widget.backendReady
        ? const VideoChatPage()
        : BackendStatusPage(
            loading: widget.backendLoading,
            error: widget.backendError,
            onRetry: widget.onRetryBackend,
          );

    final pages = [
      core.HomeContent(balance: balance, onPlay: () => setState(() => index = 1), onBonus: claimBonus),
      core.GamesPage(balance: balance, onBalance: changeBalance),
      videoPage,
      core.BonusPage(balance: balance, claimed: bonusClaimed, onClaim: claimBonus),
      core.ProfilePage(balance: balance),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF050817),
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
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

class _BackendBadge extends StatelessWidget {
  final bool ready;
  final bool loading;
  final String? error;

  const _BackendBadge({required this.ready, required this.loading, required this.error});

  @override
  Widget build(BuildContext context) {
    final text = ready ? '● שרת וידאו מחובר' : loading ? 'מתחבר לשרת הווידאו…' : (error ?? 'שרת הווידאו לא זמין');
    final color = ready ? Colors.greenAccent : loading ? Colors.cyanAccent : Colors.orangeAccent;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(color: const Color(0xFF11182A), borderRadius: BorderRadius.circular(14)),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
    );
  }
}

class BackendStatusPage extends StatelessWidget {
  final bool loading;
  final String? error;
  final Future<void> Function() onRetry;

  const BackendStatusPage({super.key, required this.loading, required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(loading ? Icons.sync : Icons.videocam_off_outlined, size: 72, color: loading ? Colors.cyanAccent : Colors.orangeAccent),
                const SizedBox(height: 18),
                Text(loading ? 'מתחבר לווידאו צ׳אט…' : (error ?? 'הווידאו צ׳אט לא זמין כרגע'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text('המשחקים ושאר האפליקציה ממשיכים לעבוד גם אם שרת הווידאו אינו זמין.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9CA8BD))),
                const SizedBox(height: 22),
                FilledButton.icon(onPressed: loading ? null : onRetry, icon: const Icon(Icons.refresh), label: const Text('נסה להתחבר שוב')),
              ],
            ),
          ),
        ),
      );
}
