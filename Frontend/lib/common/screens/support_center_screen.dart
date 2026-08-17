import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_field.dart';
import '../../core/widgets/homefix_states.dart';
import '../../models/api_dtos.dart';
import '../../repositories/support_repository.dart';

class SupportCenterScreen extends StatefulWidget {
  const SupportCenterScreen({super.key});

  @override
  State<SupportCenterScreen> createState() => _SupportCenterScreenState();
}

class _SupportCenterScreenState extends State<SupportCenterScreen> {
  final ISupportRepository _repository = SupportRepository();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _messageController = TextEditingController();

  List<SupportTicketDto> _tickets = const [];
  SupportTicketDto? _selectedTicket;
  List<SupportMessageDto> _messages = const [];
  bool _loading = true;
  bool _loadingMessages = false;
  bool _creating = false;
  bool _sending = false;
  String? _error;
  String? _messageError;

  int? get _userId =>
      int.tryParse(context.read<AuthSessionProvider>().user?.id ?? '');

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _safeError(Object error) {
    if (error is ApiException) return error.message;
    return 'تعذر الاتصال بخدمة الدعم. تحقق من الشبكة ثم حاول مرة أخرى.';
  }

  Future<void> _loadTickets() async {
    final userId = _userId;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'انتهت الجلسة. يرجى تسجيل الدخول مرة أخرى.';
        });
      }
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final tickets = await _repository.getTicketsByUser(userId);
      if (!mounted) return;
      setState(() {
        _tickets = tickets;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _safeError(e);
      });
    }
  }

  Future<void> _selectTicket(SupportTicketDto ticket) async {
    if (_loadingMessages) return;
    setState(() {
      _selectedTicket = ticket;
      _loadingMessages = true;
      _messageError = null;
      _messages = const [];
    });

    try {
      final messages = await _repository.getMessagesByTicket(ticket.id);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loadingMessages = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadingMessages = false;
        _messageError = _safeError(e);
      });
    }
  }

  Future<void> _createTicket() async {
    final userId = _userId;
    if (userId == null || _creating) return;

    final subject = _subjectController.text.trim();
    final description = _descriptionController.text.trim();
    if (subject.isEmpty || description.isEmpty) {
      setState(() => _error = 'أدخل موضوع المشكلة ووصفها أولاً.');
      return;
    }

    setState(() {
      _creating = true;
      _error = null;
    });

    try {
      final ticket = await _repository.createTicket(
        CreateSupportTicketRequest(
          userId: userId,
          subject: subject,
          description: description,
          priority: 'Medium',
        ),
      );
      _subjectController.clear();
      _descriptionController.clear();
      if (!mounted) return;
      setState(() {
        _creating = false;
        _tickets = [ticket, ..._tickets];
      });
      await _selectTicket(ticket);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = _safeError(e);
      });
    }
  }

  Future<void> _sendMessage() async {
    final ticket = _selectedTicket;
    final userId = _userId;
    final text = _messageController.text.trim();
    if (ticket == null || userId == null || text.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _messageError = null;
    });

    try {
      final message = await _repository.createMessage(
        CreateSupportMessageRequest(
          supportTicketId: ticket.id,
          senderId: userId,
          message: text,
        ),
      );
      _messageController.clear();
      if (!mounted) return;
      setState(() {
        _sending = false;
        _messages = [..._messages, message];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _messageError = _safeError(e);
      });
    }
  }

  Future<void> _retryMessages() async {
    final ticket = _selectedTicket;
    if (ticket != null) await _selectTicket(ticket);
  }

  Future<void> _showCreateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('تذكرة دعم جديدة'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                HomeFixField(controller: _subjectController, label: 'الموضوع'),
                const SizedBox(height: 10),
                HomeFixField(
                  controller: _descriptionController,
                  label: 'وصف المشكلة',
                  maxLines: 5,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _creating ? null : () => Navigator.pop(dialogContext),
              child: const Text('إلغاء'),
            ),
            HomeFixButton(
              expanded: false,
              loading: _creating,
              label: 'إرسال',
              icon: Icons.send_rounded,
              onPressed: _creating
                  ? null
                  : () async {
                      setDialogState(() {});
                      await _createTicket();
                      if (dialogContext.mounted && !_creating) {
                        Navigator.pop(dialogContext);
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _ticketList() {
    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppResponsive.pagePadding(context),
        children: [
          HomeFixCard(
            gradient: AppColors.primaryGradient,
            borderColor: Colors.transparent,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'هل تحتاج إلى مساعدة؟',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'افتح تذكرة وسيتابعها فريق الدعم من داخل النظام.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white70,
                      ),
                ),
                const SizedBox(height: 12),
                HomeFixButton(
                  variant: HomeFixButtonVariant.secondary,
                  icon: Icons.add_comment_outlined,
                  label: 'فتح تذكرة جديدة',
                  onPressed: _creating ? null : _showCreateDialog,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_error != null)
            HomeFixErrorState(
              title: 'تعذر تحميل التذاكر',
              message: _error,
              onRetry: _loadTickets,
            ),
          if (_loading)
            const HomeFixLoadingList(itemCount: 5)
          else if (_tickets.isEmpty)
            const HomeFixEmptyState(
              icon: Icons.support_agent_outlined,
              title: 'لا توجد تذاكر دعم',
              message: 'ستظهر هنا تذاكر الدعم التي تنشئها من التطبيق.',
            )
          else
            ..._tickets.map(
              (ticket) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: HomeFixCard(
                  onTap: () => _selectTicket(ticket),
                  child: Row(
                    children: [
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(
                            Icons.support_agent_rounded,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ticket.subject?.isNotEmpty == true
                                  ? ticket.subject!
                                  : 'طلب دعم',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${ticket.status ?? 'Open'} • ${ticket.priority ?? 'Medium'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_left_rounded),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _ticketDetails() {
    final ticket = _selectedTicket;
    if (ticket == null) {
      return const HomeFixEmptyState(
        icon: Icons.support_agent_outlined,
        title: 'اختر تذكرة',
        message: 'اختر إحدى التذاكر لعرض الرسائل والتفاصيل.',
      );
    }

    return Column(
      children: [
        Padding(
          padding: AppResponsive.pagePadding(context),
          child: Row(
            children: [
              IconButton(
                tooltip: 'رجوع',
                onPressed: () => setState(() => _selectedTicket = null),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject ?? 'طلب دعم',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      '${ticket.status ?? 'Open'} • ${ticket.priority ?? 'Medium'}',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _retryMessages,
            child: ListView(
              padding: AppResponsive.pagePadding(context),
              children: [
                HomeFixCard(child: Text(ticket.description ?? '')),
                const SizedBox(height: 14),
                if (_messageError != null)
                  HomeFixErrorState(
                    title: 'تعذر تحميل الرسائل',
                    message: _messageError,
                    onRetry: _retryMessages,
                  )
                else if (_loadingMessages)
                  const HomeFixLoadingList(itemCount: 4)
                else if (_messages.isEmpty)
                  const HomeFixEmptyState(
                    icon: Icons.forum_outlined,
                    title: 'لا توجد رسائل بعد',
                    message: 'أرسل رسالة لفريق الدعم للمتابعة.',
                  )
                else
                  ..._messages.map(
                    (message) => Align(
                      alignment: message.senderId == _userId
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: HomeFixCard(
                          backgroundColor: message.senderId == _userId
                              ? AppColors.primarySurface
                              : AppColors.cardBackground,
                          child: Text(message.message ?? ''),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: HomeFixField(
                    controller: _messageController,
                    enabled: !_sending,
                    hintText: 'اكتب رسالة للدعم...',
                    textInputAction: TextInputAction.send,
                    onChanged: (_) {},
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                HomeFixButton(
                  expanded: false,
                  loading: _sending,
                  icon: Icons.send_rounded,
                  label: 'إرسال',
                  onPressed: _sending ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 800;
    return Scaffold(
      appBar: AppBar(title: const Text('الدعم الفني')),
      body: SafeArea(
        child: AppResponsive.content(
          context,
          child: wide
              ? Row(
                  children: [
                    SizedBox(width: 360, child: _ticketList()),
                    const VerticalDivider(width: 1),
                    Expanded(child: _ticketDetails()),
                  ],
                )
              : (_selectedTicket == null ? _ticketList() : _ticketDetails()),
        ),
      ),
    );
  }
}
