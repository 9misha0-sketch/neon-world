import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../neon_theme.dart';
import '../services/profile_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.firstRun = false});
  final bool firstRun;
  @override State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final name = TextEditingController();
  final bio = TextEditingController();
  final service = ProfileService();
  String country = 'Worldwide';
  String language = 'English';
  String gender = 'Prefer not to say';
  String? avatarUrl;
  DateTime? birthDate;
  bool loading = true;
  bool saving = false;
  bool uploading = false;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final d = await service.loadMine();
      if (d != null) {
        name.text = d['display_name']?.toString() ?? '';
        bio.text = d['bio']?.toString() ?? '';
        country = d['country']?.toString() ?? country;
        language = d['language']?.toString() ?? language;
        gender = d['gender_label']?.toString() ?? gender;
        avatarUrl = d['avatar_url']?.toString();
        birthDate = DateTime.tryParse(d['birth_date']?.toString() ?? '');
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  bool get isAdult {
    final d = birthDate;
    if (d == null) return false;
    final n = DateTime.now();
    var age = n.year - d.year;
    if (n.month < d.month || (n.month == d.month && n.day < d.day)) age--;
    return age >= 18;
  }

  Future<void> pickAvatar() async {
    final file = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 82, maxWidth: 1200);
    if (file == null) return;
    setState(() => uploading = true);
    try {
      final bytes = await file.readAsBytes();
      final ext = file.name.contains('.') ? file.name.split('.').last : 'jpg';
      final url = await service.uploadAvatar(bytes, ext);
      if (mounted) setState(() => avatarUrl = url);
    } catch (e) {
      _msg('Could not upload photo: $e');
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  Future<void> save() async {
    if (name.text.trim().length < 2) { _msg('Choose a display name.'); return; }
    if (!isAdult) { _msg('NEON WORLD is for users aged 18 and over.'); return; }
    setState(() => saving = true);
    try {
      await service.saveMine(
        displayName: name.text,
        country: country,
        language: language,
        birthDate: birthDate!,
        gender: gender,
        bio: bio.text,
        avatarUrl: avatarUrl,
      );
      if (!mounted) return;
      if (widget.firstRun) Navigator.pop(context, true); else _msg('Profile saved.');
    } catch (e) {
      _msg(e.toString());
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _msg(String text) {
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your profile'), automaticallyImplyLeading: !widget.firstRun),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: NeonTheme.purple,
                      backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty ? NetworkImage(avatarUrl!) : null,
                      child: avatarUrl == null || avatarUrl!.isEmpty ? const Icon(Icons.person, size: 54) : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        backgroundColor: NeonTheme.blue,
                        child: IconButton(
                          onPressed: uploading ? null : pickAvatar,
                          icon: uploading
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.photo_camera, color: Colors.black),
                        ),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: 22),
                TextField(controller: name, maxLength: 30, decoration: const InputDecoration(labelText: 'Display name')),
                TextField(controller: bio, maxLength: 160, maxLines: 3, decoration: const InputDecoration(labelText: 'Short bio', hintText: 'Music, travel, sports…')),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(value: gender, decoration: const InputDecoration(labelText: 'Gender'), items: ['Man','Woman','Non-binary','Prefer not to say'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => gender = v ?? gender)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: country, decoration: const InputDecoration(labelText: 'Region'), items: ['Worldwide','Israel','Europe','North America','South America','Asia','Africa','Oceania'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => country = v ?? country)),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: language, decoration: const InputDecoration(labelText: 'Main language'), items: ['English','Hebrew','Arabic','Spanish','French','German','Russian','Portuguese'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => setState(() => language = v ?? language)),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).colorScheme.outline), borderRadius: BorderRadius.circular(14)),
                  title: const Text('Date of birth'),
                  subtitle: Text(birthDate == null ? 'Required — 18+ only' : '${birthDate!.day}/${birthDate!.month}/${birthDate!.year}'),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final picked = await showDatePicker(context: context, initialDate: birthDate ?? DateTime(DateTime.now().year - 20), firstDate: DateTime(1900), lastDate: DateTime.now());
                    if (picked != null) setState(() => birthDate = picked);
                  },
                ),
                const SizedBox(height: 20),
                FilledButton(onPressed: saving ? null : save, child: Padding(padding: const EdgeInsets.symmetric(vertical: 14), child: Text(saving ? 'Saving…' : 'Save profile'))),
              ],
            ),
    );
  }
}
