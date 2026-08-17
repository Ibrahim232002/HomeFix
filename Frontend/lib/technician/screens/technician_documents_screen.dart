import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_button.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/api_dtos.dart';
import '../../repositories/technician_repository.dart';
import '../../services/app_state_provider.dart';

class TechnicianDocumentsScreen extends StatefulWidget {
  const TechnicianDocumentsScreen({super.key});

  @override
  State<TechnicianDocumentsScreen> createState() => _TechnicianDocumentsScreenState();
}

class _TechnicianDocumentsScreenState extends State<TechnicianDocumentsScreen> {
  final ITechnicianRepository _repo = TechnicianRepository();
  List<TechnicianDocumentDto> _documents = const [];
  bool _loading = true;
  bool _submitting = false;
  String? _error;

  int? get _techId => int.tryParse(
        context.read<AppStateProvider>().currentTechProfile?.id ??
            context.read<AppStateProvider>().currentUser?.id ??
            '',
      );

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = _techId;
    if (id == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _repo.getDocuments(id);
      if (!mounted) return;
      setState(() {
        _documents = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  HomeFixStatusTone _statusTone(String? status) {
    switch ((status ?? '').toLowerCase()) {
      case 'approved':
        return HomeFixStatusTone.success;
      case 'rejected':
        return HomeFixStatusTone.error;
      case 'pending':
        return HomeFixStatusTone.warning;
      default:
        return HomeFixStatusTone.neutral;
    }
  }

  Future<void> _addDocument() async {
    final id = _techId;
    if (id == null || _submitting) return;

    final type = TextEditingController();
    final url = TextEditingController();
    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('إضافة مستند'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: type,
              decoration: const InputDecoration(labelText: 'نوع المستند'),
            ),
            const SizedBox(height: AppDesignTokens.space3),
            TextField(
              controller: url,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: 'رابط المستند'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              [type.text.trim(), url.text.trim()],
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
    type.dispose();
    url.dispose();

    if (result == null || result.length < 2 || result[0].isEmpty || result[1].isEmpty) {
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await _repo.uploadDocument(
        CreateTechnicianDocumentRequest(
          technicianId: id,
          documentType: result[0],
          documentUrl: result[1],
        ),
      );
      await _load();
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الوثائق')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: AppResponsive.pagePadding(context),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            AppResponsive.content(
              context,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_submitting) const LinearProgressIndicator(),
                  if (_loading)
                    const HomeFixLoadingList(itemCount: 3)
                  else if (_error != null)
                    HomeFixErrorState(
                      title: 'تعذر تحميل الوثائق',
                      message: _error,
                      onRetry: _load,
                    )
                  else if (_documents.isEmpty)
                    const HomeFixEmptyState(
                      icon: Icons.badge_outlined,
                      title: 'لا توجد وثائق',
                      message: 'يمكنك إضافة مستند عن طريق رابط ملف متاح فعلياً. رفع الملفات الثنائية غير مدعوم من عقد API الحالي.',
                    )
                  else
                    Column(
                      children: _documents
                          .map(
                            (doc) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppDesignTokens.space3,
                              ),
                              child: HomeFixCard(
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.description_outlined),
                                  title: Text(doc.documentType ?? 'مستند'),
                                  subtitle: Text(
                                    doc.rejectionReason?.isNotEmpty == true
                                        ? doc.rejectionReason!
                                        : 'تم الرفع: ${doc.uploadedAt}',
                                  ),
                                  trailing: HomeFixStatusChip(
                                    label: doc.status ?? 'Pending',
                                    tone: _statusTone(doc.status),
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  const SizedBox(height: AppDesignTokens.space4),
                  HomeFixButton(
                    expanded: true,
                    loading: _submitting,
                    label: 'إضافة مستند برابط',
                    icon: Icons.link_rounded,
                    onPressed: _addDocument,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
