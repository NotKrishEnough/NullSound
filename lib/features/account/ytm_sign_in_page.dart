import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/account/ytm_account_service.dart';

class YtmSignInPage extends StatefulWidget {
  const YtmSignInPage({super.key, required this.service});
  final YtmAccountService service;
  @override
  State<YtmSignInPage> createState() => _YtmSignInPageState();
}
class _YtmSignInPageState extends State<YtmSignInPage> {
  late final WebViewController controller;
  bool checking = false;
  bool loading = true;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setUserAgent('Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36')
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: _check,
        onPageFinished: (url) { if (mounted) setState(()=>loading=false); _check(url); },
      ))
      ..loadRequest(Uri.parse('https://accounts.google.com/ServiceLogin?service=youtube&continue=https://music.youtube.com/'));
  }
  Future<void> _check(String url) async {
    if (!url.startsWith('https://music.youtube.com') || checking) return;
    checking = true;
    if (mounted) setState(()=>loading=true);
    try {
      final cookies = await WebViewCookieManager().getCookies(domain: Uri.parse('https://music.youtube.com'));
      final header = cookies.map((c)=>'${c.name}=${c.value}').join('; ');
      final ok = await widget.service.saveAndVerify(header);
      if (!mounted) return;
      if (ok) { Navigator.pop(context,true); return; }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.service.lastError ?? 'Could not verify YouTube Music session. Please try again.')));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content:Text('Could not read the sign-in session on this WebView.')));
    } finally {
      checking=false;
      if (mounted) setState(()=>loading=false);
    }
  }
  @override
  Widget build(BuildContext context)=>Scaffold(
    appBar: AppBar(title:const Text('Sign in to YouTube Music')),
    body:Stack(children:[
      WebViewWidget(controller:controller),
      if(loading) const Align(alignment:Alignment.topCenter,child:LinearProgressIndicator()),
    ]),
  );
}
