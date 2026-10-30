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

  static const Color bg = Color(0xFFF4F5FB);
  static const Color navy = Color(0xFF172B50);
  static const Color purple = Color(0xFF4936C8);
  static const Color lightPurple = Color(0xFF7160E8);
  static const Color muted = Color(0xFF8992A4);
  static const Color gold = Color(0xFFDDBB70);

  final List<String> suggestions = [
    'Water leakage in common area',
    'Lift is not working properly',
    'Street lights are not working',
    'Garbage collection problem',
  ];

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
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _resultField(String title, dynamic value, IconData icon) {
    if (value == null || value.toString().trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7FC),
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: const Color(0xFFE5E5F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: purple, size: 21),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: purple,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value.toString(),
            style: const TextStyle(color: navy, fontSize: 14, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _suggestionButton(String text) {
    return InkWell(
      borderRadius: BorderRadius.circular(17),
      onTap: () {
        setState(() {
          _descriptionController.text = text;
          _result = null;
          _error = null;
        });
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 19),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE1E4F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.auto_awesome, color: purple, size: 22),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  color: navy,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: muted, size: 17),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: bg,
        foregroundColor: navy,
        toolbarHeight: 75,
        title: const Text(
          'AI Complaint Help',
          style: TextStyle(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _descriptionController.clear();
                _result = null;
                _error = null;
              });
            },
            icon: const Icon(Icons.add_box_outlined, size: 27, color: navy),
            tooltip: 'New Complaint',
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI WELCOME BANNER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(23),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF202D78),
                      Color(0xFF4936C8),
                      Color(0xFF5844E5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: purple.withOpacity(0.16),
                      blurRadius: 20,
                      offset: const Offset(0, 9),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HELLO THERE!',
                            style: TextStyle(
                              color: Color(0xFFD8D6FF),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 22),

                          const Text(
                            "I'm your AI Assistant",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              height: 1.2,
                            ),
                          ),

                          const SizedBox(height: 15),

                          const Text(
                            'Describe your society issue and get smart complaint suggestions.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.13),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, color: gold, size: 17),
                                SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    'Smart Society Support',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    const Expanded(
                      flex: 4,
                      child: Icon(
                        Icons.smart_toy_rounded,
                        color: Color(0xFFB9D4FF),
                        size: 105,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // DESCRIPTION HEADING
              const Text(
                'Describe Your Complaint',
                style: TextStyle(
                  color: navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Tell us what happened. AI will help you prepare a complaint.',
                style: TextStyle(color: muted, fontSize: 14, height: 1.5),
              ),

              const SizedBox(height: 18),

              // INPUT FIELD
              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE3E6F0)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFEDFF),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.edit_note_rounded,
                            color: purple,
                            size: 29,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Complaint Details',
                            style: TextStyle(
                              color: navy,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.verified_user_outlined,
                          color: muted,
                          size: 25,
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: _descriptionController,
                      maxLines: 6,
                      maxLength: 2000,
                      style: const TextStyle(
                        color: navy,
                        fontSize: 15,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText:
                            'Example: Water leakage in the common area...',
                        hintStyle: const TextStyle(color: muted, fontSize: 14),
                        filled: true,
                        fillColor: const Color(0xFFF5F6FB),
                        contentPadding: const EdgeInsets.all(17),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0xFFE8EAF3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: purple,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // GENERATE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 57,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _generateSuggestion,
                        icon: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.auto_awesome, size: 21),
                        label: Text(
                          _loading
                              ? 'Generating Suggestion...'
                              : 'Generate AI Suggestion',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: purple,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: purple.withOpacity(0.6),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // QUICK SUGGESTIONS
              const Text(
                'TRY ASKING...',
                style: TextStyle(
                  color: navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 15),

              ...suggestions.map(_suggestionButton),

              // ERROR
              if (_error != null) ...[
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEEEE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    'Request failed: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],

              // AI RESULT
              if (_result != null) ...[
                const SizedBox(height: 22),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(19),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF202D78), Color(0xFF4936C8)],
                    ),
                    borderRadius: BorderRadius.circular(23),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: gold, size: 26),
                      SizedBox(width: 12),
                      Text(
                        'AI Suggestion',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 17),

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

              const SizedBox(height: 25),
            ],
          ),
        ),
      ),
    );
  }
}
