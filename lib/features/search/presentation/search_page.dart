import 'package:flutter/material.dart';
class SearchPage extends StatefulWidget { const SearchPage({super.key}); @override State<SearchPage> createState()=>_SearchPageState(); }
class _SearchPageState extends State<SearchPage> {
 final controller=TextEditingController();
 @override void dispose(){controller.dispose();super.dispose();}
 @override Widget build(BuildContext context)=>Scaffold(appBar:AppBar(title:const Text('Search')),body:Padding(padding:const EdgeInsets.all(20),child:Column(children:[
 TextField(controller:controller,decoration:InputDecoration(hintText:'Songs, artists, albums…',prefixIcon:const Icon(Icons.search),filled:true,border:OutlineInputBorder(borderRadius:BorderRadius.circular(22),borderSide:BorderSide.none))),
 const SizedBox(height:24),const Text('Search the music you love')
 ])));
}
