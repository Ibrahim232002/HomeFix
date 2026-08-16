import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/wallet_model.dart';
import '../../services/app_state_provider.dart';

class TechnicianWalletScreen extends StatelessWidget {
  const TechnicianWalletScreen({Key? key}) : super(key: key);

  void _showWithdrawDialog(BuildContext context, double currentBalance) {
    final amountController = TextEditingController();
    final ibanController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('طلب تحويل الأرباح للبنك أو المحفظة الذكية', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('الرصيد المتاح للسحب حالياً: ${currentBalance.toInt()} ج.م', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Cairo')),
                const SizedBox(height: 14),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'المبلغ المطلوب سحبه (ج.م)'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: ibanController,
                  decoration: const InputDecoration(labelText: 'رقم الحساب البنكي / الآيبان أو فودافون كاش / إنستاباي'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.technicianPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final amt = double.tryParse(amountController.text) ?? 0;
                if (amt > 0) {
                  Provider.of<AppStateProvider>(context, listen: false).requestWithdrawal(
                    amt,
                    ibanController.text,
                  );
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.successDark,
                      content: Text('تم استلام طلب سحب مبلغ $amt ج.م وسيصل لحسابك البنكي أو المحفظة قريباً.'),
                    ),
                  );
                }
              },
              child: const Text('تأكيد التحويل', style: TextStyle(fontFamily: 'Cairo', color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppStateProvider>(context);
    final wallet = appState.wallet;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('المحفظة المالية والأرباح'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Balance Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'الرصيد المتاح للسحب الفوري',
                        style: TextStyle(fontSize: 13, color: Colors.white70, fontFamily: 'Cairo'),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('EGP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${wallet?.currentBalance.toStringAsFixed(2) ?? '0.00'} ج.م',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('إجمالي الأرباح الكلية', style: TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'Cairo')),
                            Text(
                              '${wallet?.totalEarnings.toStringAsFixed(2) ?? '0.00'} ج.م',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('المبالغ المسحوبة سابقاً', style: TextStyle(fontSize: 11, color: Colors.white70, fontFamily: 'Cairo')),
                            Text(
                              '${wallet?.totalWithdrawn.toStringAsFixed(2) ?? '0.00'} ج.م',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Withdraw Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.technicianPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.arrow_circle_up_rounded, color: Colors.white),
              label: const Text(
                'طلب سحب أرباح إلى حسابك البنكي أو المحفظة',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
              ),
              onPressed: (wallet != null && wallet.currentBalance > 0)
                  ? () => _showWithdrawDialog(context, wallet.currentBalance)
                  : null,
            ),
            const SizedBox(height: 24),

            // Transaction History Header
            const Text(
              'سجل المعاملات والحركات المالية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 12),

            // Transaction List
            if (wallet == null || wallet.transactions.isEmpty)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: const [
                    Icon(Icons.account_balance_wallet_outlined, size: 48, color: AppColors.textMuted),
                    SizedBox(height: 12),
                    Text(
                      'لا توجد حركات مالية مسجلة حتى الآن',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textSecondary, fontFamily: 'Cairo'),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'ستظهر هنا جميع أرباح الطلبات المكتملة وعمليات سحب الرصيد.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Cairo'),
                    ),
                  ],
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: wallet.transactions.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final tx = wallet.transactions[index];
                  final isCredit = tx.amount > 0;

                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isCredit ? AppColors.successLight : AppColors.errorLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                            color: isCredit ? AppColors.successDark : AppColors.errorDark,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.titleAr,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, fontFamily: 'Cairo'),
                              ),
                              Text(
                                '${tx.date} • ${tx.descriptionAr}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'Cairo'),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${isCredit ? "+" : ""}${tx.amount.toInt()} ج.م',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isCredit ? AppColors.successDark : AppColors.errorDark,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
