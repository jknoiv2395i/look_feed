import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../providers/credit_provider.dart';
import '../../../core/utils/formatters.dart';

class InstagramTab extends StatefulWidget {
  const InstagramTab({super.key});

  @override
  State<InstagramTab> createState() => _InstagramTabState();
}

class _InstagramTabState extends State<InstagramTab> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  Future<void> _initWebView() async {
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://www.instagram.com'));

    setState(() {
      _controller = controller;
    });
  }

  @override
  Widget build(BuildContext context) {
    final CreditProvider creditProvider = context.watch<CreditProvider>();
    final bool hasCredits = creditProvider.totalCredits > 0;

    if (hasCredits) {
      creditProvider.startCountdown();
    }

    return Stack(
      children: <Widget>[
        if (_controller != null)
          WebViewWidget(controller: _controller!)
        else
          const Center(child: CircularProgressIndicator()),
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: const Color(0xFF13ec6a).withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.timer, color: const Color(0xFF13ec6a), size: 18),
                const SizedBox(width: 8),
                Text(
                  formatCredits(creditProvider.totalCredits),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!hasCredits)
          Container(
            color: Colors.black.withOpacity(0.85),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF13ec6a).withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Color(0xFF13ec6a),
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No credits left',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Complete exercises to earn more scroll time',
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to Exercise tab
                        DefaultTabController.of(context).animateTo(2);
                      },
                      icon: const Icon(Icons.fitness_center),
                      label: const Text('Go to Exercise'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF13ec6a),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
