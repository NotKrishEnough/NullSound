import 'package:flutter/material.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../../core/audio/null_audio_handler.dart';

class FullPlayerPage extends StatefulWidget {
  const FullPlayerPage({super.key,required this.handler});
  final NullAudioHandler handler;
  @override State<FullPlayerPage> createState()=>_FullPlayerPageState();
}
class _FullPlayerPageState extends State<FullPlayerPage>{
  bool seeking=false;
  Color _backgroundA=const Color(0xff171316);
  Color _backgroundB=const Color(0xff171316);
  String? _loadedArtUri;

  Future<void> _updateBackground(String? uri) async {
    if (uri==null || uri.isEmpty || uri==_loadedArtUri) return;
    _loadedArtUri=uri;
    try {
      final palette=await PaletteGenerator.fromImageProvider(
        NetworkImage(uri),
        maximumColorCount:16,
      );
      final colors=[
        palette.darkVibrantColor?.color,
        palette.darkMutedColor?.color,
        palette.dominantColor?.color,
        palette.vibrantColor?.color,
      ].whereType<Color>().toList();
      if (!mounted || colors.isEmpty || uri!=_loadedArtUri) return;
      final a=colors.first;
      final b=colors.length>1?colors[1]:a;
      setState((){
        _backgroundA=Color.lerp(a,Colors.black,.55) ?? const Color(0xff171316);
        _backgroundB=Color.lerp(b,Colors.black,.68) ?? const Color(0xff171316);
      });
    } catch (_) {
      // Keep the safe dark fallback when artwork colors cannot be resolved.
    }
  }
  double seekValue=0;
  @override void initState(){super.initState();SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);}
  @override void dispose(){SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);super.dispose();}
  String time(Duration d){final m=d.inMinutes.remainder(60).toString().padLeft(2,'0');final s=d.inSeconds.remainder(60).toString().padLeft(2,'0');return '${d.inHours>0?'${d.inHours}:':''}$m:$s';}
  @override Widget build(BuildContext context)=>Scaffold(
    backgroundColor:const Color(0xff171316),
    body:StreamBuilder<MediaItem?>(stream:widget.handler.mediaItem,builder:(context,itemSnap){
      final item=itemSnap.data;
      _updateBackground(item?.artUri?.toString());
      return Stack(children:[
        if(item?.artUri!=null) Positioned.fill(child:Image.network(item!.artUri.toString(),fit:BoxFit.cover,errorBuilder:(_,__,___)=>const SizedBox.shrink())),
        Positioned.fill(
          child:DecoratedBox(
            decoration:BoxDecoration(
              gradient:LinearGradient(
                begin:Alignment.topLeft,
                end:Alignment.bottomRight,
                colors:[
                  _backgroundA.withValues(alpha:.96),
                  Color.lerp(_backgroundA,_backgroundB,.5)!.withValues(alpha:.94),
                  _backgroundB.withValues(alpha:.98),
                ],
                stops:const [0,.52,1],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child:Container(color:Colors.black.withValues(alpha:.18)),
        ),
        SafeArea(top:false,bottom:false,child:Padding(padding:const EdgeInsets.fromLTRB(24,24,24,18),child:Column(children:[
          Row(children:[IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.keyboard_arrow_down_rounded,size:34)),const Spacer(),const Text('NOW PLAYING',style:TextStyle(letterSpacing:2,fontWeight:FontWeight.w600)),const Spacer(),IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.more_horiz))]),
          const Spacer(),
          AspectRatio(aspectRatio:1,child:ClipRRect(borderRadius:BorderRadius.circular(28),child:item?.artUri==null?Container(color:Colors.white10,child:const Icon(Icons.music_note,size:100)):Image.network(item!.artUri.toString(),fit:BoxFit.cover,errorBuilder:(_,__,___)=>Container(color:Colors.white10,child:const Icon(Icons.music_note,size:100))))),
          const SizedBox(height:32),
          Align(alignment:Alignment.centerLeft,child:Text(item?.title??'Nothing playing',maxLines:2,overflow:TextOverflow.ellipsis,style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.bold))),
          const SizedBox(height:6),
          Align(alignment:Alignment.centerLeft,child:Text(item?.artist??'',style:Theme.of(context).textTheme.titleMedium?.copyWith(color:Colors.white70))),
          const SizedBox(height:24),
          StreamBuilder<Duration?>(stream:widget.handler.player.durationStream,builder:(context,durationSnap){
            final duration=durationSnap.data??Duration.zero;
            return StreamBuilder<Duration>(stream:widget.handler.player.positionStream,builder:(context,posSnap){
              final position=posSnap.data??Duration.zero;
              final max=duration.inMilliseconds.toDouble().clamp(1,double.infinity).toDouble();
              final value=seeking?seekValue:position.inMilliseconds.toDouble().clamp(0,max).toDouble();
              return Column(children:[
                Slider(value:value.clamp(0,max).toDouble(),min:0,max:max,onChangeStart:(v){setState(() { seeking=true; seekValue=v; });},onChanged:(v)=>setState(()=>seekValue=v),onChangeEnd:(v){widget.handler.seek(Duration(milliseconds:v.round()));setState(()=>seeking=false);}),
                Row(children:[Text(time(position),style:Theme.of(context).textTheme.labelMedium),const Spacer(),Text(time(duration),style:Theme.of(context).textTheme.labelMedium)]),
              ]);
            });
          }),
          const SizedBox(height:18),
          StreamBuilder<PlaybackState>(stream:widget.handler.playbackState,builder:(context,state)=>Row(mainAxisAlignment:MainAxisAlignment.spaceEvenly,children:[
            IconButton(onPressed:widget.handler.skipToPrevious,icon:const Icon(Icons.skip_previous_rounded,size:42)),
            IconButton(onPressed:()=>widget.handler.seek(Duration.zero),icon:const Icon(Icons.replay_10_rounded,size:30)),
            IconButton(onPressed:()=>state.data?.playing==true?widget.handler.pause():widget.handler.play(),icon:Icon(state.data?.playing==true?Icons.pause_circle_filled_rounded:Icons.play_circle_fill_rounded,size:76)),
            IconButton(onPressed:()=>widget.handler.seek(widget.handler.player.position+const Duration(seconds:10)),icon:const Icon(Icons.forward_10_rounded,size:30)),
            IconButton(onPressed:widget.handler.skipToNext,icon:const Icon(Icons.skip_next_rounded,size:42)),
          ])),
          const SizedBox(height:16),
          const Spacer(),
        ]))),
      ]);
    }),
  );
}
