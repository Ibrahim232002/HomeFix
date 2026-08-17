import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_design_tokens.dart';
import '../../core/theme/app_responsive.dart';
import '../../core/widgets/homefix_card.dart';
import '../../core/widgets/homefix_states.dart';
import '../../core/widgets/homefix_status_chip.dart';
import '../../models/service_request_model.dart';
import '../../services/app_state_provider.dart';
import 'technician_request_detail_screen.dart';

class TechnicianRequestsScreen extends StatefulWidget {
  const TechnicianRequestsScreen({super.key});
  @override State<TechnicianRequestsScreen> createState() => _TechnicianRequestsScreenState();
}

class _TechnicianRequestsScreenState extends State<TechnicianRequestsScreen> {
  bool _loading = true; String? _error;
  @override void initState(){super.initState();_load();}
  Future<void> _load() async { setState((){_loading=true;_error=null;}); try{await context.read<AppStateProvider>().refreshAuthenticatedData();if(mounted)setState(()=>_loading=false);}catch(e){if(mounted)setState((){_loading=false;_error=e.toString().replaceFirst('Exception: ','');});}}
  @override Widget build(BuildContext context){final requests=context.watch<AppStateProvider>().availableTechRequests;return Scaffold(appBar:AppBar(title:const Text('طلبات الخدمة')),body:RefreshIndicator(onRefresh:_load,child:ListView(padding:AppResponsive.pagePadding(context),physics:const AlwaysScrollableScrollPhysics(),children:[AppResponsive.content(context,child:_loading?const HomeFixLoadingList(itemCount:4):_error!=null?HomeFixErrorState(title:'تعذر تحميل الطلبات',message:_error,onRetry:_load):requests.isEmpty?const SizedBox(height:420,child:HomeFixEmptyState(icon:Icons.inbox_outlined,title:'لا توجد طلبات جديدة',message:'ستظهر هنا الطلبات المناسبة لك عند توفرها.')):Column(children:requests.map((ServiceRequestModel request)=>Padding(padding:const EdgeInsets.only(bottom:AppDesignTokens.space3),child:HomeFixCard(onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>TechnicianRequestDetailScreen(request:request))),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(children:[Expanded(child:Text(request.serviceNameAr,style:Theme.of(context).textTheme.titleMedium)),HomeFixStatusChip(label:request.status.displayNameAr,tone:HomeFixStatusTone.technician)]),const SizedBox(height:AppDesignTokens.space2),Text(request.problemDescription,maxLines:3,overflow:TextOverflow.ellipsis),const SizedBox(height:AppDesignTokens.space3),Row(children:[const Icon(Icons.schedule_outlined,size:18),const SizedBox(width:6),Expanded(child:Text('${request.preferredDate} • ${request.preferredTime}')),Text('#${request.id}',style:Theme.of(context).textTheme.bodySmall?.copyWith(color:Colors.grey))])])))).toList()))]));}
}
