import 'dart:ui';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/audio/audio_provider.dart';
import 'full_player_page.dart';

class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});
  @override Widget build(BuildContext context,WidgetRef ref){
    final handler=ref.watch(audioHandlerProvider);
    return StreamBuilder<MediaItem?>(stream:handler.mediaItem,builder:(context,snapshot){
      final item=snapshot.data;
      if(item==null)return const SizedBox.shrink();
      return FutureBuilder<SharedPreferences>(future:SharedPreferences.getInstance(),builder:(context,prefsSnap){
        final prefs=prefsSnap.data;
        final compact=prefs?.getBool('setting_compact')??false;
        final artwork=prefs?.getBool('setting_artwork')??true;
        return Padding(padding:const EdgeInsets.fromLTRB(12,6,12,8),child:ClipRRect(
          borderRadius:BorderRadius.circular(22),
          child:BackdropFilter(filter:ImageFilter.blur(sigmaX:22,sigmaY:22),child:Container(
            decoration:BoxDecoration(color:const Color(0xff382b33).withValues(alpha:.88),borderRadius:BorderRadius.circular(22),border:Border.all(color:Colors.white.withValues(alpha:.14))),
            child:Column(mainAxisSize:MainAxisSize.min,children:[ListTile(
              dense:compact,contentPadding:const EdgeInsets.symmetric(horizontal:12,vertical:2),
              leading:!artwork?const Icon(Icons.graphic_eq_rounded,size:32):item.artUri==null?const Icon(Icons.music_note):ClipRRect(borderRadius:BorderRadius.circular(10),child:Image.network(item.artUri.toString(),width:compact?42:50,height:compact?42:50,fit:BoxFit.cover,errorBuilder:(_,__,___)=>const Icon(Icons.music_note))),
              title:Text(item.title,maxLines:1,overflow:TextOverflow.ellipsis),
              subtitle:Text(item.artist??'Unknown artist',maxLines:1),
              trailing:StreamBuilder<PlaybackState>(stream:handler.playbackState,builder:(context,state)=>IconButton(icon:Icon(state.data?.playing==true?Icons.pause_rounded:Icons.play_arrow_rounded,size:30),onPressed:()=>state.data?.playing==true?handler.pause():handler.play())),
              onTap:()=>Navigator.of(context).push(MaterialPageRoute(builder:(_)=>FullPlayerPage(handler:handler))),
            ),
            StreamBuilder<Duration?>(stream:handler.player.durationStream,builder:(context,duration){final total=duration.data?.inMilliseconds??0;return StreamBuilder<Duration>(stream:handler.player.positionStream,builder:(context,position){final current=position.data?.inMilliseconds??0;return LinearProgressIndicator(minHeight:2,value:total>0?(current/total).clamp(0,1).toDouble():null,backgroundColor:Colors.white.withValues(alpha:.10));});}),
            ]),
          )),
        ));
      });
    });
  }
}
