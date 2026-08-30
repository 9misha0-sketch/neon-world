import 'dart:async';

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NeonBetApp());
}

class NeonBetApp extends StatelessWidget {
  const NeonBetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NEON BET',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF070A12),
      ),
      home: const NeonBetHome(),
    );
  }
}

class NeonBetHome extends StatefulWidget {
  const NeonBetHome({super.key});

  @override
  State<NeonBetHome> createState() => _NeonBetHomeState();
}

class _NeonBetHomeState extends State<NeonBetHome> {
  static const _appUrl =
      'https://9misha0-sketch.github.io/neon-world/?app=android-v3';

  late final WebViewController _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF070A12))
      ..enableZoom(false)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _loading = true;
              _error = null;
            });
          },
          onPageFinished: (_) async {
            await _controller.runJavaScript('''
              document.documentElement.style.visibility='visible';
              document.documentElement.style.opacity='1';
              document.body.style.visibility='visible';
              document.body.style.opacity='1';
              document.body.style.display='block';
              window.scrollTo(0,0);
            ''');
            if (!mounted) return;
            setState(() => _loading = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return;
            if (!mounted) return;
            setState(() {
              _loading = false;
              _error = 'לא הצלחנו לטעון את NEON BET. בדוק חיבור לאינטרנט ולחץ נסה שוב.';
            });
          },
        ),
      );

    unawaited(_loadFresh());
  }

  Future<void> _loadFresh() async {
    try {
      await _controller.clearCache();
      await _controller.loadRequest(
        Uri.parse('$_appUrl&t=${DateTime.now().millisecondsSinceEpoch}'),
        headers: const {
          'Cache-Control': 'no-cache',
          'Pragma': 'no-cache',
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'אירעה שגיאה בפתיחת האפליקציה. לחץ נסה שוב.';
      });
    }
  }

  Future<bool> _handleBack() async {
    if (await _controller.canGoBack()) {
      await _controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (await _handleBack() && mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              WebViewWidget(controller: _controller),
              if (_loading)
                const ColoredBox(
                  color: Color(0xFF070A12),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'NEON BET',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                          ),
                        ),
                        SizedBox(height: 18),
                        CircularProgressIndicator(),
                      ],
                    ),
                  ),
                ),
              if (_error != null)
                ColoredBox(
                  color: const Color(0xFF070A12),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 54),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 17, height: 1.5),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _loadFresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text('נסה שוב'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
