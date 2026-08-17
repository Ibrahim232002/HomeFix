import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_field.dart';
import '../../core/widgets/homefix_states.dart';
import '../../models/chat_model.dart';
import '../../models/user_model.dart';
import '../../repositories/chat_repository.dart';

class ChatDetailScreen extends StatefulWidget {
  final ConversationModel conversation;

  const ChatDetailScreen({super.key, required this.conversation});

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
    setState(() { _loading = true; _error = null; });
    try {
      final conversation = await _repository.getConversationById(widget.conversation.id);
      if (!mounted) return;
      setState(() { _conversation = conversation ?? widget.conversation; _loading = false; });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e is ApiException ? e.message : 'تعذر تحميل المحادثة. تحقق من الاتصال ثم حاول مرة أخرى.'; });
    }
  }

  Future<void> _send() async {
    final user = context.read<AuthSessionProvider>().user;
    final conversation = _conversation ?? widget.conversation;
    final text = _msgController.text.trim();
    if (user == null || text.isEmpty || _sending) return;

    setState(() { _sending = true; _error = null; });
    try {
      await _repository.sendMessage(conversationId: conversation.id, sender: user, text: text);
      _msgController.clear();
      final refreshed = await _repository.getConversationById(conversation.id);
      if (!mounted) return;
      setState(() { _conversation = refreshed ?? conversation; _sending = false; });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() { _sending = false; _error = e is ApiException ? e.message : 'تعذر إرسال الرسالة. حاول مرة أخرى.'; });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 200), curve: Curves.easeOut);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final conversation = _conversation ?? widget.conversation;
    final user = context.watch<AuthSessionProvider>().user;
    final isCustomer = user?.role == UserRole.customer;
    final otherName = isCustomer ? conversation.technicianName : conversation.customerName;
    final otherAvatar = isCustomer ? conversation.technicianAvatar : conversation.customerAvatar;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: AppDesignTokens.space3,
        title: Row(children: [
          CircleAvatar(radius: 18, backgroundColor: AppColors.primarySurface, backgroundImage: otherAvatar?.isNotEmpty == true ? NetworkImage(otherAvatar!) : null, child: otherAvatar?.isNotEmpty == true ? null : const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.primary)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(otherName.isEmpty ? 'المحادثة' : otherName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)), if (conversation.serviceNameAr?.isNotEmpty == true) Text(conversation.serviceNameAr!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary))])),
        ]),
      ),
      body: SafeArea(
        child: Column(children: [
          if (_error != null) MaterialBanner(content: Text(_error!), actions: [TextButton(onPressed: _loadConversation, child: const Text('إعادة المحاولة'))]),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadConversation,
              child: _loading
                  ? ListView(padding: AppResponsive.pagePadding(context), children: const [HomeFixLoadingList(itemCount: 6)])
                  : conversation.messages.isEmpty
                      ? ListView(physics: const AlwaysScrollableScrollPhysics(), children: const [SizedBox(height: 280), HomeFixEmptyState(icon: Icons.chat_bubble_outline_rounded, title: 'لا توجد رسائل بعد', message: 'ابدأ المحادثة بإرسال أول رسالة.')])
                      : ListView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: AppResponsive.pagePadding(context),
                          itemCount: conversation.messages.length,
                          itemBuilder: (context, index) {
                            final msg = conversation.messages[index];
                            final isMe = msg.senderId == user?.id;
                            return Align(
                              alignment: isMe ? AlignmentDirectional.centerStart : AlignmentDirectional.centerEnd,
                              child: Container(
                                constraints: const BoxConstraints(maxWidth: 560),
                                margin: const EdgeInsets.only(bottom: 10),
                                child: HomeFixCard(
                                  backgroundColor: isMe ? AppColors.primary : AppColors.cardBackground,
                                  borderColor: isMe ? Colors.transparent : AppColors.border,
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(msg.text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: isMe ? Colors.white : AppColors.textPrimary)),
                                    if (msg.attachmentUrl?.isNotEmpty == true) ...[const SizedBox(height: 6), Text('مرفق: ${msg.attachmentUrl}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: isMe ? Colors.white70 : AppColors.textMuted))],
                                    const SizedBox(height: 5),
                                    Text(msg.createdAt, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: isMe ? Colors.white70 : AppColors.textMuted)),
                                  ]),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.border))),
              child: Row(children: [
                Expanded(child: HomeFixField(controller: _msgController, enabled: !_sending, hintText: 'اكتب رسالتك...', textInputAction: TextInputAction.send, onChanged: (_) {}, onTap: () {})),
                const SizedBox(width: 8),
                HomeFixButton(expanded: false, loading: _sending, label: 'إرسال', icon: Icons.send_rounded, onPressed: _sending ? null : _send),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
