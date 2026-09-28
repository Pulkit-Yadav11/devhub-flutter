import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  final int projectCount;
  const ProfileScreen({super.key, required this.projectCount});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, String> _profile = {};
  bool _editing = false;
  bool _loading = true;

  final _nameCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _githubCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = await StorageService.loadProfile();
    if (!mounted) return;
    setState(() {
      _profile = p;
      _nameCtrl.text = p['name'] ?? '';
      _bioCtrl.text = p['bio'] ?? '';
      _emailCtrl.text = p['email'] ?? '';
      _githubCtrl.text = p['github'] ?? '';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    final updated = {
      'name': _nameCtrl.text.trim(),
      'bio': _bioCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'github': _githubCtrl.text.trim(),
    };
    await StorageService.saveProfile(updated);
    if (!mounted) return;
    setState(() {
      _profile = updated;
      _editing = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile saved!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _emailCtrl.dispose();
    _githubCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = DevHubApp.of(context).isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (!_loading)
            IconButton(
              icon: Icon(_editing ? Icons.close_rounded : Icons.edit_rounded),
              tooltip: _editing ? 'Cancel' : 'Edit Profile',
              onPressed: () => setState(() => _editing = !_editing),
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Avatar & name header
                Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundColor: cs.primaryContainer,
                            child: Text(
                              (_profile['name'] ?? '?').isNotEmpty
                                  ? (_profile['name']!)[0].toUpperCase()
                                  : '?',
                              style: GoogleFonts.inter(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: cs.onPrimaryContainer,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: cs.surface, width: 2),
                            ),
                            child: Icon(Icons.person_rounded,
                                size: 14, color: cs.onPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _profile['name'] ?? '',
                        style: GoogleFonts.inter(
                            fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _profile['bio'] ?? '',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats
                Row(
                  children: [
                    Expanded(
                      child: _ProfileStat(
                        label: 'Projects',
                        value: '${widget.projectCount}',
                        icon: Icons.folder_rounded,
                        color: cs.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileStat(
                        label: 'GitHub',
                        value: 'Connected',
                        icon: Icons.code_rounded,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Edit form or read-only info
                if (_editing) ...[
                  _SectionLabel('Edit Profile'),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Your Name',
                      prefixIcon: Icon(Icons.person_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bioCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      prefixIcon: Icon(Icons.info_outline_rounded),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _githubCtrl,
                    decoration: const InputDecoration(
                      labelText: 'GitHub username / URL',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saveProfile,
                      icon: const Icon(Icons.save_rounded),
                      label: const Text('Save Changes'),
                    ),
                  ),
                ] else ...[
                  _InfoRow(
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: _profile['email'] ?? '—'),
                  const SizedBox(height: 10),
                  _InfoRow(
                      icon: Icons.link_rounded,
                      label: 'GitHub',
                      value: _profile['github'] ?? '—'),
                ],
                const SizedBox(height: 32),

                // Settings
                _SectionLabel('Settings'),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: Text('Dark Mode',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500)),
                        subtitle: Text(
                            isDark ? 'Currently dark' : 'Currently light',
                            style: GoogleFonts.inter(fontSize: 12)),
                        secondary: Icon(
                            isDark
                                ? Icons.dark_mode_rounded
                                : Icons.light_mode_rounded,
                            color: cs.primary),
                        value: isDark,
                        onChanged: (_) => DevHubApp.of(context).toggleTheme(),
                      ),
                      const Divider(height: 1, indent: 16, endIndent: 16),
                      ListTile(
                        leading: Icon(Icons.info_outline_rounded,
                            color: cs.primary),
                        title: Text('App Version',
                            style: GoogleFonts.inter(
                                fontWeight: FontWeight.w500)),
                        trailing: Text('2.0.0',
                            style: GoogleFonts.inter(
                                color: cs.onSurfaceVariant,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Card(
                  child: ListTile(
                    leading:
                        Icon(Icons.school_rounded, color: cs.secondary),
                    title: Text('Built for',
                        style:
                            GoogleFonts.inter(fontWeight: FontWeight.w500)),
                    subtitle: Text(
                        'Cross-Platform Mobile Dev — Semester VI',
                        style: GoogleFonts.inter(fontSize: 12)),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 0.8));
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _ProfileStat(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        leading: Icon(icon, color: cs.primary, size: 20),
        title: Text(label,
            style: GoogleFonts.inter(
                fontSize: 12, color: cs.onSurfaceVariant)),
        subtitle: Text(value,
            style: GoogleFonts.inter(
                fontSize: 14, fontWeight: FontWeight.w500)),
      ),
    );
  }
}
