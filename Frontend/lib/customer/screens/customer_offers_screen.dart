import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state.dart';
import '../../models/service_request_offer_model.dart';
import '../../services/app_state_provider.dart';

class CustomerOffersScreen extends StatefulWidget {
  final String requestId;

  const CustomerOffersScreen({super.key, required this.requestId});

  @override
  State<CustomerOffersScreen> createState() => _CustomerOffersScreenState();
}

class _CustomerOffersScreenState extends State<CustomerOffersScreen> {
  late Future<List<ServiceRequestOfferModel>> _future;
  final Set<String> _busyOffers = <String>{};

  @override
  void initState() {
    super.initState();
    _future = context.read<AppStateProvider>().loadOffersForRequest(widget.requestId);
  }

  Future<void> _accept(ServiceRequestOfferModel offer) async {
    if (_busyOffers.contains(offer.id)) return;
    setState(() => _busyOffers.add(offer.id));
    try {
      await context.read<AppStateProvider>().acceptOffer(offer.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم قبول العرض وإنشاء الحجز على الخادم.')),
        );
        setState(() {
          _future = context.read<AppStateProvider>().loadOffersForRequest(widget.requestId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busyOffers.remove(offer.id));
    }
  }

  Future<void> _reject(ServiceRequestOfferModel offer) async {
    if (_busyOffers.contains(offer.id)) return;
    setState(() => _busyOffers.add(offer.id));
    try {
      await context.read<AppStateProvider>().rejectOffer(offer.id);
      if (mounted) {
        setState(() {
          _future = context.read<AppStateProvider>().loadOffersForRequest(widget.requestId);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _busyOffers.remove(offer.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('عروض الطلب #${widget.requestId}')),
      body: FutureBuilder<List<ServiceRequestOfferModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return EmptyStateWidget(
              icon: Icons.cloud_off_outlined,
              title: 'تعذر تحميل العروض',
              description: snapshot.error.toString(),
              actionText: 'إعادة المحاولة',
              onAction: () => setState(() {
                _future = context.read<AppStateProvider>().loadOffersForRequest(widget.requestId);
              }),
            );
          }

          final offers = snapshot.data ?? const <ServiceRequestOfferModel>[];
          if (offers.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.local_offer_outlined,
              title: 'لا توجد عروض بعد',
              description: 'سنظهر هنا عروض الفنيين عندما يقدمون أسعارهم للطلب.',
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final offer = offers[index];
              final busy = _busyOffers.contains(offer.id);
              final pending = offer.status.toLowerCase() == 'pending';
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(offer.technicianName.isEmpty ? 'فني' : offer.technicianName, style: const TextStyle(fontWeight: FontWeight.w800)),
                          Text('${offer.proposedPrice.toStringAsFixed(2)} ج.م', style: const TextStyle(fontWeight: FontWeight.w900)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(offer.technicianNote.isEmpty ? 'لا توجد ملاحظات' : offer.technicianNote),
                      const SizedBox(height: 8),
                      Text('الحالة: ${offer.status}'),
                      if (pending) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: busy ? null : () => _accept(offer),
                                child: busy ? const CircularProgressIndicator() : const Text('قبول العرض'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: busy ? null : () => _reject(offer),
                                child: const Text('رفض'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
