import 'package:flutter/material.dart';
import '../neon_theme.dart';
class VipScreen extends StatelessWidget { const VipScreen({super.key}); @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('NEON VIP')),body:ListView(padding:const EdgeInsets.all(20),children:[
  const NeonPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Icon(Icons.workspace_premium_rounded,color:Color(0xFFFFD76A),size:52),SizedBox(height:12),Text('NEON VIP',style:TextStyle(fontSize:28,fontWeight:FontWeight.w900)),SizedBox(height:8),Text('Premium matching perks without making the core app harder to use.',style:TextStyle(color:Colors.white70))])),
  const SizedBox(height:18),...['Priority matching','Extra profile filters','VIP badge','Monthly coin bonus'].map((x)=>ListTile(leading:const Icon(Icons.check_circle,color:NeonTheme.success),title:Text(x))),
  const SizedBox(height:16),FilledButton(onPressed:null,child:Padding(padding:EdgeInsets.symmetric(vertical:14),child:Text('Connect App Store / Google Play billing'))),
  const SizedBox(height:10),Text('Real-money purchases are intentionally disabled in this demo until official in-app purchase verification is connected.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white54,fontSize:12)),
])); }
