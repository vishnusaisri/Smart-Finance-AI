import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/chat_service.dart';

class ChatInput extends StatefulWidget {
  final ChatService chatService;
  final Function(String) onSend;

  const ChatInput({
    super.key,
    required this.chatService,
    required this.onSend,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x0DFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x1AFFFFFF)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Ask about your finances...',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[400],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(
                    color: Colors.grey[600]!,
                  ),
                ),
                filled: true,
                fillColor: Colors.grey[900],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Voice input button
                    IconButton(
                      icon: Icon(
                        Icons.mic,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: _startVoiceInput,
                      tooltip: 'Voice input',
                    ),
                    // Attach file button
                    IconButton(
                      icon: Icon(
                        Icons.attach_file,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      onPressed: _showAttachmentOptions,
                      tooltip: 'Attach file',
                    ),
                  ],
                ),
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
              maxLines: 3,
              minLines: 1,
              onChanged: (text) {
                if (text.isNotEmpty && !_isTyping) {
                  setState(() {
                    _isTyping = true;
                  });
                } else if (text.isEmpty && _isTyping) {
                  setState(() {
                    _isTyping = false;
                  });
                }
              },
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          
          // Send button
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isTyping ? [Colors.grey[600]!, Colors.grey[700]!] : [Colors.blue, Colors.purple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                _isTyping ? Icons.stop : Icons.send,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _isTyping ? _stopTyping : _sendMessage,
              tooltip: _isTyping ? 'Stop typing' : 'Send message',
            ),
          ),
        ],
      ),
    ).animate(target: 1, duration: const Duration(milliseconds: 500));
  }

  void _sendMessage() {
    final message = _textController.text.trim();
    if (message.isEmpty) return;

    widget.onSend(message);
    _textController.clear();
    setState(() {
      _isTyping = false;
    });
    _focusNode.requestFocus();
  }

  void _startVoiceInput() {
    // Placeholder for voice input functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Voice input coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _stopTyping() {
    setState(() {
      _isTyping = false;
    });
    _textController.clear();
    _focusNode.requestFocus();
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            Text(
              'Add Attachment',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildAttachmentOption(
              context,
              Icons.receipt_long,
              'Receipt',
              () => Navigator.pop(context),
            ),
            _buildAttachmentOption(
              context,
              Icons.description,
              'Document',
              () => Navigator.pop(context),
            ),
            _buildAttachmentOption(
              context,
              attach_money,
              'Budget Report',
              () => Navigator.pop(context),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildAttachmentOption(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      color: const Color(0x0A1E293B),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[400]),
        title: Text(title),
        onTap: onTap,
      ),
    );
  }
}