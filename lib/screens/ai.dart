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
  final ScrollController _scrollController = ScrollController();

  final List<Map<String, String>> _messages = [];

  final Color bg = const Color(0xFF0B1120);
  final Color surface = const Color(0xFF151F32);
  final Color blue = const Color(0xFF60A5FA);
  final Color muted = const Color(0xFF94A3B8);

  final TextEditingController _residentController = TextEditingController();

  String? _conversationId;
  bool _loading = false;

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
      if (mounted) setState(() => _loading = false);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  void _newConversation() {
    setState(() {
      _conversationId = null;
      _messages.clear();
      _messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFC084FC)),
            SizedBox(width: 10),
            Text('AI Assistant'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Load history',
            onPressed: _loading ? null : _loadHistory,
            icon: const Icon(Icons.history),
          ),
          IconButton(
            tooltip: 'New chat',
            onPressed: _newConversation,
            icon: const Icon(Icons.add_comment_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            color: surface,
            child: TextField(
              controller: _residentController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Resident ID',
                labelStyle: TextStyle(color: muted),
                prefixIcon: const Icon(
                  Icons.person_outline,
                  color: Colors.blue,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: muted.withValues(alpha: 0.3)),
                ),
              ),
            ),
          ),
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(25),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.smart_toy_outlined,
                            color: Color(0xFFC084FC),
                            size: 70,
                          ),
                          const SizedBox(height: 18),
                          const Text(
                            'How can I help you?',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask questions about society services, '
                            'facilities, notices or complaints.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: muted),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final item = _messages[index];
                      final isUser = item['role'] == 'user';

                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.82,
                          ),
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? blue : surface,
                            borderRadius: BorderRadius.circular(17),
                          ),
                          child: Text(
                            item['message'] ?? '',
                            style: TextStyle(
                              color: isUser ? bg : Colors.white,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_loading)
            const LinearProgressIndicator(
              color: Color(0xFFC084FC),
              backgroundColor: Color(0xFF151F32),
            ),
          Container(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
            decoration: BoxDecoration(
              color: surface,
              border: Border(
                top: BorderSide(color: muted.withValues(alpha: 0.15)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    minLines: 1,
                    maxLines: 4,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Ask something...',
                      hintStyle: TextStyle(color: muted),
                      filled: true,
                      fillColor: bg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton.filled(
                  onPressed: _loading ? null : _sendMessage,
                  style: IconButton.styleFrom(
                    backgroundColor: blue,
                    foregroundColor: bg,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
