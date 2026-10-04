import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../app/glass.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override State<SettingsPage> createState() => _SettingsPageState();
}
class _SettingsPageState extends State<SettingsPage> {
  SharedPreferences? prefs;
  double blur = 22, glass = .72, roundness = 24;
  int accent = 0;
  bool glow = true, compact = false, artwork = true;
  static const colors = [Color(0xffbd829f),Color(0xff8b80d8),Color(0xff5f9fba),Color(0xff68a88d),Color(0xffd49a63),Color(0xffdc7180),Color(0xffe4e4e4)];
  @override void initState(){super.initState();_load();}
  Future<void> _load() async {
    final p=await SharedPreferences.getInstance();
    if(!mounted)return;
    setState((){
      prefs=p; blur=p.getDouble('setting_blur')??22; glass=p.getDouble('setting_glass')??.72;
      roundness=p.getDouble('setting_roundness')??24;
      accent=p.getInt('setting_accent')??0; glow=p.getBool('setting_glow')??true;
      compact=p.getBool('setting_compact')??false; artwork=p.getBool('setting_artwork')??true;
      haptics=p.getBool('setting_haptics')??true; animated=p.getBool('setting_animated')??true;
      edgeToEdge=p.getBool('setting_edge')??true;
    });
  }
  Future<void> save(String key,Object value) async {
    final p=prefs??await SharedPreferences.getInstance();
    if(value is bool) await p.setBool(key,value);
    if(value is int) await p.setInt(key,value);
    if(value is double) await p.setDouble(key,value);
  }
  Widget section(String title,IconData icon,List<Widget> children)=>Padding(
    padding:const EdgeInsets.only(bottom:18),
    child:GlassPanel(radius:24,padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Row(children:[Icon(icon,color:Theme.of(context).colorScheme.primary),const SizedBox(width:10),Text(title,style:Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight:FontWeight.bold))]),
      const SizedBox(height:10),...children
    ])));
  Widget toggle(String title,String subtitle,bool value,String key,ValueChanged<bool> update)=>SwitchListTile.adaptive(
    contentPadding:EdgeInsets.zero,title:Text(title),subtitle:Text(subtitle),value:value,
    onChanged:(v){setState(()=>update(v));save(key,v);});
  Widget slider(String title,double value,double min,double max,String key,ValueChanged<double> update,{String suffix=''})=>Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[Expanded(child:Text(title)),Text('${value.toStringAsFixed(0)}$suffix',style:Theme.of(context).textTheme.labelLarge)]),
    Slider(value:value.clamp(min,max).toDouble(),min:min,max:max,onChanged:(v){setState(()=>update(v));save(key,v);})
  ]);
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:Colors.transparent,
    appBar:AppBar(title:const Text('Settings')),
    body:prefs==null?const Center(child:CircularProgressIndicator()):ListView(padding:const EdgeInsets.fromLTRB(16,8,16,36),children:[
      Text('Make NullSound yours',style:Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight:FontWeight.bold)),
      const SizedBox(height:5),Text('Personalise the look, feel and player.',style:Theme.of(context).textTheme.bodyMedium),
      const SizedBox(height:18),
      section('Appearance',Icons.palette_outlined,[
        const Text('Accent colour'),
        const SizedBox(height:10),
        Wrap(spacing:12,runSpacing:10,children:List.generate(colors.length,(i)=>InkWell(
          onTap:(){setState(()=>accent=i);save('setting_accent',i);},
          child:Container(width:38,height:38,decoration:BoxDecoration(color:colors[i],shape:BoxShape.circle,border:Border.all(color:accent==i?Theme.of(context).colorScheme.onSurface:Colors.transparent,width:3)),
            child:accent==i?const Icon(Icons.check,color:Colors.white):null)))),
        const SizedBox(height:8),
        toggle('Ambient glow','Show soft colour behind the glass surfaces',glow,'setting_glow',(v)=>glow=v),
        toggle('Edge-to-edge layout','Use the full screen height',edgeToEdge,'setting_edge',(v)=>edgeToEdge=v),
      ]),
      section('Glass effects',Icons.blur_on_rounded,[
        slider('Background blur',blur,0,36,'setting_blur',(v)=>blur=v),
        slider('Glass opacity',glass,0.2,1,'setting_glass',(v)=>glass=v),
        slider('Corner roundness',roundness,8,36,'setting_roundness',(v)=>roundness=v),
      ]),
      section('Player',Icons.graphic_eq_rounded,[
        toggle('Compact mini-player','Reduce the floating player height',compact,'setting_compact',(v)=>compact=v),
        toggle('Show album artwork','Display artwork in the mini-player',artwork,'setting_artwork',(v)=>artwork=v),
      ]),
      section('Motion & feedback',Icons.animation_rounded,[
        toggle('Animations','Enable motion throughout the interface',animated,'setting_animated',(v)=>animated=v),
        slider('Animation speed',animation,.5,1.5,'setting_animation',(v)=>animation=v,suffix:'×'),
        toggle('Haptic feedback','Vibrate on supported interactions',haptics,'setting_haptics',(v)=>haptics=v),
      ]),
      Center(child:TextButton.icon(onPressed:()async{await prefs!.clear();await _load();},icon:const Icon(Icons.restart_alt),label:const Text('Reset all customisations'))),
    ]));
}
