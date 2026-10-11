import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  runApp(const NeonHighwayApp());
}

class NeonHighwayApp extends StatelessWidget {
  const NeonHighwayApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Neon Highway',
        home: GameScreen(),
      );
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = WebViewController();
    if (kIsWeb) {
      // Chrome preview: the game is served as a Flutter asset and shown in an
      // iframe. The web WebView only supports loadRequest, so nothing else is set.
      _controller.loadRequest(Uri.base.resolve('assets/assets/game/index.html'));
    } else {
      _controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.black)
        // The game is fully offline; block any navigation away from bundled files.
        ..setNavigationDelegate(NavigationDelegate(
          onNavigationRequest: (req) =>
              req.url.startsWith('file:') || req.url.startsWith('about:')
                  ? NavigationDecision.navigate
                  : NavigationDecision.prevent,
        ))
        ..loadFlutterAsset('assets/game/index.html');
    }
  }

  // Pause the render loop when the app goes to the background (Android only).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (kIsWeb) return;
    final paused = state != AppLifecycleState.resumed;
    _controller.runJavaScript('window.__paused = $paused;');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(child: WebViewWidget(controller: _controller)),
      );
}
