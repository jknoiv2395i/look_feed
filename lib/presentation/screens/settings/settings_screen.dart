import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/services/native_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/niche_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final NativeService _nativeService = NativeService();

  Future<void> _openAccessibilitySettings() async {
    await _nativeService.openAccessibilitySettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a3a2a),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Account Section
              _buildSectionHeader('ACCOUNT'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.person,
                title: 'Account Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account Settings')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildSettingsCard(
                icon: Icons.credit_card,
                title: 'Subscription Management',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Subscription Management')),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Filtering & Content Section
              _buildSectionHeader('FILTERING & CONTENT'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.local_offer,
                title: 'Keyword Management',
                onTap: () {
                  Navigator.pushNamed(context, '/keywords');
                },
              ),
              const SizedBox(height: 8),
              _buildSettingsCard(
                icon: Icons.tune,
                title: 'Filtering Preferences',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Filtering Preferences')),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Activity Section
              _buildSectionHeader('ACTIVITY'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.fitness_center,
                title: 'Exercise Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Exercise Settings')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildSettingsCard(
                icon: Icons.notifications,
                title: 'Notification Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notification Settings')),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Permissions Section
              _buildSectionHeader('PERMISSIONS'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.accessibility_new,
                title: 'Enable Feed Lock Service',
                onTap: () {
                   if (kIsWeb) {
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(
                         content: Text('This feature is only available on Android devices.'),
                         backgroundColor: Colors.orange,
                       ),
                     );
                     return;
                   }
                   _openAccessibilitySettings();
                },
              ),
              const SizedBox(height: 24),

              // General Section
              _buildSectionHeader('GENERAL'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.privacy_tip,
                title: 'Privacy Settings',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Privacy Settings')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildSettingsCard(
                icon: Icons.help,
                title: 'Help & Support',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Help & Support')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildSettingsCard(
                icon: Icons.info,
                title: 'About Feed Lock',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('About Feed Lock v1.0.0')),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Log Out Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    _showLogOutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.2),
                    foregroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Log Out',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 24),

              // Developer Section (Temporary)
              _buildSectionHeader('DEVELOPER'),
              const SizedBox(height: 12),
              _buildSettingsCard(
                icon: Icons.cloud_upload,
                title: 'Seed Database',
                onTap: () async {
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Seeding database...')),
                    );
                    await context.read<NicheProvider>().seedDatabase();
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Database seeded successfully!'),
                          backgroundColor: Color(0xFF00FF00),
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error seeding database: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF00FF00),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF00FF00).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF00FF00), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54, size: 24),
          ],
        ),
      ),
    );
  }

  void _showLogOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1a3a2a),
          title: const Text(
            'Log Out',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Are you sure you want to log out?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Color(0xFF00FF00)),
              ),
            ),
            TextButton(
              onPressed: () {
                final authProvider = context.read<AuthProvider>();
                authProvider.logout();
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/onboarding', (route) => false);
              },
              child: const Text('Log Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
