import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../state/editor_provider.dart';
import '../core/theme.dart';

class CanvasRatioSheet extends StatelessWidget {
  final EditorProvider provider;

  const CanvasRatioSheet({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final currentRatio = provider.currentProject?.aspectRatio ?? AspectRatioPreset.ratio9_16;

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
                  Icon(Icons.aspect_ratio_rounded, size: 20, color: AppTheme.cyan),
                  SizedBox(width: 8),
                  Text(
                    'Canvas & Aspect Ratio',
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
          const SizedBox(height: 12),
          SizedBox(
            height: 95,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AspectRatioPreset.values.length,
              itemBuilder: (context, index) {
                final preset = AspectRatioPreset.values[index];
                final isSelected = preset == currentRatio;

                return GestureDetector(
                  onTap: () {
                    provider.setAspectRatio(preset);
                  },
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.2) : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.stroke,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(preset.icon, size: 26, color: isSelected ? AppTheme.primaryLight : Colors.white70),
                        const SizedBox(height: 6),
                        Text(
                          preset.name,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          preset.subtitle.split(' ').first,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 9, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
