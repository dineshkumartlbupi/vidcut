import 'package:flutter/material.dart';
import '../core/constants.dart';
import '../state/editor_provider.dart';
import '../core/theme.dart';

class TransitionSelectorSheet extends StatelessWidget {
  final EditorProvider provider;

  const TransitionSelectorSheet({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final selectedClip = provider.selectedClip;
    final currentTransition = selectedClip?.transition ?? VideoTransitionType.none;

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
                    'Transitions & Cut FX',
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
          const SizedBox(height: 6),
          const Text(
            'Seamlessly blend spliced clips together with cinematic transitions:',
            style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 14),

          // Horizontal Transition Cards
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: VideoTransitionType.values.length,
              itemBuilder: (context, index) {
                final transition = VideoTransitionType.values[index];
                final isSelected = transition == currentTransition;

                return GestureDetector(
                  onTap: () {
                    provider.setTransition(provider.selectedClipIndex, transition);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(transition.icon, color: AppTheme.cyan, size: 16),
                            const SizedBox(width: 8),
                            Text('Applied "${transition.name}" transition'),
                          ],
                        ),
                        duration: const Duration(milliseconds: 1000),
                        backgroundColor: AppTheme.surfaceCard,
                      ),
                    );
                  },
                  child: Container(
                    width: 82,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary.withOpacity(0.25) : AppTheme.surfaceCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : AppTheme.stroke,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          transition.icon,
                          size: 26,
                          color: isSelected ? AppTheme.primaryLight : Colors.white70,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          transition.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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

          const SizedBox(height: 14),

          // Action: Apply To All Clips
          SizedBox(
            width: double.infinity,
            height: 38,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.done_all_rounded, size: 16),
              label: const Text('Apply Transition to All Clips (1-Tap)', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.cyan,
                side: const BorderSide(color: AppTheme.cyan),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                provider.setTransitionToAll(currentTransition);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Applied "${currentTransition.name}" to all clips!'),
                    backgroundColor: AppTheme.primary,
                    duration: const Duration(milliseconds: 1200),
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
