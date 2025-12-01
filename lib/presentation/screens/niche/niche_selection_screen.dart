import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/niche_provider.dart';
import '../../../data/services/native_service.dart';

class NicheSelectionScreen extends StatefulWidget {
  const NicheSelectionScreen({super.key});

  @override
  State<NicheSelectionScreen> createState() => _NicheSelectionScreenState();
}

class _NicheSelectionScreenState extends State<NicheSelectionScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NicheProvider>().fetchNiches();
      _checkConnectionStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkConnectionStatus();
    }
  }

  Future<void> _checkConnectionStatus() async {
    final isEnabled = await NativeService().isServiceEnabled();
    if (mounted) {
      setState(() {
        _isConnected = isEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a3a2a),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1a3a2a),
        elevation: 0,
        title: const Text(
          'Select Your Niches',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_isConnected) {
                 ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Already connected! Updating preferences...'),
                      backgroundColor: Color(0xFF00FF00),
                    ),
                  );
                  await context.read<NicheProvider>().saveNiches();
                  return;
              }
              
              try {
                await context.read<NicheProvider>().saveNiches();
                if (mounted) {
                  // Show dialog to guide user to enable service
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1a3a2a),
                      title: const Text('Connect to Instagram', style: TextStyle(color: Colors.white)),
                      content: const Text(
                        'To filter your feed, we need to connect to Instagram via the Feed Lock service.\n\n1. Tap "Connect Now"\n2. Look for "Downloaded Apps" or "Installed Services"\n3. Find "Feed Lock"\n4. Turn it ON\n\nOnce connected, your feed will automatically filter based on your selected niches.',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            Navigator.pop(context);
                            // Open accessibility settings directly
                            await NativeService().openAccessibilitySettings();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF00)),
                          child: const Text('Connect Now', style: TextStyle(color: Color(0xFF1a3a2a))),
                        ),
                      ],
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(
              _isConnected ? 'Connected' : 'Connect',
              style: TextStyle(
                color: _isConnected ? const Color(0xFF00FF00) : Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<NicheProvider>(
        builder: (context, nicheProvider, child) {
          if (nicheProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF00FF00)),
            );
          }

          if (nicheProvider.niches.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.category_outlined, size: 64, color: Colors.white54),
                  const SizedBox(height: 16),
                  const Text(
                    'No niches available yet.',
                    style: TextStyle(color: Colors.white54),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => nicheProvider.fetchNiches(),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Color(0xFF00FF00)),
                    ),
                  ),
                ],
              ),
            );
          }

          final filteredNiches = nicheProvider.niches.where((niche) {
            if (_searchQuery.isEmpty) return true;
            return niche['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              // Description
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'Choose topics to focus on. This will filter your feed and help our AI provide better summaries.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search for topics...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
              ),
              // Niche Chips
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ...filteredNiches.map((niche) {
                        final String name = niche['name'];
                        final String icon = niche['icon'] ?? 'category';
                        final bool isSelected = nicheProvider.selectedNiches.contains(name);
                        
                        return _buildNicheChip(
                          name: name,
                          icon: icon,
                          isSelected: isSelected,
                          onTap: () => nicheProvider.toggleNiche(name),
                        );
                      }).toList(),
                      // Add Custom Niche
                      _buildAddCustomChip(),
                    ],
                  ),
                ),
              ),
              // Bottom Save Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF1a3a2a),
                      const Color(0xFF1a3a2a).withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () async {
                         if (_isConnected) {
                             ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Preferences updated!'),
                                  backgroundColor: Color(0xFF00FF00),
                                ),
                              );
                              await context.read<NicheProvider>().saveNiches();
                              return;
                          }
                        try {
                          await context.read<NicheProvider>().saveNiches();
                          if (mounted) {
                            // Show dialog to guide user to enable service
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF1a3a2a),
                                title: const Text('Connect to Instagram', style: TextStyle(color: Colors.white)),
                                content: const Text(
                                  'To filter your feed, we need to connect to Instagram via the Feed Lock service.\n\n1. Tap "Connect Now"\n2. Look for "Downloaded Apps" or "Installed Services"\n3. Find "Feed Lock"\n4. Turn it ON\n\nOnce connected, your feed will automatically filter based on your selected niches.',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      Navigator.pop(context);
                                      // Open accessibility settings directly
                                      await NativeService().openAccessibilitySettings();
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF00)),
                                    child: const Text('Connect Now', style: TextStyle(color: Color(0xFF1a3a2a))),
                                  ),
                                ],
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isConnected ? Colors.white.withOpacity(0.1) : const Color(0xFF00FF00),
                        foregroundColor: _isConnected ? const Color(0xFF00FF00) : const Color(0xFF1a3a2a),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                          side: _isConnected ? const BorderSide(color: Color(0xFF00FF00)) : BorderSide.none,
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _isConnected ? 'Connected' : 'Connect to Instagram',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNicheChip({
    required String name,
    required String icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00FF00).withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: const Color(0xFF00FF00), width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(
                  Icons.check,
                  color: Color(0xFF00FF00),
                  size: 20,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  _getIconData(icon),
                  color: Colors.white.withOpacity(0.7),
                  size: 20,
                ),
              ),
            Text(
              name,
              style: TextStyle(
                color: isSelected ? const Color(0xFF00FF00) : Colors.white,
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddCustomChip() {
    return GestureDetector(
      onTap: () {
        // TODO: Implement add custom niche dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Custom niches coming soon!'),
            backgroundColor: Color(0xFF00FF00),
          ),
        );
      },
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.white.withOpacity(0.3),
            width: 1,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.add,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              'Add Custom',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'biotech':
        return Icons.science_outlined;
      case 'restaurant':
        return Icons.restaurant;
      case 'trending_up':
        return Icons.trending_up;
      case 'self_improvement':
        return Icons.self_improvement;
      case 'attach_money':
        return Icons.attach_money;
      case 'draw':
        return Icons.draw_outlined;
      case 'recycling':
        return Icons.recycling;
      case 'flight_takeoff':
        return Icons.flight_takeoff;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'code':
        return Icons.code;
      default:
        return Icons.category;
    }
  }
}
