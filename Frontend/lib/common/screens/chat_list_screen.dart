import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../services/app_state_provider.dart';
import 'chat_detail_screen.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final conversations = appState.conversations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المحادثات والرسائل'),
      ),
      body: conversations.isEmpty
          ? const EmptyStateWidget(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'لا توجد محادثات جارية حالياً',
              description: 'يمكنك بدء محادثة مباشرة مع الفنيين المختصين عبر صفحات الطلبات والخدمات.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: conversations.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final conv = conversations[index];
                final isCustomer = appState.isCustomer;
                final otherName = isCustomer ? conv.technicianName : conv.customerName;
                final otherAvatar = isCustomer ? conv.technicianAvatar : conv.customerAvatar;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatDetailScreen(conversation: conv),
                        ),
                      );
                    },
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: (otherAvatar != null && otherAvatar.isNotEmpty) ? NetworkImage(otherAvatar) : null,
                    ),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          otherName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          conv.lastMessageTime,
                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (conv.serviceNameAr != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            conv.serviceNameAr!,
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, fontFamily: 'Cairo'),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          conv.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
