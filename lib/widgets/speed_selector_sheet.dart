import 'package:flutter/material.dart';
import '../state/editor_provider.dart';
import '../core/theme.dart';

class SpeedSelectorSheet extends StatefulWidget {
  final EditorProvider provider;

  const SpeedSelectorSheet({super.key, required this.provider});

  @override
  State<SpeedSelectorSheet> createState() => _SpeedSelectorSheetState();
}

class _SpeedSelectorSheetState extends State<SpeedSelectorSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const List<double> standardSpeeds = [
    0.25,
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    2.0,
    3.0,
    4.0,
  ];

  static const List<Map<String, dynamic>> velocityCurves = [
    {
      'id': 'montage',
      'name': 'Montage',
      'speed': 1.5,
      'desc': 'Fast -> Slow-Mo -> Fast',
      'icon': Icons.trending_up,
      'badge': 'VIRAL',
    },
    {
      'id': 'hero',
      'name': 'Hero Climax',
      'speed': 0.25,
      'desc': 'Normal into dramatic slow drop',
      'icon': Icons.flash_on,
      'badge': 'ACTION',
    },
    {
      'id': 'bullet',
      'name': 'Bullet Time',
      'speed': 0.35,
      'desc': 'Smooth deceleration glide',
      'icon': Icons.slow_motion_video_rounded,
      'badge': 'CINEMA',
    },
    {
      'id': 'flash',
      'name': 'Flash Surge',
      'speed': 3.0,
      'desc': 'Ultra fast rush into 1x',
      'icon': Icons.electric_bolt_rounded,
      'badge': 'HYPER',
    },
    {
      'id': 'flow',
      'name': 'Smooth Flow',
      'speed': 1.25,
      'desc': 'Vlog pace & rhythmic beat',
      'icon': Icons.waves_rounded,
      'badge': 'VLOG',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clip = widget.provider.selectedClip;
    final currentSpeed = clip?.speed ?? 1.0;

    return Container(
      height: 290,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: AppTheme.surfaceElevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'PRO FREE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Speed Ramping & Velocity',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.white70),
                onPressed: () => widget.provider.setActiveTool('none'),
              ),
            ],
          ),
          const SizedBox(height: 6),

          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.amberHandle,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: const [
              Tab(text: 'Standard Speed'),
              Tab(text: 'Velocity Curves (Curves)'),
            ],
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Standard Speed
                Center(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: standardSpeeds.map((speed) {
                      final isSelected = (currentSpeed - speed).abs() < 0.05;
                      String label = '${speed}x';
                      if (speed == 0.25) label = '0.25x (Slow)';
                      if (speed == 1.0) label = '1.0x (Normal)';
                      if (speed == 4.0) label = '4.0x (Fast)';

                      return ChoiceChip(
                        label: Text(label),
                        selected: isSelected,
                        selectedColor: AppTheme.amberHandle,
                        backgroundColor: AppTheme.surfaceCard,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (_) {
                          widget.provider.updateClipSpeed(widget.provider.selectedClipIndex, speed);
                        },
                      );
                    }).toList(),
                  ),
                ),

                // Tab 2: Velocity Curve Ramping (Pro Free)
                ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  itemCount: velocityCurves.length,
                  itemBuilder: (context, index) {
                    final curve = velocityCurves[index];
                    final speed = curve['speed'] as double;
                    final isSelected = (currentSpeed - speed).abs() < 0.05;

                    return GestureDetector(
                      onTap: () {
                        widget.provider.updateClipSpeed(widget.provider.selectedClipIndex, speed);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Applied "${curve['name']}" velocity speed ramp!'),
                            duration: const Duration(milliseconds: 1000),
                            backgroundColor: AppTheme.surfaceCard,
                          ),
                        );
                      },
                      child: Container(
                        width: 130,
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.amberHandle.withOpacity(0.2) : AppTheme.surfaceCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppTheme.amberHandle : AppTheme.stroke,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(curve['icon'] as IconData, size: 20, color: AppTheme.amberHandle),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.amberHandle.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    curve['badge'] as String,
                                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.amberHandle),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              curve['name'] as String,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              curve['desc'] as String,
                              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
