import 'package:flutter/material.dart';
import '../services/social_service.dart';
import 'messages_screen.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});
  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final service = SocialService();
  bool loading = true;
  List<Map<String, dynamic>> friends = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final data = await service.friends();
      if (mounted) setState(() { friends = data; loading = false; });
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
                  const Text('Inbox', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  Text('Private chats are available only with friends.', style: TextStyle(color: Colors.white.withValues(alpha: .55))),
                  const SizedBox(height: 18),
                  if (friends.isEmpty)
                    const ListTile(
                      leading: Icon(Icons.mark_chat_unread_outlined),
                      title: Text('No conversations yet'),
                      subtitle: Text('Add someone during a live chat to start messaging.'),
                    )
                  else
                    ...friends.map((p) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundImage: (p['avatar_url'] ?? '').toString().isNotEmpty ? NetworkImage(p['avatar_url']) : null,
                            child: (p['avatar_url'] ?? '').toString().isEmpty ? const Icon(Icons.person) : null,
                          ),
                          title: Text(p['display_name'] ?? 'User'),
                          subtitle: const Text('Tap to open chat'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => MessagesScreen(friend: p)),
                          ),
                        )),
                ],
              ),
            ),
    );
  }
}
