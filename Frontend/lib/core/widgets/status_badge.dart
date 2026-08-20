import 'package:flutter/material.dart';
import '../../models/service_request_model.dart';
import '../../models/booking_model.dart';
import '../../models/technician_document_model.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    Key? key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  }) : super(key: key);

  factory StatusBadge.fromRequestStatus(ServiceRequestStatus status) {
    switch (status) {
      case ServiceRequestStatus.pending:
        return const StatusBadge(
          label: 'قيد الانتظار',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFB45309),
          icon: Icons.access_time_rounded,
        );
      case ServiceRequestStatus.accepted:
        return const StatusBadge(
          label: 'تم القبول',
          backgroundColor: Color(0xFFE0F2FE),
          textColor: Color(0xFF0369A1),
          icon: Icons.check_circle_outline_rounded,
        );
      case ServiceRequestStatus.scheduled:
        return const StatusBadge(
          label: 'مجدول',
          backgroundColor: Color(0xFFEDE9FE),
          textColor: Color(0xFF6D28D9),
          icon: Icons.calendar_today_rounded,
        );
      case ServiceRequestStatus.inProgress:
        return const StatusBadge(
          label: 'جاري التنفيذ',
          backgroundColor: Color(0xFFE0F2FE),
          textColor: Color(0xFF0284C7),
          icon: Icons.engineering_rounded,
        );
      case ServiceRequestStatus.completed:
        return const StatusBadge(
          label: 'مكتمل',
          backgroundColor: Color(0xFFD1FAE5),
          textColor: Color(0xFF047857),
          icon: Icons.verified_rounded,
        );
      case ServiceRequestStatus.cancelled:
        return const StatusBadge(
          label: 'ملغي',
          backgroundColor: Color(0xFFFFE4E6),
          textColor: Color(0xFFBE123C),
          icon: Icons.cancel_outlined,
        );
    }
  }

  factory StatusBadge.fromBookingStatus(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return const StatusBadge(
          label: 'قادم ومؤكد',
          backgroundColor: Color(0xFFEDE9FE),
          textColor: Color(0xFF6D28D9),
          icon: Icons.event_available_rounded,
        );
      case BookingStatus.technicianOnTheWay:
        return const StatusBadge(
          label: 'الفني في الطريق',
          backgroundColor: Color(0xFFDBEAFE),
          textColor: Color(0xFF1D4ED8),
          icon: Icons.directions_car_rounded,
        );
      case BookingStatus.arrived:
        return const StatusBadge(
          label: 'وصل الفني',
          backgroundColor: Color(0xFFDCFCE7),
          textColor: Color(0xFF15803D),
          icon: Icons.location_on_rounded,
        );
      case BookingStatus.inProgress:
        return const StatusBadge(
          label: 'جاري العمل',
          backgroundColor: Color(0xFFE0F2FE),
          textColor: Color(0xFF0284C7),
          icon: Icons.build_rounded,
        );
      case BookingStatus.awaitingCompletion:
        return const StatusBadge(
          label: 'بانتظار تأكيد العميل',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFB45309),
          icon: Icons.hourglass_bottom_rounded,
        );
      case BookingStatus.completed:
        return const StatusBadge(
          label: 'مكتمل',
          backgroundColor: Color(0xFFD1FAE5),
          textColor: Color(0xFF047857),
          icon: Icons.check_circle_rounded,
        );
      case BookingStatus.cancelled:
        return const StatusBadge(
          label: 'ملغي',
          backgroundColor: Color(0xFFFFE4E6),
          textColor: Color(0xFFBE123C),
          icon: Icons.cancel_rounded,
        );
      case BookingStatus.unknown:
        return const StatusBadge(
          label: 'حالة غير معروفة',
          backgroundColor: Color(0xFFF3F4F6),
          textColor: Color(0xFF374151),
          icon: Icons.help_outline_rounded,
        );
    }
  }

  factory StatusBadge.fromDocumentStatus(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.pending:
        return const StatusBadge(
          label: 'قيد المراجعة',
          backgroundColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFB45309),
          icon: Icons.hourglass_top_rounded,
        );
      case DocumentStatus.approved:
        return const StatusBadge(
          label: 'معتمد وموثق',
          backgroundColor: Color(0xFFD1FAE5),
          textColor: Color(0xFF047857),
          icon: Icons.verified_user_rounded,
        );
      case DocumentStatus.rejected:
        return const StatusBadge(
          label: 'مرفوض',
          backgroundColor: Color(0xFFFFE4E6),
          textColor: Color(0xFFBE123C),
          icon: Icons.error_outline_rounded,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
    );
  }
}
