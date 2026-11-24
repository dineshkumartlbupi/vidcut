import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../state/editor_provider.dart';
import '../models/filter_preset.dart';
import '../core/theme.dart';

class VideoPlayerViewport extends StatelessWidget {
  final EditorProvider provider;

  const VideoPlayerViewport({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final project = provider.currentProject;
    if (project == null) {
      return const Center(child: Text('No project loaded'));
    }

    final clip = provider.selectedClip;
    final ratio = project.aspectRatio.ratio;

    // Resolve color filter matrix
    final filterId = clip?.filterId ?? 'none';
    final filter = FilterPreset.all.firstWhere(
      (f) => f.id == filterId,
      orElse: () => FilterPreset.none,
    );

    return Center(
      child: AspectRatio(
        aspectRatio: ratio,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.stroke, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Video or Fallback Thumbnail Canvas with Live Filter Matrix
              ColorFiltered(
                colorFilter: ColorFilter.matrix(filter.matrix),
                child: _buildVideoContent(clip),
              ),

              // 2. Active Text Layers
              ...project.textLayers.map((textLayer) {
                // Check if text layer is active at current time
                final isActive = provider.currentTimeMs >= textLayer.startOnTimelineMs &&
                    provider.currentTimeMs <= (textLayer.startOnTimelineMs + textLayer.durationMs);

                if (!isActive) return const SizedBox.shrink();

                return Positioned(
                  left: (textLayer.xPercent * 300).clamp(20, 240),
                  top: (textLayer.yPercent * 450).clamp(40, 400),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      textLayer.xPercent = (textLayer.xPercent + details.delta.dx / 300).clamp(0.1, 0.9);
                      textLayer.yPercent = (textLayer.yPercent + details.delta.dy / 450).clamp(0.1, 0.9);
                      provider.saveCurrentProject();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: textLayer.hasBackground ? textLayer.backgroundColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white24, width: 1),
                      ),
                      child: Text(
                        textLayer.text,
                        style: TextStyle(
                          color: textLayer.color,
                          fontSize: textLayer.fontSize * 0.7,
                          fontWeight: textLayer.isBold ? FontWeight.bold : FontWeight.normal,
                          fontStyle: textLayer.isItalic ? FontStyle.italic : FontStyle.normal,
                          shadows: const [
                            Shadow(color: Colors.black, blurRadius: 4, offset: Offset(1, 1)),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // 3. Active Sticker Layers
              ...project.stickerLayers.map((sticker) {
                final isActive = provider.currentTimeMs >= sticker.startOnTimelineMs &&
                    provider.currentTimeMs <= (sticker.startOnTimelineMs + sticker.durationMs);

                if (!isActive) return const SizedBox.shrink();

                return Positioned(
                  left: (sticker.xPercent * 300).clamp(20, 240),
                  top: (sticker.yPercent * 450).clamp(40, 400),
                  child: GestureDetector(
                    onPanUpdate: (details) {
                      sticker.xPercent = (sticker.xPercent + details.delta.dx / 300).clamp(0.1, 0.9);
                      sticker.yPercent = (sticker.yPercent + details.delta.dy / 450).clamp(0.1, 0.9);
                      provider.saveCurrentProject();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.primary, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Text(
                        sticker.content,
                        style: TextStyle(
                          fontSize: 16 * sticker.scale,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                );
              }),

              // 4. Center Play/Pause Touch Overlay
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: provider.togglePlay,
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: provider.isPlaying ? 0.0 : 1.0,
                      child: Center(
                        child: Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white30, width: 1.5),
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // 5. Watermark Badge / Quality Indicator
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.movie_creation_outlined, size: 12, color: AppTheme.cyan),
                      const SizedBox(width: 4),
                      Text(
                        project.aspectRatio.name,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 6. Timecode Pill
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatTimecode(provider.currentTimeMs, project.totalDurationMs),
                    style: const TextStyle(
                      fontSize: 11,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoContent(dynamic clip) {
    if (provider.videoController != null && provider.videoController!.value.isInitialized) {
      return Transform.rotate(
        angle: (clip?.rotationDegrees ?? 0) * (3.1415926535 / 180),
        child: Transform.flip(
          flipX: clip?.isFlippedHorizontally ?? false,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: provider.videoController!.value.size.width,
              height: provider.videoController!.value.size.height,
              child: VideoPlayer(provider.videoController!),
            ),
          ),
        ),
      );
    }

    if (clip != null && clip.thumbnailUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: clip.thumbnailUrl,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          color: AppTheme.surfaceCard,
          child: const Center(
            child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => Container(
          color: AppTheme.surfaceCard,
          child: const Center(child: Icon(Icons.videocam_outlined, color: Colors.white38, size: 48)),
        ),
      );
    }

    return Container(
      color: AppTheme.surfaceCard,
      child: const Center(child: Icon(Icons.movie_outlined, color: Colors.white24, size: 48)),
    );
  }

  String _formatTimecode(int currentMs, int totalMs) {
    final curSec = (currentMs / 1000).toStringAsFixed(1);
    final totSec = (totalMs / 1000).toStringAsFixed(1);
    return '${curSec}s / ${totSec}s';
  }
}
