import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../repositories/chat_repository.dart';

class ChatDetailScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatDetailScreen({Key? key, required this.conversation}) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final IChatRepository _repository = ChatRepository();
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  ConversationModel? _conversation;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadConversation();
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final conversation = await _repository.getConversationById(widget.conversation.id);
      if (!mounted) return;
      setState(() {
        _conversation = conversation ?? widget.conversation;
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _send() async {
    final user = context.read<AuthSessionProvider>().user;
    final conversation = _conversation ?? widget.conversation;
    final text = _msgController.text.trim();
    if (user == null || text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await _repository.sendMessage(
        conversationId: conversation.id,
        sender: user,
        text: text,
      );
      _msgController.clear();
      final refreshed = await _repository.getConversationById(conversation.id);
      if (!mounted) return;
      setState(() {
        _conversation = refreshed ?? conversation;
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation ?? widget.conversation;
    final user = context.watch<AuthSessionProvider>().user;
    final isCustomer = user?.role == UserRole.customer;
    final otherName = isCustomer ? conversation.technicianName : conversation.customerName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(otherName.isEmpty ? 'المحادثة' : otherName)),
      body: Column(
        children: [
          if (_error != null)
            MaterialBanner(
              content: Text(_error!),
              actions: [TextButton(onPressed: _loadConversation, child: const Text('إعادة المحاولة'))],
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : conversation.messages.isEmpty
                    ? const Center(child: Text('لا توجد رسائل بعد'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: conversation.messages.length,
                        itemBuilder: (context, index) {
                          final msg = conversation.messages[index];
                          final isMe = msg.senderId == user?.id;
                          return Align(
                            alignment: isMe ? Alignment.centerLeft : Alignment.centerRight,
                            child: Card(
                              color: isMe ? AppColors.primary : Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(msg.text, style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary)),
                                    if (msg.attachmentUrl?.isNotEmpty == true) ...[
                                      const SizedBox(height: 6),
                                      Text(msg.attachmentUrl!, style: TextStyle(fontSize: 10, color: isMe ? Colors.white70 : AppColors.textMuted)),
                                    ],
                                    const SizedBox(height: 4),
                                    Text(msg.createdAt, style: TextStyle(fontSize: 9, color: isMe ? Colors.white70 : AppColors.textMuted)),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      enabled: !_sending,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(hintText: 'اكتب رسالتك...', border: InputBorder.none),
                    ),
                  ),
                  IconButton(onPressed: _sending ? null : _send, icon: const Icon(Icons.send_rounded, color: AppColors.primary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
