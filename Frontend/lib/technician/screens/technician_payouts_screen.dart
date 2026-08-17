import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/api_dtos.dart';
import '../../repositories/wallet_repository.dart';
import '../../services/app_state_provider.dart';

class TechnicianPayoutsScreen extends StatefulWidget { const TechnicianPayoutsScreen({super.key}); @override State<TechnicianPayoutsScreen> createState()=>_TechnicianPayoutsScreenState(); }
class _TechnicianPayoutsScreenState extends State<TechnicianPayoutsScreen>{
 final IWalletRepository _repo=WalletRepository(); List<PayoutDto> _payouts=const []; bool _loading=true; String? _error;
 @override void initState(){super.initState();_load();}
 Future<void> _load() async{if(context.read<AppStateProvider>().currentUser==null)return;setState((){_loading=true;_error=null;});try{final data=await _repo.getApiPayoutsForCurrentTechnician();if(mounted)setState((){_payouts=data;_loading=false;});}catch(e){if(mounted)setState((){_loading=false;_error=e.toString().replaceFirst('Exception: ','');});}}
 HomeFixStatusTone _tone(String? s){switch((s??'').toLowerCase()){case'completed':case'paid':return HomeFixStatusTone.success;case'rejected':case'failed':return HomeFixStatusTone.error;case'pending':return HomeFixStatusTone.warning;default:return HomeFixStatusTone.neutral;}}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('طلبات السحب')),body:RefreshIndicator(onRefresh:_load,child:ListView(padding:AppResponsive.pagePadding(context),physics:const AlwaysScrollableScrollPhysics(),children:[AppResponsive.content(context,child:_loading?const HomeFixLoadingList(itemCount:4):_error!=null?HomeFixErrorState(title:'تعذر تحميل طلبات السحب',message:_error,onRetry:_load):_payouts.isEmpty?const SizedBox(height:420,child:HomeFixEmptyState(icon:Icons.payments_outlined,title:'لا توجد طلبات سحب',message:'ستظهر هنا طلبات السحب التي أنشأتها وحالاتها.')):Column(children:_payouts.map((p)=>Padding(padding:const EdgeInsets.only(bottom:AppDesignTokens.space3),child:HomeFixCard(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text('${p.amount.toStringAsFixed(2)} ج.م',style:Theme.of(context).textTheme.headlineSmall)),HomeFixStatusChip(label:p.status??'Pending',tone:_tone(p.status))]),const SizedBox(height:AppDesignTokens.space2),Text(p.paymentMethod??'طريقة السحب غير محددة'),Text('طُلب في ${p.requestedAt}',style:Theme.of(context).textTheme.bodySmall?.copyWith(color:Colors.grey)),if(p.transactionReference?.isNotEmpty==true)Text('مرجع: ${p.transactionReference}',style:Theme.of(context).textTheme.bodySmall)])))).toList()))])));
}
