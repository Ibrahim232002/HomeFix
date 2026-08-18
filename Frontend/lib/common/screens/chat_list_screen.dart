import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../models/user_model.dart';
import '../../services/app_state_provider.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  bool _loading = true;
  String? _error;
  String? _openingConversationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    if (!mounted || _loading) return;
    setState(() { _loading = true; _error = null; });
    try {
      await context.read<AppStateProvider>().refreshAuthenticatedData();
      if (mounted) setState(() => _loading = false);
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _openConversation(ConversationModel conversation) async {
    if (!mounted || _openingConversationId != null) return;
    setState(() => _openingConversationId = conversation.id);
    try {
      await Navigator.push(context, MaterialPageRoute(builder: (_) => ChatDetailScreen(conversation: conversation)));
    } finally {
      if (!mounted) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() => _openingConversationId = null);
        _load();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final conversations = appState.conversations;
    final isCustomer = appState.currentUser?.role == UserRole.customer;
    final unreadCount = conversations.fold<int>(0, (sum, item) => sum + (isCustomer ? item.unreadCountCustomer : item.unreadCountTechnician));

    return Scaffold(
      appBar: AppBar(
        title: const Text('المحادثات'),
        actions: [
          if (unreadCount > 0)
            Padding(padding: const EdgeInsetsDirectional.only(end: 16), child: Center(child: Text('$unreadCount غير مقروء', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)))),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: AppResponsive.pagePadding(context),
            children: [
              AppResponsive.content(
                context,
                child: _loading
                    ? const HomeFixLoadingList(itemCount: 4)
                    : _error != null
                        ? HomeFixErrorState(title: 'تعذر تحميل المحادثات', message: _error, onRetry: _load)
                        : conversations.isEmpty
                            ? const SizedBox(height: 420, child: HomeFixEmptyState(icon: Icons.chat_bubble_outline_rounded, title: 'لا توجد محادثات', message: 'ستظهر هنا محادثاتك مع الفنيين بعد بدء التواصل من الطلبات المدعومة.'))
                            : Column(
                                children: conversations.map((conversation) {
                                  final otherName = isCustomer ? conversation.technicianName : conversation.customerName;
                                  final otherAvatar = isCustomer ? conversation.technicianAvatar : conversation.customerAvatar;
                                  final unread = isCustomer ? conversation.unreadCountCustomer : conversation.unreadCountTechnician;
                                  final opening = _openingConversationId == conversation.id;
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: HomeFixCard(
                                      onTap: opening ? null : () => _openConversation(conversation),
                                      child: Row(children: [
                                        CircleAvatar(
                                          radius: 26,
                                          backgroundColor: AppColors.primarySurface,
                                          backgroundImage: otherAvatar?.isNotEmpty == true ? NetworkImage(otherAvatar!) : null,
                                          child: otherAvatar?.isNotEmpty == true ? null : const Icon(Icons.person_outline_rounded, color: AppColors.primary),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Row(children: [Expanded(child: Text(otherName.isEmpty ? 'المحادثة' : otherName, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: unread > 0 ? FontWeight.w800 : FontWeight.w700))), Text(conversation.lastMessageTime, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.textMuted))]),
                                          if (conversation.serviceNameAr?.isNotEmpty == true) Padding(padding: const EdgeInsets.only(top: 3), child: Text(conversation.serviceNameAr!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700))),
                                          const SizedBox(height: 4),
                                          Text(conversation.lastMessage.isEmpty ? 'لا توجد رسالة بعد' : conversation.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
                                        ])),
                                        if (opening)
                                          const Padding(padding: EdgeInsetsDirectional.only(start: 10), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                                        else if (unread > 0)
                                          Container(
                                            margin: const EdgeInsetsDirectional.only(start: 10),
                                            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
                                            alignment: Alignment.center,
                                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                            child: Text('$unread', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
                                          ),
                                      ]),
                                    ),
                                  );
                                }).toList(),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
