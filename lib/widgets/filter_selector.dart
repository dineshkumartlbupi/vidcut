import 'package:flutter/material.dart';
import '../models/filter_preset.dart';
import '../state/editor_provider.dart';
import '../core/theme.dart';

class FilterSelectorSheet extends StatelessWidget {
  final EditorProvider provider;

  const FilterSelectorSheet({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final clip = provider.selectedClip;
    final activeFilterId = clip?.filterId ?? 'none';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      color: AppTheme.surfaceElevated,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_fix_high, size: 18, color: AppTheme.cyan),
                    SizedBox(width: 8),
                    Text(
                      'Cinematic Filters & LUTs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.white70),
                  onPressed: () => provider.setActiveTool('none'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 105,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: FilterPreset.all.length,
              itemBuilder: (context, index) {
                final filter = FilterPreset.all[index];
                final isSelected = filter.id == activeFilterId;

                return GestureDetector(
                  onTap: () {
                    provider.setClipFilter(provider.selectedClipIndex, filter.id);
                  },
                  child: Container(
                    width: 78,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: filter.previewColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected ? Colors.white : Colors.transparent,
                              width: isSelected ? 3 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: filter.previewColor.withOpacity(0.6),
                                      blurRadius: 10,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: isSelected
                                ? const Icon(Icons.check_circle, color: Colors.white, size: 24)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          filter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
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
