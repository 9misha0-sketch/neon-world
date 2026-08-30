import 'package:flutter/material.dart';
import '../neon_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget { const LoginScreen({super.key}); @override State<LoginScreen> createState()=>_LoginScreenState(); }
class _LoginScreenState extends State<LoginScreen>{
  final email=TextEditingController(); final password=TextEditingController(); final auth=AuthService(); bool busy=false; bool createAccount=false;
  @override void dispose(){email.dispose();password.dispose();super.dispose();}
  Future<void> submit() async {if(email.text.trim().isEmpty||password.text.length<6){_message('Enter a valid email and a password of at least 6 characters.');return;} setState(()=>busy=true);try{if(createAccount){final r=await auth.signUp(email.text,password.text);if(r.session==null&&mounted){_message('Account created. Check your email, then sign in.');setState(()=>createAccount=false);}}else{await auth.signIn(email.text,password.text);}}catch(e){_message(e.toString());}finally{if(mounted)setState(()=>busy=false);}}
  void _message(String t){if(mounted)ScaffoldMessenger.of(context).showSnackBar(SnackBar(content:Text(t)));}
  @override Widget build(BuildContext context)=>Scaffold(body:Container(
    decoration:const BoxDecoration(gradient:RadialGradient(center:Alignment(-.8,-.8),radius:1.35,colors:[Color(0x558B5CFF),Color(0x00070816)])),
    child:SafeArea(child:Center(child:SingleChildScrollView(padding:const EdgeInsets.all(24),child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:440),child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
      const Center(child:NeonLogo(size:92)),const SizedBox(height:22),const Text('NEON WORLD',textAlign:TextAlign.center,style:TextStyle(fontSize:29,fontWeight:FontWeight.w900,letterSpacing:2)),const SizedBox(height:5),Text('One tap. One world. Real people.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white.withValues(alpha:.56))),const SizedBox(height:30),
      NeonPanel(child:Column(crossAxisAlignment:CrossAxisAlignment.stretch,children:[
        Text(createAccount?'Create your account':'Welcome back',style:const TextStyle(fontSize:22,fontWeight:FontWeight.w900)),const SizedBox(height:16),
        TextField(controller:email,keyboardType:TextInputType.emailAddress,autofillHints:const[AutofillHints.email],decoration:const InputDecoration(labelText:'Email',prefixIcon:Icon(Icons.alternate_email_rounded))),const SizedBox(height:12),
        TextField(controller:password,obscureText:true,autofillHints:const[AutofillHints.password],decoration:const InputDecoration(labelText:'Password',prefixIcon:Icon(Icons.lock_outline_rounded))),const SizedBox(height:16),
        SizedBox(height:56,child:FilledButton(onPressed:busy?null:submit,child:busy?const SizedBox(width:22,height:22,child:CircularProgressIndicator(strokeWidth:2)):Text(createAccount?'CREATE ACCOUNT':'SIGN IN'))),
        TextButton(onPressed:busy?null:()=>setState(()=>createAccount=!createAccount),child:Text(createAccount?'Already a member? Sign in':'New here? Create account')),
      ])),const SizedBox(height:16),Text('18+ only • By continuing you agree to the community safety rules.',textAlign:TextAlign.center,style:TextStyle(color:Colors.white.withValues(alpha:.4),fontSize:12)),
    ]))))),
  ));
}
