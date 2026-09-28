import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/project.dart';

class AddProjectScreen extends StatefulWidget {
  const AddProjectScreen({super.key});

  @override
  State<AddProjectScreen> createState() => _AddProjectScreenState();
}

class _AddProjectScreenState extends State<AddProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _techCtrl = TextEditingController();
  final _authorCtrl = TextEditingController(text: 'Pulkit');
  final _githubCtrl = TextEditingController();

  ProjectCategory _category = ProjectCategory.mobileApp;
  DevelopmentStatus _status = DevelopmentStatus.inProgress;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _techCtrl.dispose();
    _authorCtrl.dispose();
    _githubCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await Future.delayed(const Duration(milliseconds: 300)); // micro UX delay
    final project = Project(
      id: 'PRJ-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      techStack: _techCtrl.text.trim(),
      author: _authorCtrl.text.trim(),
      githubUrl: _githubCtrl.text.trim(),
      category: _category,
      status: _status,
      timestamp: DateTime.now(),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ "${project.title}" added to your showcase!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    Navigator.pop(context, project);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Project'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    cs.primaryContainer,
                    cs.secondaryContainer,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.rocket_launch_rounded,
                      color: cs.onPrimaryContainer, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Log a project you\'ve built or are working on',
                      style: GoogleFonts.inter(
                        color: cs.onPrimaryContainer,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel('Basic Info'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Project Title *',
                prefixIcon: Icon(Icons.title_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter a project title' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _authorCtrl,
              decoration: const InputDecoration(
                labelText: 'Your Name *',
                prefixIcon: Icon(Icons.person_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter your name' : null,
            ),
            const SizedBox(height: 24),
            _SectionLabel('Classification'),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProjectCategory>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category *',
                prefixIcon: Icon(Icons.category_rounded),
              ),
              items: ProjectCategory.values
                  .map((c) => DropdownMenuItem(
                      value: c, child: Text(c.displayName)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _category = v);
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<DevelopmentStatus>(
              value: _status,
              decoration: const InputDecoration(
                labelText: 'Status *',
                prefixIcon: Icon(Icons.flag_rounded),
              ),
              items: DevelopmentStatus.values
                  .map((s) => DropdownMenuItem(
                      value: s, child: Text(s.displayName)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _status = v);
              },
            ),
            const SizedBox(height: 24),
            _SectionLabel('Tech & Details'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _techCtrl,
              decoration: const InputDecoration(
                labelText: 'Tech Stack *',
                hintText: 'e.g. Flutter, Python, React…',
                prefixIcon: Icon(Icons.code_rounded),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Enter the tech stack' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _githubCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                labelText: 'GitHub URL (optional)',
                hintText: 'https://github.com/…',
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 5,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description & Architecture *',
                hintText: 'What does this project do? What\'s the architecture?',
                alignLabelWithHint: true,
              ),
              validator: (v) => v == null || v.trim().isEmpty
                  ? 'Enter a description'
                  : v.trim().length < 20
                      ? 'Please add more detail (at least 20 chars)'
                      : null,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _submit,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.publish_rounded),
                label: Text(_saving ? 'Saving…' : 'Publish Project'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Theme.of(context).colorScheme.primary,
        letterSpacing: 0.8,
      ),
    );
  }
}
