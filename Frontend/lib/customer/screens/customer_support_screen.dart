import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/api_dtos.dart';
import '../../repositories/support_repository.dart';
import '../../services/app_state_provider.dart';

class CustomerSupportScreen extends StatefulWidget {
  const CustomerSupportScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSupportScreen> createState() => _CustomerSupportScreenState();
}

class _CustomerSupportScreenState extends State<CustomerSupportScreen> {
  final ISupportRepository _supportRepository = SupportRepository();
  List<SupportTicketDto> _tickets = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final userId = int.tryParse(Provider.of<AppStateProvider>(context, listen: false).currentUser?.id ?? '');
    if (userId == null || userId <= 0) {
      if (mounted) setState(() { _loading = false; _error = 'تعذر تحديد حساب العميل.'; });
      return;
    }
    try {
      final tickets = await _supportRepository.getTicketsByUser(userId);
      if (!mounted) return;
      setState(() { _tickets = tickets; _loading = false; _error = null; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString().replaceFirst('Exception: ', ''); });
    }
  }

  Future<void> _createTicket() async {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();
    try {
      final created = await showDialog<SupportTicketDto>(
        context: context,
        builder: (dialogContext) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('فتح طلب دعم', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: subjectController, decoration: const InputDecoration(labelText: 'موضوع الطلب')),
                const SizedBox(height: 10),
                TextField(controller: descriptionController, maxLines: 4, decoration: const InputDecoration(labelText: 'اشرح المشكلة أو طلبك')),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
              ElevatedButton(
                onPressed: () async {
                  final userId = int.tryParse(Provider.of<AppStateProvider>(context, listen: false).currentUser?.id ?? '');
                  if (userId == null || userId <= 0 || subjectController.text.trim().isEmpty || descriptionController.text.trim().isEmpty) return;
                  try {
                    final ticket = await _supportRepository.createTicket(CreateSupportTicketRequest(
                      userId: userId,
                      subject: subjectController.text.trim(),
                      description: descriptionController.text.trim(),
                      priority: 'Medium',
                    ));
                    if (dialogContext.mounted) Navigator.pop(dialogContext, ticket);
                  } catch (e) {
                    if (dialogContext.mounted) ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
                  }
                },
                child: const Text('إرسال الطلب', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      );

      if (!mounted || created == null) return;
      setState(() => _tickets = [created, ..._tickets]);
      if (!mounted) return;
      await Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerSupportTicketScreen(ticket: created)));
      await _loadTickets();
    } finally {
      subjectController.dispose();
      descriptionController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('مركز المساعدة وخدمة العملاء')),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo'))))
                : RefreshIndicator(
                    onRefresh: _loadTickets,
                    child: _tickets.isEmpty
                        ? ListView(padding: const EdgeInsets.all(24), children: const [SizedBox(height: 120), Icon(Icons.support_agent_rounded, size: 60, color: AppColors.primary), SizedBox(height: 16), Center(child: Text('لا توجد طلبات دعم حالياً', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold))), SizedBox(height: 8), Center(child: Text('يمكنك فتح طلب جديد وسيتابع فريق الدعم معك.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)))])
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _tickets.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final ticket = _tickets[index];
                              return Card(
                                child: ListTile(
                                  leading: const CircleAvatar(child: Icon(Icons.support_agent_rounded)),
                                  title: Text(ticket.subject ?? 'طلب دعم', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
                                  subtitle: Text('${ticket.status ?? 'Open'} • ${ticket.description ?? ''}', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontFamily: 'Cairo')),
                                  trailing: const Icon(Icons.chevron_left_rounded),
                                  onTap: () async {
                                    await Navigator.push(context, MaterialPageRoute(builder: (_) => CustomerSupportTicketScreen(ticket: ticket)));
                                    await _loadTickets();
                                  },
                                ),
                              );
                            },
                          ),
                  ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: AppColors.primary,
          onPressed: _createTicket,
          icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
          label: const Text('طلب دعم جديد', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class CustomerSupportTicketScreen extends StatefulWidget {
  final SupportTicketDto ticket;

  const CustomerSupportTicketScreen({Key? key, required this.ticket}) : super(key: key);

  @override
  State<CustomerSupportTicketScreen> createState() => _CustomerSupportTicketScreenState();
}

class _CustomerSupportTicketScreenState extends State<CustomerSupportTicketScreen> {
  final ISupportRepository _supportRepository = SupportRepository();
  final _messageController = TextEditingController();
  List<SupportMessageDto> _messages = [];
  bool _loading = true;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await _supportRepository.getMessagesByTicket(widget.ticket.id);
      if (!mounted) return;
      setState(() { _messages = messages; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final userId = int.tryParse(Provider.of<AppStateProvider>(context, listen: false).currentUser?.id ?? '');
    if (text.isEmpty || userId == null || userId <= 0 || _sending) return;
    setState(() => _sending = true);
    try {
      final message = await _supportRepository.createMessage(CreateSupportMessageRequest(
        supportTicketId: widget.ticket.id,
        senderId: userId,
        message: text,
      ));
      if (!mounted) return;
      setState(() {
        _messages.add(message);
        _messageController.clear();
        _sending = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _sending = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(widget.ticket.subject ?? 'طلب الدعم')),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.ticket.subject ?? 'طلب دعم', style: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 6),
                Text(widget.ticket.description ?? '', style: const TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary, height: 1.4)),
                const SizedBox(height: 8),
                Text('الحالة: ${widget.ticket.status ?? 'Open'}', style: const TextStyle(fontFamily: 'Cairo', color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12)),
              ]),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _messages.isEmpty
                      ? const Center(child: Text('لم تتم إضافة رسائل بعد.', style: TextStyle(fontFamily: 'Cairo', color: AppColors.textSecondary)))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) {
                            final message = _messages[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                              child: Text(message.message ?? '', style: const TextStyle(fontFamily: 'Cairo', height: 1.4)),
                            );
                          },
                        ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  Expanded(child: TextField(controller: _messageController, minLines: 1, maxLines: 4, decoration: const InputDecoration(hintText: 'اكتب رسالتك لفريق الدعم', border: OutlineInputBorder()))),
                  const SizedBox(width: 8),
                  IconButton(onPressed: _sending ? null : _sendMessage, icon: const Icon(Icons.send_rounded, color: AppColors.primary)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
