import 'package:flutter/material.dart';
import '../state/editor_provider.dart';
import '../core/theme.dart';

class SpeedSelectorSheet extends StatelessWidget {
  final EditorProvider provider;

  const SpeedSelectorSheet({super.key, required this.provider});

  static const List<double> speedOptions = [
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

  @override
  Widget build(BuildContext context) {
    final clip = provider.selectedClip;
    final currentSpeed = clip?.speed ?? 1.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: AppTheme.surfaceElevated,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.speed, size: 20, color: AppTheme.amberHandle),
                  SizedBox(width: 8),
                  Text(
                    'Speed & Motion Control',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.white70),
                onPressed: () => provider.setActiveTool('none'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Slow down for dramatic slow-mo or speed up for timelapse/hyperlapse:',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: speedOptions.map((speed) {
              final isSelected = (currentSpeed - speed).abs() < 0.05;
              String label = '${speed}x';
              if (speed == 0.25) label = '0.25x (Slow-Mo)';
              if (speed == 1.0) label = '1.0x (Normal)';
              if (speed == 4.0) label = '4.0x (Fast)';

              return ChoiceChip(
                label: Text(label),
                selected: isSelected,
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.surfaceCard,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
                onSelected: (_) {
                  provider.updateClipSpeed(provider.selectedClipIndex, speed);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
