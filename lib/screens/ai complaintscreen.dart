import 'package:flutter/material.dart';
import 'package:society_management/services/ai.service.dart';

class AiComplaintScreen extends StatefulWidget {
  const AiComplaintScreen({super.key});

  @override
  State<AiComplaintScreen> createState() => _AiComplaintScreenState();
}

class _AiComplaintScreenState extends State<AiComplaintScreen> {
  final AiService _service = AiService();
  final TextEditingController _descriptionController = TextEditingController();

  bool _loading = false;
  Map<String, dynamic>? _result;
  String? _error;

  static const Color bg = Color(0xFF0B1120);
  static const Color surface = Color(0xFF151F32);
  static const Color pink = Color(0xFFF472B6);
  static const Color muted = Color(0xFF94A3B8);

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _generateSuggestion() async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe your complaint')),
      );
      return;
    }

    if (description.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Description must be 2000 characters or less'),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });

    try {
      final response = await _service.suggestComplaint(
        description: description,
      );

      if (!mounted) return;
      setState(() => _result = response);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _resultField(String title, dynamic value, IconData icon) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: pink, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: pink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(color: Colors.white, height: 1.5),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Text('AI Complaint Help'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF831843),
                    Color(0xFF9D174D),
                    Color(0xFF4C1D95),
                  ],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.psychology_rounded, color: Colors.white, size: 42),
                  SizedBox(height: 15),
                  Text(
                    'Complaint Assistant',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Describe your issue and get an AI-generated '
                    'complaint suggestion.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'Describe your complaint',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 7,
              maxLength: 2000,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Example: Water leakage in the common area...',
                hintStyle: const TextStyle(color: muted),
                filled: true,
                fillColor: surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _generateSuggestion,
                icon: const Icon(Icons.auto_awesome),
                label: Text(
                  _loading ? 'Generating suggestion...' : 'Generate Suggestion',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: pink,
                  foregroundColor: bg,
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            if (_loading) ...[
              const SizedBox(height: 20),
              const Center(child: CircularProgressIndicator(color: pink)),
            ],
            if (_error != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF451A1A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Request failed: $_error',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
            if (_result != null) ...[
              const SizedBox(height: 28),
              const Text(
                'AI Suggestion',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              _resultField('Suggested Title', _result!['title'], Icons.title),
              _resultField(
                'Description',
                _result!['description'],
                Icons.description_outlined,
              ),
              _resultField(
                'Category',
                _result!['category'],
                Icons.category_outlined,
              ),
              _resultField(
                'Priority',
                _result!['priority'],
                Icons.flag_outlined,
              ),
              _resultField(
                'Next Steps',
                _result!['nextSteps'],
                Icons.checklist_rounded,
              ),
              const SizedBox(height: 8),
              const Text(
                'Review the suggestion before using it in an official complaint.',
                style: TextStyle(color: muted, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
