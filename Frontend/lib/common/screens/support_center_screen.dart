import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../core/constants/app_colors.dart';
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

  List<SupportTicketDto> _tickets = const [];
  SupportTicketDto? _selectedTicket;
  List<SupportMessageDto> _messages = const [];
  bool _loading = true;
  bool _loadingMessages = false;
  bool _creating = false;
  bool _sending = false;
  String? _error;
  final _messageController = TextEditingController();

  int? get _userId {
    final id = context.read<AuthSessionProvider>().user?.id;
    return id == null ? null : int.tryParse(id);
  }

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

  Future<void> _loadTickets() async {
    final userId = _userId;
    if (userId == null) return;
    if (_loading) setState(() => _error = null);
    try {
      final tickets = await _repository.getTicketsByUser(userId);
      if (!mounted) return;
      setState(() {
        _tickets = tickets;
        _loading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _message(e);
      });
    }
  }

  Future<void> _selectTicket(SupportTicketDto ticket) async {
    setState(() {
      _selectedTicket = ticket;
      _loadingMessages = true;
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
        _error = _message(e);
      });
    }
  }

  Future<void> _createTicket() async {
    final userId = _userId;
    if (userId == null || _creating) return;
    if (_subjectController.text.trim().isEmpty || _descriptionController.text.trim().isEmpty) return;

    setState(() {
      _creating = true;
      _error = null;
    });
    try {
      final ticket = await _repository.createTicket(CreateSupportTicketRequest(
        userId: userId,
        subject: _subjectController.text.trim(),
        description: _descriptionController.text.trim(),
        priority: 'Medium',
      ));
      _subjectController.clear();
      _descriptionController.clear();
      if (!mounted) return;
      setState(() {
        _creating = false;
        _tickets = [ticket, ..._tickets];
        _selectedTicket = ticket;
        _messages = const [];
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _creating = false;
        _error = _message(e);
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
      _error = null;
    });
    try {
      final message = await _repository.createMessage(CreateSupportMessageRequest(
        supportTicketId: ticket.id,
        senderId: userId,
        message: text,
      ));
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
        _error = _message(e);
      });
    }
  }

  String _message(Object error) => error.toString().replaceFirst('Exception: ', '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('مركز المساعدة والدعم')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 800;
          if (wide) {
            return Row(
              children: [
                SizedBox(width: 320, child: _ticketList()),
                const VerticalDivider(width: 1),
                Expanded(child: _ticketDetails()),
              ],
            );
          }
          return _selectedTicket == null ? _ticketList() : _ticketDetails();
        },
      ),
    );
  }

  Widget _ticketList() {
    return RefreshIndicator(
      onRefresh: _loadTickets,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _newTicketCard(),
          const SizedBox(height: 16),
          if (_error != null) _errorCard(),
          if (_loading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_tickets.isEmpty)
            const _EmptySupportState()
          else
            ..._tickets.map((ticket) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(ticket.subject ?? 'طلب دعم'),
                    subtitle: Text('${ticket.status ?? 'Open'} • ${ticket.priority ?? 'Medium'}'),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => _selectTicket(ticket),
                  ),
                )),
        ],
      ),
    );
  }

  Widget _ticketDetails() {
    final ticket = _selectedTicket;
    if (ticket == null) {
      return const Center(child: Text('اختر تذكرة دعم لعرض التفاصيل'));
    }

    return Column(
      children: [
        ListTile(
          leading: IconButton(
            onPressed: () => setState(() => _selectedTicket = null),
            icon: const Icon(Icons.arrow_forward),
          ),
          title: Text(ticket.subject ?? 'طلب دعم', style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${ticket.status ?? 'Open'} • ${ticket.priority ?? 'Medium'}'),
        ),
        const Divider(height: 1),
        Expanded(
          child: _loadingMessages
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(ticket.description ?? ''),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_messages.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('لا توجد رسائل بعد. يمكنك إرسال أول رسالة للدعم.'),
                      ),
                    ..._messages.map((message) => Align(
                          alignment: message.senderId == _userId ? Alignment.centerLeft : Alignment.centerRight,
                          child: Card(
                            color: message.senderId == _userId ? AppColors.primarySurface : Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Text(message.message ?? ''),
                            ),
                          ),
                        )),
                  ],
                ),
        ),
        if (_error != null) Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _errorCard()),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _messageController, enabled: !_sending, decoration: const InputDecoration(hintText: 'اكتب رسالتك...'))),
                const SizedBox(width: 8),
                IconButton(onPressed: _sending ? null : _sendMessage, icon: const Icon(Icons.send_rounded)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _newTicketCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('فتح تذكرة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(controller: _subjectController, enabled: !_creating, decoration: const InputDecoration(labelText: 'الموضوع')),
            const SizedBox(height: 8),
            TextField(controller: _descriptionController, enabled: !_creating, maxLines: 3, decoration: const InputDecoration(labelText: 'وصف المشكلة')),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _creating ? null : _createTicket, child: _creating ? const CircularProgressIndicator() : const Text('إرسال التذكرة')),
          ],
        ),
      ),
    );
  }

  Widget _errorCard() => Card(
        color: AppColors.errorLight,
        child: ListTile(
          leading: const Icon(Icons.error_outline, color: AppColors.errorDark),
          title: Text(_error ?? 'حدث خطأ'),
          trailing: TextButton(onPressed: _loadTickets, child: const Text('إعادة المحاولة')),
        ),
      );
}

class _EmptySupportState extends StatelessWidget {
  const _EmptySupportState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.support_agent_rounded, size: 48, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('لا توجد تذاكر دعم حالياً'),
          SizedBox(height: 4),
          Text('أنشئ تذكرة جديدة وسيتابع فريق الدعم طلبك.'),
        ],
      ),
    );
  }
}
