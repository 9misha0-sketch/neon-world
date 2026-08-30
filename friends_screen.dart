import 'package:flutter/material.dart';
import '../neon_theme.dart';
import '../services/social_service.dart';
import 'messages_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});
  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final service = SocialService();
  bool loading = true;
  List<Map<String, dynamic>> friends = [];
  List<Map<String, dynamic>> requests = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final a = await service.friends();
      final b = await service.requests();
      if (mounted) setState(() { friends = a; requests = b; loading = false; });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 110),
                children: [
                  const Text('Friends', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                  if (requests.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    const Text('Requests', style: TextStyle(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    ...requests.map((r) {
                      final p = (r['profiles'] as Map?) ?? const {};
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: NeonPanel(
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            _avatar(p['avatar_url']),
                            const SizedBox(width: 10),
                            Expanded(child: Text(p['display_name'] ?? 'User')),
                            IconButton(
                              onPressed: () async { await service.respondRequest(r['id'].toString(), true); await load(); },
                              icon: const Icon(Icons.check, color: NeonTheme.success),
                            ),
                            IconButton(
                              onPressed: () async { await service.respondRequest(r['id'].toString(), false); await load(); },
                              icon: const Icon(Icons.close),
                            ),
                          ]),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 18),
                  if (friends.isEmpty)
                    Text('People you add during a live chat will appear here.', style: TextStyle(color: Colors.white.withValues(alpha: .55)))
                  else
                    ...friends.map((p) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: _avatar(p['avatar_url']),
                          title: Row(children: [
                            Flexible(child: Text(p['display_name'] ?? 'User')),
                            if (p['is_vip'] == true)
                              const Padding(
                                padding: EdgeInsets.only(left: 6),
                                child: Icon(Icons.workspace_premium, color: Color(0xFFFFD76A), size: 17),
                              ),
                          ]),
                          subtitle: Text('★ ${p['rating'] ?? 5}'),
                          trailing: const Icon(Icons.chat_bubble_outline),
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MessagesScreen(friend: p))),
                        )),
                ],
              ),
            ),
    );
  }

  Widget _avatar(dynamic url) => CircleAvatar(
        radius: 24,
        backgroundColor: NeonTheme.purple,
        backgroundImage: url != null && url.toString().isNotEmpty ? NetworkImage(url.toString()) : null,
        child: url == null || url.toString().isEmpty ? const Icon(Icons.person) : null,
      );
}
