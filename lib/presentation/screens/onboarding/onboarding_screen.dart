import 'package:flutter/material.dart';
import '../../../data/services/native_service.dart';
import '../../providers/niche_provider.dart';
import 'package:provider/provider.dart';
import '../niche/niche_selection_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isInstagramSelected = false;
  bool _isUsageGranted = false;
  bool _isAccessibilityGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(_LifecycleObserver(
      onResume: _checkPermissions,
    ));
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final usage = await NativeService().isUsageAccessGranted();
    final accessibility = await NativeService().isServiceEnabled();
    if (mounted) {
      setState(() {
        _isUsageGranted = usage;
        _isAccessibilityGranted = accessibility;
      });
    }
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark blue/slate background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Disable swipe
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  _buildAppSelectionPage(),
                  _buildUsagePermissionPage(),
                  _buildAccessibilityPermissionPage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Let's set up Feed Lock!",
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Select your most distracting apps",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "You can always change this later in settings.",
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 32),
          if (!_isInstagramSelected)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: const [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange),
                  SizedBox(width: 12),
                  Text(
                    "No apps configured",
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          _buildAppToggle(
            name: "Instagram",
            icon: Icons.camera_alt, // Placeholder for Instagram icon
            color: Colors.pink,
            isSelected: _isInstagramSelected,
            onChanged: (val) => setState(() => _isInstagramSelected = val),
          ),
          // Add more mock apps if needed to look like the screenshot
          _buildAppToggle(
            name: "YouTube",
            icon: Icons.play_arrow,
            color: Colors.red,
            isSelected: false,
            onChanged: (val) {}, // Mock
          ),
        ],
      ),
    );
  }

  Widget _buildAppToggle({
    required String name,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  "Daily average of 45 min", // Mock data
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
          Switch(
            value: isSelected,
            onChanged: onChanged,
            activeColor: const Color(0xFF00FF00),
            activeTrackColor: const Color(0xFF00FF00).withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildUsagePermissionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_rounded, size: 80, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            "Connect Feed Lock to Usage Data, Securely.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Find Feed Lock in the list and make sure it's switched on.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_clock, color: Colors.blue),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Feed Lock",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Allow",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isUsageGranted,
                  onChanged: (val) async {
                    await NativeService().openUsageAccessSettings();
                  },
                  activeColor: Colors.blue,
                ),
              ],
            ),
          ),
          if (_isUsageGranted)
             Padding(
               padding: const EdgeInsets.only(top: 20),
               child: const Text("Access Granted! ✅", style: TextStyle(color: Colors.green, fontSize: 16)),
             ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityPermissionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.accessibility_new_rounded, size: 80, color: Color(0xFF00FF00)),
          const SizedBox(height: 24),
          const Text(
            "Enable Feed Filtering",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "1. Tap 'Grant Access'\n2. Find 'Downloaded Apps' or 'Installed Services'\n3. Turn ON 'Feed Lock'",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 48),
           Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF00).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.filter_list, color: Color(0xFF00FF00)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Feed Lock Service",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Enable",
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isAccessibilityGranted,
                  onChanged: (val) async {
                    await NativeService().openAccessibilitySettings();
                  },
                  activeColor: const Color(0xFF00FF00),
                ),
              ],
            ),
          ),
           if (_isAccessibilityGranted)
             Padding(
               padding: const EdgeInsets.only(top: 20),
               child: const Text("Service Enabled! ✅", style: TextStyle(color: Colors.green, fontSize: 16)),
             ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: () {
            if (_currentPage == 0) {
              if (_isInstagramSelected) {
                _nextPage();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please select an app to continue")),
                );
              }
            } else if (_currentPage == 1) {
              if (_isUsageGranted) {
                _nextPage();
              } else {
                 // Optional: Allow skip? Or force? User said "Connect Pushscroll to Usage Data", implying force.
                 // For better UX, let's force but provide feedback.
                 NativeService().openUsageAccessSettings();
              }
            } else if (_currentPage == 2) {
              if (_isAccessibilityGranted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const NicheSelectionScreen()),
                );
              } else {
                NativeService().openAccessibilitySettings();
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FF00),
            foregroundColor: const Color(0xFF1a3a2a),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          child: Text(
            _getButtonText(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  String _getButtonText() {
    if (_currentPage == 0) return "Select Apps";
    if (_currentPage == 1) return _isUsageGranted ? "Next" : "Grant Usage Access";
    return _isAccessibilityGranted ? "Get Started" : "Grant Accessibility";
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResume;
  _LifecycleObserver({required this.onResume});

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      onResume();
    }
  }
}
