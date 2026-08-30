import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/social_service.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key,required this.friend});
  final Map<String,dynamic> friend;
  @override State<MessagesScreen> createState()=>_MessagesScreenState();
}
class _MessagesScreenState extends State<MessagesScreen> {
  final service=SocialService(), text=TextEditingController();
  final scroll=ScrollController();
  List<Map<String,dynamic>> messages=[]; Timer? timer; bool sending=false;
  @override void initState(){super.initState();load();timer=Timer.periodic(const Duration(seconds:2),(_)=>load(silent:true));}
  Future<void> load({bool silent=false}) async {try{final x=await service.messagesWith(widget.friend['id']);if(mounted){final changed=x.length!=messages.length;setState(()=>messages=x);if(changed)WidgetsBinding.instance.addPostFrameCallback((_){if(scroll.hasClients)scroll.animateTo(scroll.position.maxScrollExtent,duration:const Duration(milliseconds:220),curve:Curves.easeOut);});}}catch(e){if(!silent&&mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text('$e')));}}
  Future<void> send() async {final v=text.text.trim();if(v.isEmpty||sending)return;setState(()=>sending=true);text.clear();try{await service.sendMessage(widget.friend['id'],v);await load();}finally{if(mounted)setState(()=>sending=false);}}
  @override void dispose(){timer?.cancel();text.dispose();scroll.dispose();super.dispose();}
  @override Widget build(BuildContext context){final me=Supabase.instance.client.auth.currentUser!.id;return Scaffold(appBar:AppBar(title:Text(widget.friend['display_name']??'Chat')),body:Column(children:[
    Expanded(child:ListView(controller:scroll,padding:const EdgeInsets.all(16),children:messages.map((m){final own=m['sender_id']==me;return Align(alignment:own?Alignment.centerRight:Alignment.centerLeft,child:Container(constraints:BoxConstraints(maxWidth:MediaQuery.sizeOf(context).width*.74),margin:const EdgeInsets.symmetric(vertical:4),padding:const EdgeInsets.symmetric(horizontal:14,vertical:10),decoration:BoxDecoration(color:own?Theme.of(context).colorScheme.primary:Colors.white10,borderRadius:BorderRadius.circular(16)),child:Text(m['body']?.toString()??'')));}).toList())),
    SafeArea(top:false,child:Padding(padding:const EdgeInsets.all(10),child:Row(children:[Expanded(child:TextField(controller:text,textInputAction:TextInputAction.send,onSubmitted:(_)=>send(),decoration:const InputDecoration(hintText:'Message…'))),const SizedBox(width:6),IconButton(onPressed:sending?null:send,icon:sending?const SizedBox(width:20,height:20,child:CircularProgressIndicator(strokeWidth:2)):const Icon(Icons.send_rounded))])))
  ]));}
}
