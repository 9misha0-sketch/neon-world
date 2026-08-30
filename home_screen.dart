import 'package:flutter/material.dart';
import 'video_chat_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String country = 'Worldwide';
  String language = 'Any language';
  bool adultsOnly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('World Live Chat')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.public, size: 96),
              const SizedBox(height: 16),
              const Text(
                'Meet people around the world',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Random 1-to-1 live video chat. You can skip, report or block at any time.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              DropdownButtonFormField<String>(
                value: country,
                decoration: const InputDecoration(labelText: 'Region', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Worldwide', child: Text('Worldwide')),
                  DropdownMenuItem(value: 'Israel', child: Text('Israel')),
                  DropdownMenuItem(value: 'Europe', child: Text('Europe')),
                  DropdownMenuItem(value: 'North America', child: Text('North America')),
                  DropdownMenuItem(value: 'Asia', child: Text('Asia')),
                ],
                onChanged: (v) => setState(() => country = v ?? country),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: language,
                decoration: const InputDecoration(labelText: 'Language', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'Any language', child: Text('Any language')),
                  DropdownMenuItem(value: 'English', child: Text('English')),
                  DropdownMenuItem(value: 'Hebrew', child: Text('Hebrew')),
                  DropdownMenuItem(value: 'Arabic', child: Text('Arabic')),
                  DropdownMenuItem(value: 'Spanish', child: Text('Spanish')),
                ],
                onChanged: (v) => setState(() => language = v ?? language),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: adultsOnly,
                title: const Text('I confirm I am 18+'),
                subtitle: const Text('Required for this MVP'),
                onChanged: (v) => setState(() => adultsOnly = v ?? false),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: adultsOnly
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => VideoChatScreen(region: country, language: language),
                          ),
                        );
                      }
                    : null,
                icon: const Icon(Icons.videocam),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Find someone'),
                ),
              ),
              const Spacer(),
              const Text(
                'Safety: never share passwords, payment details or private identifying information.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
