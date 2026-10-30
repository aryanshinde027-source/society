import 'package:flutter/material.dart';
import 'package:society_management/services/ai.service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final AiService _service = AiService();

  final TextEditingController _messageController = TextEditingController();

  final TextEditingController _residentController = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];

  static const Color bg = Color(0xFFF4F5FB);
  static const Color navy = Color(0xFF172B50);
  static const Color purple = Color(0xFF4936C8);
  static const Color muted = Color(0xFF8992A4);
  static const Color gold = Color(0xFFDDBB70);

  String? _conversationId;
  bool _loading = false;

  final List<String> suggestions = [
    'How do I report a water leak?',
    'How can I check society notices?',
    'How can I book a society facility?',
    'How do I check maintenance payments?',
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _residentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final residentId = int.tryParse(_residentController.text.trim());

    if (residentId == null || residentId <= 0) {
      _showMessage('Enter a valid numeric Resident ID');
      return;
    }

    if (text.isEmpty || _loading) return;

    setState(() {
      _messages.add({'role': 'user', 'message': text});
      _messageController.clear();
      _loading = true;
    });

    _scrollToBottom();

    try {
      final response = await _service.sendMessage(
        residentId: residentId,
        message: text,
        conversationId: _conversationId,
      );

      if (!mounted) return;

      setState(() {
        _conversationId =
            response['conversationId']?.toString() ?? _conversationId;

        _messages.add({
          'role': 'assistant',
          'message': response['message']?.toString() ?? 'No response received.',
        });
      });

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _messages.add({
          'role': 'assistant',
          'message': 'Could not connect to AI. Please try again.',
        });
      });

      _showMessage('Chat failed: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }

      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _loadHistory() async {
    final residentId = int.tryParse(_residentController.text.trim());

    if (residentId == null || residentId <= 0) {
      _showMessage('Enter Resident ID first');
      return;
    }

    if (_conversationId == null) {
      _showMessage('Send a message first to create a conversation');
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await _service.getChatHistory(
        conversationId: _conversationId!,
        residentId: residentId,
      );

      if (!mounted) return;

      final List<dynamic> history = result is List
          ? result
          : result is Map && result['messages'] is List
          ? result['messages'] as List
          : [];

      setState(() {
        _messages.clear();

        for (final item in history) {
          if (item is Map) {
            _messages.add({
              'role': item['role']?.toString() ?? 'assistant',
              'message': item['message']?.toString() ?? '',
            });
          }
        }
      });

      _scrollToBottom();

      if (history.isEmpty) {
        _showMessage('No history messages found');
      }
    } catch (e) {
      _showMessage('History failed: $e');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _newConversation() {
    setState(() {
      _conversationId = null;
      _messages.clear();
      _messageController.clear();
    });
  }

  // WELCOME BANNER
  Widget _welcomeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF202D78), Color(0xFF4936C8), Color(0xFF5844E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(29),
        boxShadow: [
          BoxShadow(
            color: purple.withOpacity(0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 5,
            child: Icon(
              Icons.auto_awesome,
              color: Colors.white.withOpacity(0.09),
              size: 115,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
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
                    SizedBox(width: 9),
                    Text(
                      'SMART SOCIETY AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                "I'm your AI Assistant",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Ask me about your society, services, '
                'notices and complaints.',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 23),

              const Row(
                children: [
                  Icon(Icons.bolt_rounded, color: gold, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Smart Answers  •  Society Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // RESIDENT ID FIELD
  Widget _residentField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E6EF)),
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEDFF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: purple,
              size: 29,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: TextField(
              controller: _residentController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: navy,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              decoration: const InputDecoration(
                hintText: 'Resident ID',
                hintStyle: TextStyle(color: muted, fontSize: 16),
                border: InputBorder.none,
              ),
            ),
          ),

          const Icon(Icons.verified_user_outlined, color: muted, size: 28),
        ],
      ),
    );
  }

  // SUGGESTION BUTTON
  Widget _suggestionButton(String text) {
    return InkWell(
      onTap: () {
        setState(() {
          _messageController.text = text;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE1E5F0)),
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
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: muted, size: 17),
          ],
        ),
      ),
    );
  }

  // EMPTY CHAT SCREEN
  Widget _emptyChat() {
    return Column(
      children: [
        const SizedBox(height: 24),

        Container(
          height: 112,
          width: 112,
          decoration: BoxDecoration(
            color: const Color(0xFFECEAFF),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.smart_toy_rounded, color: purple, size: 75),
        ),

        const SizedBox(height: 18),

        const Text(
          'Start a Conversation',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),

        const SizedBox(height: 9),

        const Text(
          'Your friendly society assistant is ready to help!',
          textAlign: TextAlign.center,
          style: TextStyle(color: muted, fontSize: 14, height: 1.5),
        ),

        const SizedBox(height: 30),

        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'TRY ASKING...',
            style: TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),

        const SizedBox(height: 15),

        ...suggestions.map(_suggestionButton),
      ],
    );
  }

  // CHAT MESSAGE BUBBLE
  Widget _messageBubble(Map<String, String> item) {
    final isUser = item['role'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.82,
        ),
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? purple : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(19),
            topRight: const Radius.circular(19),
            bottomLeft: Radius.circular(isUser ? 19 : 5),
            bottomRight: Radius.circular(isUser ? 5 : 19),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFFE5E7F0)),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(0.035),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isUser ? Icons.person_rounded : Icons.auto_awesome,
                  color: isUser ? Colors.white : purple,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  isUser ? 'You' : 'Society AI',
                  style: TextStyle(
                    color: isUser ? Colors.white70 : purple,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              item['message'] ?? '',
              style: TextStyle(
                color: isUser ? Colors.white : navy,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BOTTOM MESSAGE INPUT
  Widget _bottomInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 13, 15, 15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: const Color(0xFFE8EAF1))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(35),
                  border: Border.all(color: const Color(0xFFE5E7F0)),
                ),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  onSubmitted: (_) => _sendMessage(),
                  style: const TextStyle(color: navy, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(color: muted, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 21,
                      vertical: 17,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 11),

            SizedBox(
              height: 58,
              width: 58,
              child: ElevatedButton(
                onPressed: _loading ? null : _sendMessage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: purple,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(19),
                  ),
                ),
                child: _loading
                    ? const SizedBox(
                        height: 23,
                        width: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 27),
              ),
            ),
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
        surfaceTintColor: bg,
        elevation: 0,
        toolbarHeight: 72,
        foregroundColor: navy,
        title: const Text(
          'AI Assistant',
          style: TextStyle(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Chat History',
            onPressed: _loading ? null : _loadHistory,
            icon: const Icon(Icons.history_rounded, size: 28, color: navy),
          ),
          IconButton(
            tooltip: 'New Chat',
            onPressed: _newConversation,
            icon: const Icon(Icons.add_comment_outlined, size: 27, color: navy),
          ),
          const SizedBox(width: 7),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(17, 12, 17, 20),
              children: [
                _welcomeBanner(),

                const SizedBox(height: 24),

                _residentField(),

                if (_messages.isEmpty)
                  _emptyChat()
                else ...[
                  const SizedBox(height: 25),

                  const Text(
                    'Your Conversation',
                    style: TextStyle(
                      color: navy,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 20),

                  ..._messages.map(_messageBubble),

                  if (_loading)
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(color: purple),
                      ),
                    ),
                ],
              ],
            ),
          ),

          if (_loading)
            const LinearProgressIndicator(
              color: purple,
              backgroundColor: bg,
              minHeight: 2,
            ),

          _bottomInput(),
        ],
      ),
    );
  }
}
