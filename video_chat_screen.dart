import 'dart:async';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';
import '../models/match_result.dart';
import '../neon_theme.dart';
import '../services/livekit_service.dart';
import '../services/matchmaking_service.dart';
import '../services/social_service.dart';

class VideoChatScreen extends StatefulWidget {
  const VideoChatScreen({super.key,required this.region,required this.language,this.genderPreference='Everyone'});
  final String region, language, genderPreference;
  @override State<VideoChatScreen> createState()=>_VideoChatScreenState();
}

class _VideoChatScreenState extends State<VideoChatScreen> {
  final liveKit=LiveKitService(), matchmaking=MatchmakingService(), social=SocialService();
  Timer? poller; MatchResult? match; bool searching=true,micOn=true,cameraOn=true,friendRequested=false; String status='Finding someone…';

  @override void initState(){super.initState();_beginSearch();}
  Future<void> _beginSearch() async {
    poller?.cancel(); await liveKit.disconnect(); if(!mounted)return;
    setState((){searching=true;match=null;friendRequested=false;status='Finding someone…';});
    try{final r=await matchmaking.join(region:widget.region,language:widget.language,genderPreference:widget.genderPreference);if(!mounted)return;if(r.matched){await _connectMatch(r);}else{poller=Timer.periodic(const Duration(seconds:2),(_)=>_poll());}}
    catch(e){if(mounted)setState((){searching=false;status='Could not start matching: $e';});}
  }
  Future<void> _poll() async {try{final r=await matchmaking.status();if(!mounted||!r.matched)return;poller?.cancel();await _connectMatch(r);}catch(_){}}
  Future<void> _connectMatch(MatchResult r) async {setState((){match=r;status='Connecting to ${r.partnerName}…';});try{await liveKit.connect(url:r.liveKitUrl!,token:r.token!);if(mounted)setState((){searching=false;status='Connected with ${r.partnerName}';});}catch(e){if(mounted)setState((){searching=false;status='Video connection failed: $e';});}}
  Future<void> _next({bool askRating=true}) async {if(askRating)await _ratePrompt();poller?.cancel();await liveKit.disconnect();try{await matchmaking.leave();}catch(_){}await _beginSearch();}
  Future<void> _addFriend() async {final id=match?.partnerId;if(id==null)return;try{await social.addFriend(id);if(mounted)setState(()=>friendRequested=true);_msg('Friend request sent.');}catch(e){_msg(e.toString());}}
  Future<void> _giftPicker() async {
    final id=match?.partnerId;if(id==null)return;
    final g=await showModalBottomSheet<String>(context:context,builder:(c)=>SafeArea(child:Column(mainAxisSize:MainAxisSize.min,children:[const ListTile(title:Text('Send a gift',style:TextStyle(fontWeight:FontWeight.w900))),...[
      ('rose','🌹','Rose',20),('gem','💎','Gem',50),('fire','🔥','Fire',100),('crown','👑','Crown',250)
    ].map((x)=>ListTile(leading:Text(x.$2,style:const TextStyle(fontSize:28)),title:Text(x.$3),trailing:Text('${x.$4} coins'),onTap:()=>Navigator.pop(c,x.$1))) ])));
    if(g==null)return;try{await social.sendGift(id,g);_msg('Gift sent ✨');}catch(e){_msg(e.toString());}
  }
  Future<void> _ratePrompt() async {final id=match?.partnerId;if(id==null||searching)return;final stars=await showDialog<int>(context:context,builder:(c)=>AlertDialog(title:const Text('How was this chat?'),content:Row(mainAxisAlignment:MainAxisAlignment.center,children:List.generate(5,(i)=>IconButton(onPressed:()=>Navigator.pop(c,i+1),icon:const Icon(Icons.star_rounded,color:Color(0xFFFFD76A))))),actions:[TextButton(onPressed:()=>Navigator.pop(c),child:const Text('Skip'))]));if(stars!=null){try{await social.rate(id,stars);}catch(_){}}}
  Future<void> _report() async {final id=match?.partnerId;if(id==null)return;final reason=await showDialog<String>(context:context,builder:(c)=>SimpleDialog(title:const Text('Report this user'),children:['Harassment','Nudity / sexual content','Hate or threats','Spam / scam','Underage concern'].map((r)=>SimpleDialogOption(onPressed:()=>Navigator.pop(c,r),child:Text(r))).toList()));if(reason==null)return;try{await matchmaking.report(targetUserId:id,reason:reason);_msg('Report submitted.');await _next(askRating:false);}catch(e){_msg(e.toString());}}
  Future<void> _block() async {final id=match?.partnerId;if(id==null)return;try{await matchmaking.block(targetUserId:id);_msg('User blocked.');await _next(askRating:false);}catch(e){_msg(e.toString());}}
  void _msg(String s){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(s)));}

  VideoTrack? _remoteVideo(Room r){for(final p in r.remoteParticipants.values){for(final pub in p.videoTrackPublications){final t=pub.track;if(t is VideoTrack)return t;}}return null;}
  VideoTrack? _localVideo(Room r){for(final pub in r.localParticipant.videoTrackPublications){final t=pub.track;if(t is VideoTrack)return t;}return null;}
  @override void dispose(){poller?.cancel();matchmaking.leave();liveKit.disconnect();super.dispose();}

  @override Widget build(BuildContext context){final room=liveKit.room;return PopScope(onPopInvokedWithResult:(_,__)async{poller?.cancel();await matchmaking.leave();await liveKit.disconnect();},child:Scaffold(backgroundColor:NeonTheme.bg,body:SafeArea(child:Stack(children:[
    Positioned.fill(child:_videoArea(room)),
    Positioned(top:12,left:12,right:12,child:Row(children:[_circle(Icons.close,()=>Navigator.pop(context)),const Spacer(),if(match!=null)Container(padding:const EdgeInsets.symmetric(horizontal:10,vertical:7),decoration:BoxDecoration(color:Colors.black54,borderRadius:BorderRadius.circular(20)),child:Row(children:[if(match!.partnerVip)const Icon(Icons.workspace_premium,color:Color(0xFFFFD76A),size:17),if(match!.partnerVip)const SizedBox(width:4),Text('${match!.partnerName}  ★ ${(match!.partnerRating??5).toStringAsFixed(1)}',style:const TextStyle(fontWeight:FontWeight.w800))])),PopupMenuButton<String>(iconColor:Colors.white,enabled:match!=null,onSelected:(v)=>v=='report'?_report():_block(),itemBuilder:(_)=>const[PopupMenuItem(value:'report',child:Text('Report user')),PopupMenuItem(value:'block',child:Text('Block user'))])])),
    if(match!=null)Positioned(left:14,right:14,bottom:115,child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[_action(friendRequested?Icons.person_add_alt_1:Icons.person_add_rounded,friendRequested?'Requested':'Add friend',friendRequested?null:_addFriend),const SizedBox(width:10),_action(Icons.card_giftcard_rounded,'Gift',_giftPicker)])),
    Positioned(left:16,right:16,bottom:88,child:Text(status,textAlign:TextAlign.center,style:const TextStyle(color:Colors.white70,fontWeight:FontWeight.w600))),
    Positioned(left:0,right:0,bottom:18,child:Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[_round(micOn?Icons.mic:Icons.mic_off,()async{setState(()=>micOn=!micOn);await liveKit.setMicEnabled(micOn);}),_round(Icons.skip_next_rounded,_next,large:true),_round(cameraOn?Icons.videocam:Icons.videocam_off,()async{setState(()=>cameraOn=!cameraOn);await liveKit.setCameraEnabled(cameraOn);})]))
  ])))) ;}
  Widget _videoArea(Room? room){if(searching||room==null)return const Center(child:Column(mainAxisSize:MainAxisSize.min,children:[NeonLogo(size:78),SizedBox(height:22),CircularProgressIndicator(color:NeonTheme.blue),SizedBox(height:14),Text('Finding your next vibe…',style:TextStyle(color:Colors.white70,fontWeight:FontWeight.w700))]));return AnimatedBuilder(animation:room,builder:(c,_){final remote=_remoteVideo(room),local=_localVideo(room);return Stack(fit:StackFit.expand,children:[if(remote!=null)VideoTrackRenderer(remote,fit:VideoViewFit.cover)else const ColoredBox(color:Colors.black,child:Center(child:Icon(Icons.person,size:120,color:Colors.white38))),if(local!=null)Positioned(right:14,top:70,width:120,height:170,child:ClipRRect(borderRadius:BorderRadius.circular(18),child:VideoTrackRenderer(local,fit:VideoViewFit.cover)))]);});}
  Widget _circle(IconData i,VoidCallback f)=>Container(decoration:BoxDecoration(color:Colors.black45,shape:BoxShape.circle,border:Border.all(color:Colors.white24)),child:IconButton(onPressed:f,icon:Icon(i,color:Colors.white)));
  Widget _action(IconData i,String t,VoidCallback? f)=>FilledButton.tonalIcon(onPressed:f,icon:Icon(i,size:18),label:Text(t));
  Widget _round(IconData i,VoidCallback f,{bool large=false})=>SizedBox(width:large?72:58,height:large?72:58,child:FloatingActionButton(heroTag:'${i.codePoint}-$large',backgroundColor:large?NeonTheme.purple:const Color(0xCC171A35),foregroundColor:Colors.white,onPressed:f,child:Icon(i,size:large?34:26)));
}
