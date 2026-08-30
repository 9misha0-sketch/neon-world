import 'package:flutter/material.dart';
import '../services/admin_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override State<AdminScreen> createState()=>_AdminScreenState();
}
class _AdminScreenState extends State<AdminScreen> {
  final service=AdminService(); List<Map<String,dynamic>> reports=[]; bool loading=true;
  @override void initState(){super.initState();load();}
  Future<void> load() async {try{final x=await service.reports();if(mounted)setState((){reports=x;loading=false;});}catch(e){if(mounted){setState(()=>loading=false);ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}}}
  Future<void> action(Map<String,dynamic> r,bool ban) async {await service.resolve(r['id'].toString(),ban:ban);if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(ban?'User banned':'Report resolved')));await load();}
  @override Widget build(BuildContext context)=>Scaffold(
    appBar:AppBar(title:const Text('Admin • Moderation')),
    body:loading?const Center(child:CircularProgressIndicator()):RefreshIndicator(onRefresh:load,child:reports.isEmpty?ListView(children:const[Padding(padding:EdgeInsets.all(30),child:Center(child:Text('No open reports 🎉'))) ]):ListView.builder(padding:const EdgeInsets.all(12),itemCount:reports.length,itemBuilder:(_,i){final r=reports[i];return Card(child:ListTile(title:Text(r['reason']?.toString()??'Report'),subtitle:Text('Reported user: ${r['reported_id']}\n${r['created_at']}'),isThreeLine:true,trailing:PopupMenuButton<String>(onSelected:(v)=>action(r,v=='ban'),itemBuilder:(_)=>const[PopupMenuItem(value:'resolve',child:Text('Resolve')),PopupMenuItem(value:'ban',child:Text('Ban user'))])));})),
  );
}
