/// World Credit Badge SDK Example App
/// 
/// Demonstrates all badge types and theming options
import 'package:flutter/material.dart';
import 'package:worldcredit_badge/worldcredit_badge.dart';

void main() {
  runApp(const WorldCreditBadgeExampleApp());
}

class WorldCreditBadgeExampleApp extends StatelessWidget {
  const WorldCreditBadgeExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Credit Badge SDK Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const BadgeDemoScreen(),
    );
  }
}

class BadgeDemoScreen extends StatefulWidget {
  const BadgeDemoScreen({super.key});

  @override
  State<BadgeDemoScreen> createState() => _BadgeDemoScreenState();
}

class _BadgeDemoScreenState extends State<BadgeDemoScreen> {
  String _selectedHandle = 'demo';
  WCBadgeSize _selectedSize = WCBadgeSize.md;
  bool _isDarkMode = false;
  
  final List<String> _demoHandles = [
    'demo',
    'sarahk',
    'alex_dev',
    'maria_designer',
    'crypto_guru',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? WCBadgeTheme.dark : WCBadgeTheme.light;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('World Credit Badge SDK'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Controls
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Demo Controls',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    
                    // Handle selector
                    Row(
                      children: [
                        const Text('Handle: '),
                        const SizedBox(width: 8),
                        DropdownButton<String>(
                          value: _selectedHandle,
                          onChanged: (value) {
                            setState(() {
                              _selectedHandle = value!;
                            });
                          },
                          items: _demoHandles.map((handle) {
                            return DropdownMenuItem(
                              value: handle,
                              child: Text('@$handle'),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Size selector
                    Row(
                      children: [
                        const Text('Size: '),
                        const SizedBox(width: 8),
                        DropdownButton<WCBadgeSize>(
                          value: _selectedSize,
                          onChanged: (value) {
                            setState(() {
                              _selectedSize = value!;
                            });
                          },
                          items: WCBadgeSize.values.map((size) {
                            return DropdownMenuItem(
                              value: size,
                              child: Text(size.name.toUpperCase()),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Inline Badge Demo
            _buildSection(
              title: 'WC Inline Badge',
              description: 'Tiny pill badge that sits inline next to text',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  border: Border.all(color: theme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      'User: Sarah K. ',
                      style: TextStyle(
                        fontSize: _selectedSize.fontSize,
                        color: theme.textColor,
                      ),
                    ),
                    WCInlineBadge(
                      handle: _selectedHandle,
                      theme: theme,
                      size: _selectedSize,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Pill Badge Demo
            _buildSection(
              title: 'WC Pill Badge',
              description: 'Compact badge with logo, score, and tier tag',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  border: Border.all(color: theme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    WCPillBadge(
                      handle: _selectedHandle,
                      theme: theme,
                      size: _selectedSize,
                    ),
                    const SizedBox(height: 12),
                    WCPillBadge(
                      handle: _selectedHandle,
                      theme: theme,
                      size: _selectedSize,
                      showDisplayName: true,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Shield Badge Demo
            _buildSection(
              title: 'WC Shield Badge',
              description: 'Minimal badge with logo and colored verification dot',
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  border: Border.all(color: theme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    WCShieldBadge(
                      handle: _selectedHandle,
                      theme: theme,
                      size: _selectedSize,
                      dotPosition: ShieldDotPosition.bottomRight,
                    ),
                    const SizedBox(width: 16),
                    WCShieldBadge(
                      handle: _selectedHandle,
                      theme: theme,
                      size: _selectedSize,
                      dotPosition: ShieldDotPosition.topRight,
                    ),
                    const SizedBox(width: 16),
                    WCShieldBadge(
                      handle: _selectedHandle,
                      theme: theme,
                      size: _selectedSize,
                      dotPosition: ShieldDotPosition.topLeft,
                    ),
                    const SizedBox(width: 16),
                    WCShieldBadge(
                      handle: _selectedHandle,
                      theme: theme,
                      size: _selectedSize,
                      dotPosition: ShieldDotPosition.bottomLeft,
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Card Badge Demo
            _buildSection(
              title: 'WC Card Badge',
              description: 'Rich card with detailed badge information',
              child: Container(
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  border: Border.all(color: theme.borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      WCCardBadge(
                        handle: _selectedHandle,
                        theme: theme,
                        size: _selectedSize,
                        maxWidth: 300,
                      ),
                      const SizedBox(height: 16),
                      WCCardBadge(
                        handle: _selectedHandle,
                        theme: theme,
                        size: _selectedSize,
                        maxWidth: 300,
                        showLinkedNetworks: true,
                        showCategories: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Usage Code Demo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Usage Examples',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCodeExample('// Simple usage'),
                          _buildCodeExample("WCInlineBadge(handle: '$_selectedHandle')"),
                          const SizedBox(height: 8),
                          _buildCodeExample('// With theming'),
                          _buildCodeExample(
                            "WCPillBadge(\n"
                            "  handle: '$_selectedHandle',\n"
                            "  theme: WCBadgeTheme.${_isDarkMode ? 'dark' : 'light'},\n"
                            "  size: WCBadgeSize.${_selectedSize.name},\n"
                            ")"
                          ),
                          const SizedBox(height: 8),
                          _buildCodeExample('// Programmatic fetch'),
                          _buildCodeExample("final data = await WorldCreditBadge.fetch('$_selectedHandle');"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Cache Statistics
            FutureBuilder(
              future: Future.value(WorldCreditBadge.getCacheStats()),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();
                
                final stats = snapshot.data as Map<String, dynamic>;
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Cache Statistics',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            TextButton(
                              onPressed: () {
                                WorldCreditBadge.clearCache();
                                setState(() {});
                              },
                              child: const Text('Clear Cache'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Total Entries: ${stats['totalEntries']}'),
                        Text('Fresh Entries: ${stats['freshEntries']}'),
                        Text('Expired Entries: ${stats['expiredEntries']}'),
                        Text('Pending Requests: ${stats['pendingRequests']}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildCodeExample(String code) {
    return Text(
      code,
      style: const TextStyle(
        fontFamily: 'Courier',
        fontSize: 12,
        color: Colors.black87,
      ),
    );
  }
}