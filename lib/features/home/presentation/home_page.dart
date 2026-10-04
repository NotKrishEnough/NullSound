import 'package:flutter/material.dart';
import '../../../app/glass.dart';
import '../../settings/presentation/settings_page.dart';

class HomePage extends StatelessWidget {
 const HomePage({super.key});
 @override Widget build(BuildContext context) => Scaffold(
  backgroundColor: Colors.transparent,
  body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(22,24,22,190), children: [
   Row(children: [
    Container(width: 42,height:42,decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha:.18),borderRadius: BorderRadius.circular(15)),child: const Icon(Icons.graphic_eq_rounded)),
    const SizedBox(width: 12),
    Text('NullSound', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900,letterSpacing:-1)),
    const Spacer(),
    IconButton(tooltip:'Settings',onPressed:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>const SettingsPage())),icon:const Icon(Icons.tune_rounded,size:26)),
   ]),
   const SizedBox(height: 8),
   Text('Find your next favourite.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha:.72))),
   const SizedBox(height: 30),
   GlassPanel(radius:30,padding:const EdgeInsets.all(20),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Text('MADE FOR YOUR MOOD',style:Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing:2,fontWeight:FontWeight.bold,color:Theme.of(context).colorScheme.primary)),
    const SizedBox(height:14),
    Text('A little less noise.\nA lot more music.',style:Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight:FontWeight.w800,height:1.08)),
    const SizedBox(height:20),
    Container(height:150,decoration:BoxDecoration(borderRadius:BorderRadius.circular(24),gradient:const LinearGradient(begin:Alignment.topLeft,end:Alignment.bottomRight,colors:[Color(0xff594477),Color(0xffa95f83),Color(0xffd18c85)])),child:Stack(children:[
     const Positioned(right:18,top:14,child:Icon(Icons.blur_on_rounded,size:105,color:Colors.white24)),
     Center(child:Icon(Icons.graphic_eq_rounded,size:72,color:Colors.white.withValues(alpha:.95))),
     const Positioned(left:18,bottom:14,child:Text('PRESS PLAY. FEEL EVERYTHING.',style:TextStyle(color:Colors.white,fontWeight:FontWeight.bold,letterSpacing:1.5))),
    ])),
   ])),
   const SizedBox(height:28),
   Row(children:[Text('Your next soundtrack',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),const Spacer(),const Icon(Icons.arrow_forward_rounded)]),
   const SizedBox(height:12),
   GlassPanel(padding:const EdgeInsets.all(16),child:Row(children:[
    Container(width:52,height:52,decoration:BoxDecoration(color:Theme.of(context).colorScheme.primary.withValues(alpha:.18),borderRadius:BorderRadius.circular(16)),child:const Icon(Icons.search_rounded,size:28)),
    const SizedBox(width:14),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('Start with a search',style:TextStyle(fontWeight:FontWeight.w700)),SizedBox(height:4),Text('Explore songs, artists and playlists') ])),
    const Icon(Icons.chevron_right_rounded),
   ])),
  ])));
}
