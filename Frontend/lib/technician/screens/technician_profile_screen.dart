import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/rating_stars.dart';
import '../../models/technician_document_model.dart';
import '../../services/app_state_provider.dart';
import '../widgets/technician_service_area_card.dart';
import '../widgets/technician_current_location_card.dart';
import '../widgets/technician_specialization_card.dart';

class TechnicianProfileScreen extends StatelessWidget {
  const TechnicianProfileScreen({Key? key}) : super(key: key);

  void _showUploadDocDialog(BuildContext context) {
    final titleController = TextEditingController();
    final numController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('رفع وثيقة أو شهادة مهنية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'عنوان الوثيقة أو الترخيص')),
                const SizedBox(height: 10),
                TextField(controller: numController, decoration: const InputDecoration(labelText: 'رقم الشهادة / الترخيص')),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.technicianLight, borderRadius: BorderRadius.circular(10)),
                  child: Row(children: const [
                    Icon(Icons.file_upload_outlined, color: AppColors.technicianPrimary),
                    SizedBox(width: 8),
                    Expanded(child: Text('إرفاق الملف بصيغة PDF أو صورة', style: TextStyle(fontSize: 12, color: AppColors.technicianPrimary, fontWeight: FontWeight.bold, fontFamily: 'Cairo'))),
                  ]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo'))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.technicianPrimary),
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                Provider.of<AppStateProvider>(context, listen: false).uploadDocument(titleAr: titleController.text.trim(), titleEn: 'Professional Document', documentType: 'Certificate', documentNumber: numController.text.trim(), fileUrl: null);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم رفع الوثيقة بنجاح وجاري مراجعتها من قبل الإدارة.')));
              },
              child: const Text('إرسال للمراجعة', style: TextStyle(fontFamily: 'Cairo', color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final tech = appState.currentTechProfile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('الملف المهني للفني')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
            child: Column(children: [
              CircleAvatar(radius: 40, backgroundImage: (tech?.avatarUrl.isNotEmpty ?? false) ? NetworkImage(tech!.avatarUrl) : null),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(tech?.fullName ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                const SizedBox(width: 6),
                const Icon(Icons.verified_rounded, size: 18, color: AppColors.technicianPrimary),
              ]),
              const SizedBox(height: 4),
              Text(tech?.phoneNumber ?? '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontFamily: 'Cairo')),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                RatingStarsWidget(rating: tech?.rating ?? 0.0, reviewCount: tech?.reviewCount ?? 0),
                const SizedBox(width: 16),
                Text('${tech?.completedJobsCount ?? 0} عمل منجز', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary, fontFamily: 'Cairo')),
              ]),
            ]),
          ),
          const SizedBox(height: 16),
          const TechnicianSpecializationCard(),
          const SizedBox(height: 16),
          const TechnicianCurrentLocationCard(),
          const SizedBox(height: 16),
          const TechnicianServiceAreaCard(),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('الوثائق والشهادات المعتمدة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, fontFamily: 'Cairo')),
                TextButton.icon(icon: const Icon(Icons.add_rounded, size: 18, color: AppColors.technicianPrimary), label: const Text('إضافة وثيقة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, color: AppColors.technicianPrimary)), onPressed: () => _showUploadDocDialog(context)),
              ]),
              const SizedBox(height: 8),
              if (appState.technicianDocuments.isEmpty)
                Container(width: double.infinity, padding: const EdgeInsets.all(16), alignment: Alignment.center, child: const Text('لم يتم رفع وثائق أو شهادات مهنية بعد.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')))
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: appState.technicianDocuments.length,
                  separatorBuilder: (_, __) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final doc = appState.technicianDocuments[index];
                    return Row(children: [
                      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.scaffoldBackground, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.description_outlined, color: AppColors.technicianPrimary, size: 20)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(doc.titleAr, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Cairo')), if (doc.documentNumber != null && doc.documentNumber!.isNotEmpty) Text('رقم: ${doc.documentNumber}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'))])),
                      StatusBadge.fromDocumentStatus(doc.status),
                    ]);
                  },
                ),
            ]),
          ),
          const SizedBox(height: 16),
          Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppColors.border),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListTile(
              onTap: () => appState.logout(),
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.errorLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20)),
              title: const Text('تسجيل الخروج', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error, fontFamily: 'Cairo')),
              trailing: const Icon(Icons.chevron_left_rounded, color: AppColors.textMuted),
            ),
          ),
          const SizedBox(height: 24),
        ]),
      ),
    );
  }
}
