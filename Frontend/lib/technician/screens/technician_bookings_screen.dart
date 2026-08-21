import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/network/api_exception.dart';
import '../../models/booking_model.dart';
import '../../services/app_state_provider.dart';
import '../../common/widgets/booking_verification_dialog.dart';

class TechnicianBookingsScreen extends StatefulWidget {
  const TechnicianBookingsScreen({Key? key}) : super(key: key);

  @override
  State<TechnicianBookingsScreen> createState() => _TechnicianBookingsScreenState();
}

class _TechnicianBookingsScreenState extends State<TechnicianBookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _transitioningBookingIds = <String>{};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> _filterBookings(List<BookingModel> all, int index) {
    switch (index) {
      case 0:
        return all.where((b) =>
            b.status == BookingStatus.upcoming ||
            b.status == BookingStatus.technicianOnTheWay ||
            b.status == BookingStatus.arrived).toList();
      case 1:
        return all.where((b) =>
            b.status == BookingStatus.inProgress ||
            b.status == BookingStatus.awaitingCompletion).toList();
      case 2:
        return all.where((b) => b.status == BookingStatus.completed).toList();
      default:
        return all;
    }
  }

  BookingStatus? _nextTransitionFor(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return BookingStatus.technicianOnTheWay;
      case BookingStatus.technicianOnTheWay:
        return BookingStatus.arrived;
      case BookingStatus.arrived:
        return null;
      case BookingStatus.inProgress:
        return BookingStatus.awaitingCompletion;
      case BookingStatus.awaitingCompletion:
      case BookingStatus.completed:
      case BookingStatus.cancelled:
      case BookingStatus.unknown:
        return null;
    }
  }

  String _actionLabelFor(BookingStatus status) {
    switch (status) {
      case BookingStatus.upcoming:
        return 'في الطريق';
      case BookingStatus.technicianOnTheWay:
        return 'وصلت للموقع';
      case BookingStatus.inProgress:
        return 'إنهاء العمل';
      case BookingStatus.arrived:
        return 'بدء العمل';
      case BookingStatus.awaitingCompletion:
        return 'بانتظار تأكيد العميل';
      case BookingStatus.completed:
      case BookingStatus.cancelled:
      case BookingStatus.unknown:
        return '';
    }
  }

  String _successMessage(BookingStatus status) {
    switch (status) {
      case BookingStatus.technicianOnTheWay:
        return 'تم تحديث حالة المهمة: الفني في الطريق.';
      case BookingStatus.arrived:
        return 'تم تسجيل وصولك إلى موقع العميل.';
      case BookingStatus.awaitingCompletion:
        return 'تم إنهاء العمل، والطلب الآن بانتظار تأكيد العميل.';
      default:
        return 'تم تحديث حالة الحجز بنجاح.';
    }
  }

  String _errorMessage(Object error) {
    if (error is ApiException) return error.message;
    final message = error.toString();
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  Future<void> _transitionBooking(BookingModel booking, BookingStatus nextStatus) async {
    if (_transitioningBookingIds.contains(booking.id)) return;

    setState(() => _transitioningBookingIds.add(booking.id));
    try {
      await Provider.of<AppStateProvider>(context, listen: false)
          .updateBookingStatus(booking.id, nextStatus);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_successMessage(nextStatus))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _transitioningBookingIds.remove(booking.id));
      }
    }
  }

  Future<void> _startJob(BookingModel booking) async {
    if (booking.status != BookingStatus.arrived) return;
    final provider = Provider.of<AppStateProvider>(context, listen: false);

    setState(() => _transitioningBookingIds.add(booking.id));
    try {
      await provider.requestJobStartCode(booking.id);
      if (!mounted) return;

      final verified = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => BookingVerificationDialog(
          title: 'تأكيد بدء العمل',
          description: 'أدخل رمز التحقق المكون من 6 أرقام لبدء تنفيذ الخدمة.',
          onVerify: (code) => provider.verifyJobStart(booking.id, code),
          onResend: () => provider.requestJobStartCode(booking.id),
        ),
      );

      if (!mounted) return;
      if (verified == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم تأكيد بدء العمل وتحديث حالة الحجز.')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_errorMessage(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _transitioningBookingIds.remove(booking.id));
      }
    }
  }

  Widget _buildAction(BookingModel booking) {
    final transitioning = _transitioningBookingIds.contains(booking.id);
    final nextStatus = _nextTransitionFor(booking.status);

    if (booking.status == BookingStatus.awaitingCompletion) {
      return const Text(
        'بانتظار تأكيد العميل',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          fontFamily: 'Cairo',
        ),
      );
    }

    if (booking.status == BookingStatus.arrived) {
      return OutlinedButton(
        onPressed: transitioning ? null : () => _startJob(booking),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.border),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: transitioning
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text(
                'بدء العمل',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo',
                ),
              ),
      );
    }

    if (nextStatus == null) return const SizedBox.shrink();

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: booking.status == BookingStatus.inProgress
            ? AppColors.successDark
            : AppColors.technicianPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: transitioning
          ? null
          : () => _transitionBooking(booking, nextStatus),
      child: transitioning
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
            )
          : Text(
              _actionLabelFor(booking.status),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'Cairo',
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('جدول المواعيد والحجوزات'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.technicianPrimary,
          unselectedLabelColor: AppColors.textMuted,
          indicatorColor: AppColors.technicianPrimary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Cairo',
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: 'القادمة'),
            Tab(text: 'قيد التنفيذ'),
            Tab(text: 'المكتملة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: List.generate(3, (tabIndex) {
          final bookings = _filterBookings(appState.bookings, tabIndex);

          if (bookings.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.event_busy_rounded,
              title: 'لا توجد حجوزات في هذا التبويب',
              description: 'يمكنك قبول طلبات صيانة جديدة من قائمة الطلبات المتاحة لتعبئة جدولك.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final b = bookings[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'حجز #${b.id}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          StatusBadge.fromBookingStatus(b.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        b.serviceNameAr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'العميل: ${b.customerName}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          fontFamily: 'Cairo',
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.scaffoldBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.schedule_rounded,
                                  size: 16,
                                  color: AppColors.technicianPrimary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'الموعد: ${b.scheduledDate} (${b.scheduledTime})',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Cairo',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_rounded,
                                  size: 16,
                                  color: AppColors.technicianPrimary,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${b.address.city} - ${b.address.fullAddressDescription}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Cairo',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'المبلغ: ${b.price.toInt()} ج.م',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppColors.technicianDark,
                              fontFamily: 'Cairo',
                            ),
                          ),
                          _buildAction(b),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}
