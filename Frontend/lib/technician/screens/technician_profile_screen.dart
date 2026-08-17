import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/auth_session_provider.dart';
import '../../common/screens/notifications_screen.dart';
import '../../common/screens/support_center_screen.dart';
import '../../core/constants/app_colors.dart';
import '../../core/network/api_exception.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/api_dtos.dart';
import '../../repositories/technician_repository.dart';

class TechnicianProfileScreen extends StatefulWidget {
  const TechnicianProfileScreen({Key? key}) : super(key: key);

  @override
  State<TechnicianProfileScreen> createState() => _TechnicianProfileScreenState();
}

class _TechnicianProfileScreenState extends State<TechnicianProfileScreen> {
  final ITechnicianRepository _repository = TechnicianRepository();
  TechnicianProfileDto? _profile;
  List<TechnicianServiceAreaDto> _areas = const [];
  List<TechnicianDocumentDto> _documents = const [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  int? get _userId => int.tryParse(context.read<AuthSessionProvider>().user?.id ?? '');

  @override
  void initState() {
    super.initState();
    _load();
  }

  String _safeError(Object error) => error is ApiException ? error.message : 'تعذر تحميل أو تحديث الملف المهني. يرجى المحاولة مرة أخرى.';

  Future<void> _load() async {
    final userId = _userId;
    if (userId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final profile = await _repository.getApiTechnicianProfileByUserId(userId);
      final areas = await _repository.getServiceAreas(profile.id);
      final documents = await _repository.getDocuments(profile.id);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _areas = areas;
        _documents = documents;
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

  Future<void> _editProfile() async {
    if (_profile == null || _saving) return;
    final bioController = TextEditingController(text: _profile!.bio ?? '');
    final yearsController = TextEditingController(text: (_profile!.yearsOfExperience ?? 0).toString());
    final imageController = TextEditingController(text: _profile!.profileImageUrl ?? '');

    final values = await showDialog<List<String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تعديل الملف المهني'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: bioController, maxLines: 4, decoration: const InputDecoration(labelText: 'النبذة المهنية')),
              const SizedBox(height: 10),
              TextField(controller: yearsController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'سنوات الخبرة')),
              const SizedBox(height: 10),
              TextField(controller: imageController, keyboardType: TextInputType.url, decoration: const InputDecoration(labelText: 'رابط صورة الملف المهني')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, [bioController.text.trim(), yearsController.text.trim(), imageController.text.trim()]), child: const Text('حفظ')),
        ],
      ),
    );
    bioController.dispose();
    yearsController.dispose();
    imageController.dispose();
    if (values == null) return;

    setState(() => _saving = true);
    try {
      final updated = await _repository.updateApiTechnicianProfile(
        _profile!.id,
        UpdateTechnicianProfileRequest(
          bio: values[0],
          yearsOfExperience: int.tryParse(values[1]),
          profileImageUrl: values[2].isEmpty ? null : values[2],
          isAvailable: _profile!.isAvailable,
        ),
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _safeError(e);
      });
    }
  }

  Future<void> _toggleAvailability() async {
    if (_profile == null || _saving) return;
    setState(() => _saving = true);
    try {
      final updated = await _repository.updateApiTechnicianProfile(
        _profile!.id,
        UpdateTechnicianProfileRequest(isAvailable: !_profile!.isAvailable),
      );
      if (!mounted) return;
      setState(() {
        _profile = updated;
        _saving = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = _safeError(e);
      });
    }
  }

  Future<void> _addArea() async {
    if (_profile == null) return;
    final controller = TextEditingController();
    final cityId = await showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة منطقة خدمة'),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'معرف المدينة')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(onPressed: () => Navigator.pop(context, int.tryParse(controller.text.trim())), child: const Text('إضافة')),
        ],
      ),
    );
    controller.dispose();
    if (cityId == null || cityId <= 0) return;
    try {
      await _repository.addServiceArea(CreateTechnicianServiceAreaRequest(technicianId: _profile!.id, cityId: cityId));
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = _safeError(e));
    }
  }

  Future<void> _deleteArea(TechnicianServiceAreaDto area) async {
    try {
      await _repository.deleteServiceArea(area.technicianId, area.cityId);
      await _load();
    } catch (e) {
      if (mounted) setState(() => _error = _safeError(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AuthSessionProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الملف المهني للفني')),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_error != null)
              Card(
                color: AppColors.errorLight,
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: AppColors.errorDark),
                  title: Text(_error!),
                  trailing: TextButton(onPressed: _load, child: const Text('إعادة المحاولة')),
                ),
              ),
            if (_loading)
              const SizedBox(height: 260, child: Center(child: CircularProgressIndicator()))
            else if (_profile == null)
              const SizedBox(height: 260, child: EmptyStateWidget(icon: Icons.engineering_outlined, title: 'تعذر تحميل الملف المهني', description: 'تحقق من الاتصال ثم حاول مرة أخرى.'))
            else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 42,
                        backgroundImage: _profile!.profileImageUrl?.isNotEmpty == true ? NetworkImage(_profile!.profileImageUrl!) : null,
                        child: _profile!.profileImageUrl?.isNotEmpty == true ? null : const Icon(Icons.engineering, size: 42),
                      ),
                      const SizedBox(height: 10),
                      Text(session.user?.fullName ?? 'الفني', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(session.user?.email ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      Text('التقييم ${_profile!.averageRating.toStringAsFixed(1)} • ${_profile!.totalJobs} عمل مكتمل', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text('سنوات الخبرة: ${_profile!.yearsOfExperience ?? 0}', style: const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 10),
                      if ((_profile!.bio ?? '').isNotEmpty) Text(_profile!.bio!, textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: OutlinedButton.icon(onPressed: _saving ? null : _editProfile, icon: const Icon(Icons.edit), label: const Text('تعديل'))),
                          const SizedBox(width: 10),
                          Expanded(child: ElevatedButton.icon(onPressed: _saving ? null : _toggleAvailability, icon: Icon(_profile!.isAvailable ? Icons.pause_circle : Icons.play_circle), label: Text(_profile!.isAvailable ? 'غير متاح' : 'متاح'))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(title: const Text('حالة التحقق'), subtitle: Text(_profile!.isVerified ? 'تم اعتماد الملف' : 'لم يتم اعتماد الملف بعد'), leading: Icon(_profile!.isVerified ? Icons.verified : Icons.pending_outlined)),
                    const Divider(height: 1),
                    ListTile(title: const Text('مناطق الخدمة'), subtitle: Text('${_areas.length} منطقة مسجلة'), trailing: IconButton(onPressed: _addArea, icon: const Icon(Icons.add))),
                    if (_areas.isEmpty)
                      const Padding(padding: EdgeInsets.all(16), child: Text('لا توجد مناطق خدمة مسجلة حالياً.'))
                    else
                      ..._areas.map((area) => ListTile(title: Text('مدينة #${area.cityId}'), trailing: IconButton(onPressed: () => _deleteArea(area), icon: const Icon(Icons.delete_outline))))
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ListTile(title: Text('الوثائق والمستندات'), subtitle: Text('حالة الوثائق القادمة من الخادم')),
                    if (_documents.isEmpty)
                      const Padding(padding: EdgeInsets.all(16), child: Text('لا توجد وثائق مسجلة. رفع الملفات غير مدعوم فعلياً لأن الـAPI الحالي يقبل رابط ملف فقط ولا يوفر endpoint لرفع binary data.'))
                    else
                      ..._documents.map((document) => ListTile(
                            title: Text(document.documentType ?? 'وثيقة'),
                            subtitle: Text(document.status ?? 'Pending'),
                            trailing: document.documentUrl?.isNotEmpty == true ? const Icon(Icons.link) : null,
                          )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.support_agent),
                  title: const Text('الدعم'),
                  subtitle: const Text('فتح مركز الدعم الفني'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportCenterScreen())),
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('الإشعارات'),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
