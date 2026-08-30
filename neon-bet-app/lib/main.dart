import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

const checkoutUrl = String.fromEnvironment('CHECKOUT_URL', defaultValue: '');

void main() => runApp(const NeonBetApp());

class NeonBetApp extends StatelessWidget {
  const NeonBetApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NEON BET',
        theme: ThemeData.dark(useMaterial3: true),
        home: const MembershipGate(),
      );
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
    await launchUrl(Uri.parse(checkoutUrl), mode: LaunchMode.externalApplication);
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      HomeContent(balance: balance, onPlay: () => setState(() => index = 1), onBonus: claimBonus),
      GamesPage(balance: balance, onBalance: changeBalance),
      BonusPage(balance: balance, claimed: bonusClaimed, onClaim: claimBonus),
      ProfilePage(balance: balance),
    ];
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
  final int balance;
  final VoidCallback onPlay;
  final VoidCallback onBonus;
  const HomeContent({super.key, required this.balance, required this.onPlay, required this.onBonus});
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
              Wallet(balance: balance),
            ]),
            const SizedBox(height: 55),
            const Text('SOCIAL CASINO • PLAY MONEY ONLY', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF24D9E7), fontWeight: FontWeight.w800, letterSpacing: 1.4)),
            const SizedBox(height: 18),
            const Text('הדור הבא של\nמשחקי הקזינו', textAlign: TextAlign.center, style: TextStyle(fontSize: 44, height: 1.12, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            const Text('ארבעה משחקים פעילים עם מטבעות וירטואליים בלבד. אין כסף אמיתי ואין אפשרות משיכה.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFB7BED0), fontSize: 17, height: 1.55)),
            const SizedBox(height: 28),
            FilledButton(onPressed: onPlay, style: FilledButton.styleFrom(backgroundColor: const Color(0xFF6C4CFF), padding: const EdgeInsets.all(18)), child: const Text('שחק עכשיו', style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold))),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onBonus, style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(17)), child: const Text('🎁 בונוס יומי', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
          ]),
        ),
      ),
    );
  }
}

class Wallet extends StatelessWidget {
  final int balance;
  const Wallet({super.key, required this.balance});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFF11182A), borderRadius: BorderRadius.circular(16)),
        child: Text('${balance.toString()} 🪙', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
      );
}

class GamesPage extends StatelessWidget {
  final int balance;
  final ValueChanged<int> onBalance;
  const GamesPage({super.key, required this.balance, required this.onBalance});

  void open(BuildContext context, Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('משחקים', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
            Wallet(balance: balance),
          ]),
          const SizedBox(height: 18),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                GameCard(icon: '🎰', title: 'Neon Slots', subtitle: '100 🪙 לסיבוב', onTap: () => open(context, SlotsGame(balance: balance, onBalance: onBalance))),
                GameCard(icon: '🎯', title: 'Roulette', subtitle: 'אדום / שחור', onTap: () => open(context, RouletteGame(balance: balance, onBalance: onBalance))),
                GameCard(icon: '🎲', title: 'Lucky Dice', subtitle: 'גבוה / נמוך', onTap: () => open(context, DiceGame(balance: balance, onBalance: onBalance))),
                GameCard(icon: '🃏', title: 'Blackjack 21', subtitle: 'פגע ב־21', onTap: () => open(context, BlackjackGame(balance: balance, onBalance: onBalance))),
              ],
            ),
          ),
          const Text('Play Money בלבד • המטבעות הווירטואליים אינם ניתנים למשיכה או להמרה לכסף.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9CA8BD), fontSize: 12)),
        ]),
      ),
    );
  }
}

class GameCard extends StatelessWidget {
  final String icon, title, subtitle;
  final VoidCallback onTap;
  const GameCard({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
        color: const Color(0xFF11182A),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(icon, style: const TextStyle(fontSize: 48)),
              const SizedBox(height: 10),
              Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(subtitle, style: const TextStyle(color: Color(0xFF9CA8BD))),
            ]),
          ),
        ),
      );
}

abstract class BaseGameState<T extends StatefulWidget> extends State<T> {
  final rng = Random();
  int localBalance = 0;
  bool initialized = false;
  void initBalance(int b) {
    if (!initialized) {
      localBalance = b;
      initialized = true;
    }
  }
  bool spend(int amount, ValueChanged<int> cb) {
    if (localBalance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('אין מספיק מטבעות וירטואליים')));
      return false;
    }
    setState(() => localBalance -= amount);
    cb(-amount);
    return true;
  }
  void win(int amount, ValueChanged<int> cb) {
    setState(() => localBalance += amount);
    cb(amount);
  }
}

class SlotsGame extends StatefulWidget {
  final int balance;
  final ValueChanged<int> onBalance;
  const SlotsGame({super.key, required this.balance, required this.onBalance});
  @override State<SlotsGame> createState() => _SlotsGameState();
}
class _SlotsGameState extends BaseGameState<SlotsGame> {
  final symbols = ['🍒', '🍋', '💎', '7️⃣', '⭐'];
  List<String> reels = ['7️⃣', '7️⃣', '7️⃣'];
  String message = '100 מטבעות לסיבוב';
  void spin() {
    if (!spend(100, widget.onBalance)) return;
    final r = List.generate(3, (_) => symbols[rng.nextInt(symbols.length)]);
    int prize = 0;
    if (r[0] == r[1] && r[1] == r[2]) prize = 1200;
    else if (r[0] == r[1] || r[1] == r[2] || r[0] == r[2]) prize = 250;
    if (prize > 0) win(prize, widget.onBalance);
    setState(() { reels = r; message = prize > 0 ? 'זכית $prize 🪙' : 'נסה שוב'; });
  }
  @override Widget build(BuildContext context) {
    initBalance(widget.balance);
    return GameScaffold(title: '🎰 Neon Slots', balance: localBalance, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: reels.map((s) => Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF11182A), borderRadius: BorderRadius.circular(16)), child: Text(s, style: const TextStyle(fontSize: 48)))).toList()),
      const SizedBox(height: 20), Text(message, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 20), FilledButton(onPressed: spin, child: const Text('סובב • 100 🪙')),
    ]));
  }
}

class RouletteGame extends StatefulWidget {
  final int balance; final ValueChanged<int> onBalance;
  const RouletteGame({super.key, required this.balance, required this.onBalance});
  @override State<RouletteGame> createState() => _RouletteGameState();
}
class _RouletteGameState extends BaseGameState<RouletteGame> {
  String result = 'בחר אדום או שחור';
  void bet(bool red) {
    if (!spend(100, widget.onBalance)) return;
    final landedRed = rng.nextBool();
    final won = landedRed == red;
    if (won) win(200, widget.onBalance);
    setState(() => result = '${landedRed ? '🔴 אדום' : '⚫ שחור'} — ${won ? 'זכית 200 🪙' : 'הפסדת'}');
  }
  @override Widget build(BuildContext context) {
    initBalance(widget.balance);
    return GameScaffold(title: '🎯 Neon Roulette', balance: localBalance, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🎯', style: TextStyle(fontSize: 90)), const SizedBox(height: 18), Text(result, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [FilledButton(onPressed: () => bet(true), child: const Text('🔴 אדום • 100')), const SizedBox(width: 12), FilledButton(onPressed: () => bet(false), child: const Text('⚫ שחור • 100'))]),
    ]));
  }
}

class DiceGame extends StatefulWidget {
  final int balance; final ValueChanged<int> onBalance;
  const DiceGame({super.key, required this.balance, required this.onBalance});
  @override State<DiceGame> createState() => _DiceGameState();
}
class _DiceGameState extends BaseGameState<DiceGame> {
  int die = 1; String result = 'בחר נמוך 1–3 או גבוה 4–6';
  void roll(bool high) {
    if (!spend(100, widget.onBalance)) return;
    final d = rng.nextInt(6) + 1;
    final won = high ? d >= 4 : d <= 3;
    if (won) win(190, widget.onBalance);
    setState(() { die = d; result = won ? 'זכית 190 🪙' : 'נסה שוב'; });
  }
  @override Widget build(BuildContext context) {
    initBalance(widget.balance);
    return GameScaffold(title: '🎲 Lucky Dice', balance: localBalance, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('🎲 $die', style: const TextStyle(fontSize: 72)), const SizedBox(height: 16), Text(result, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 24),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [FilledButton(onPressed: () => roll(false), child: const Text('1–3 • 100')), const SizedBox(width: 12), FilledButton(onPressed: () => roll(true), child: const Text('4–6 • 100'))]),
    ]));
  }
}

class BlackjackGame extends StatefulWidget {
  final int balance; final ValueChanged<int> onBalance;
  const BlackjackGame({super.key, required this.balance, required this.onBalance});
  @override State<BlackjackGame> createState() => _BlackjackGameState();
}
class _BlackjackGameState extends BaseGameState<BlackjackGame> {
  int player = 0, dealer = 0; bool playing = false; String msg = 'עלות משחק: 200 🪙';
  int card() => rng.nextInt(10) + 2;
  void start() {
    if (!spend(200, widget.onBalance)) return;
    setState(() { player = card() + card(); dealer = card(); playing = true; msg = 'פגע או עצור'; });
    if (player == 21) stand();
  }
  void hit() {
    if (!playing) return;
    setState(() => player += card());
    if (player > 21) setState(() { playing = false; msg = 'עברת 21 — הפסדת'; });
  }
  void stand() {
    if (!playing) return;
    var d = dealer;
    while (d < 17) d += card();
    final won = d > 21 || player > d;
    final tie = player == d;
    if (won) win(400, widget.onBalance); else if (tie) win(200, widget.onBalance);
    setState(() { dealer = d; playing = false; msg = won ? 'ניצחת! +400 🪙' : tie ? 'תיקו — ההימור הוחזר' : 'הדילר ניצח'; });
  }
  @override Widget build(BuildContext context) {
    initBalance(widget.balance);
    return GameScaffold(title: '🃏 Blackjack 21', balance: localBalance, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Text('דילר: $dealer', style: const TextStyle(fontSize: 28)), const SizedBox(height: 14), Text('אתה: $player', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)), const SizedBox(height: 16), Text(msg, style: const TextStyle(fontSize: 19)), const SizedBox(height: 24),
      if (!playing) FilledButton(onPressed: start, child: const Text('משחק חדש • 200 🪙')),
      if (playing) Row(mainAxisAlignment: MainAxisAlignment.center, children: [FilledButton(onPressed: hit, child: const Text('פגע')), const SizedBox(width: 12), OutlinedButton(onPressed: stand, child: const Text('עצור'))]),
    ]));
  }
}

class GameScaffold extends StatelessWidget {
  final String title; final int balance; final Widget child;
  const GameScaffold({super.key, required this.title, required this.balance, required this.child});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF050817),
    appBar: AppBar(backgroundColor: const Color(0xFF0B1020), title: Text(title), actions: [Padding(padding: const EdgeInsets.all(12), child: Center(child: Text('$balance 🪙', style: const TextStyle(fontWeight: FontWeight.bold))))]),
    body: Directionality(textDirection: TextDirection.rtl, child: Padding(padding: const EdgeInsets.all(22), child: Center(child: child))),
  );
}

class BonusPage extends StatelessWidget {
  final int balance; final bool claimed; final VoidCallback onClaim;
  const BonusPage({super.key, required this.balance, required this.claimed, required this.onClaim});
  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Center(child: Padding(padding: const EdgeInsets.all(26), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('🎁', style: TextStyle(fontSize: 72)), const SizedBox(height: 12), const Text('בונוס יומי', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)), const SizedBox(height: 10), Text('יתרה: $balance 🪙'), const SizedBox(height: 20), FilledButton(onPressed: claimed ? null : onClaim, child: Text(claimed ? 'כבר נאסף' : 'קבל 2,500 🪙'))]))));
}

class ProfilePage extends StatelessWidget {
  final int balance;
  const ProfilePage({super.key, required this.balance});
  @override Widget build(BuildContext context) => Directionality(textDirection: TextDirection.rtl, child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [const CircleAvatar(radius: 42, child: Icon(Icons.person, size: 46)), const SizedBox(height: 16), const Text('NEON PLAYER', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('יתרה וירטואלית: $balance 🪙'), const SizedBox(height: 8), const Text('Play Money בלבד', style: TextStyle(color: Color(0xFF9CA8BD)))])));
}
