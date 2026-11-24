import 'package:flutter/material.dart';
import '../state/editor_provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';

class TimelineView extends StatefulWidget {
  final EditorProvider provider;
  final VoidCallback onAddClip;

  const TimelineView({
    super.key,
    required this.provider,
    required this.onAddClip,
  });

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  double _pixelsPerSecond = 35.0; // Zoom level

  @override
  Widget build(BuildContext context) {
    final project = widget.provider.currentProject;
    if (project == null) return const SizedBox.shrink();

    final totalSeconds = (project.totalDurationMs / 1000).clamp(1.0, 600.0);
    final timelineWidth = (totalSeconds * _pixelsPerSecond) + 300.0;

    return Container(
      height: 230,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(
          top: BorderSide(color: AppTheme.stroke, width: 1.5),
        ),
      ),
      child: Column(
        children: [
          // 1. Timeline Quick Tools Bar (Split, Delete, Add, Zoom)
          Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: AppTheme.surfaceElevated,
              border: Border(bottom: BorderSide(color: AppTheme.stroke, width: 1)),
            ),
            child: Row(
              children: [
                // Current Playhead Time display
                Text(
                  _formatTimeDisplay(widget.provider.currentTimeMs),
                  style: const TextStyle(
                    color: AppTheme.cyan,
                    fontSize: 13,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/ ${project.formattedDuration}',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const Spacer(),

                // Split at Playhead button
                IconButton(
                  icon: const Icon(Icons.call_split_rounded, size: 18, color: Colors.white),
                  tooltip: 'Split Clip at Playhead',
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    widget.provider.splitClipAtPlayhead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Clip split into two segments'),
                        duration: Duration(milliseconds: 1200),
                        backgroundColor: AppTheme.primary,
                      ),
                    );
                  },
                ),

                // Delete selected clip
                if (project.clips.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, size: 18, color: AppTheme.redPlayhead),
                    tooltip: 'Delete Selected Clip',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {
                      widget.provider.removeClip(widget.provider.selectedClipIndex);
                    },
                  ),

                // Zoom Out
                IconButton(
                  icon: const Icon(Icons.remove, size: 16, color: Colors.white70),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() {
                      _pixelsPerSecond = (_pixelsPerSecond - 8.0).clamp(18.0, 70.0);
                    });
                  },
                ),

                // Zoom In
                IconButton(
                  icon: const Icon(Icons.add, size: 16, color: Colors.white70),
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() {
                      _pixelsPerSecond = (_pixelsPerSecond + 8.0).clamp(18.0, 70.0);
                    });
                  },
                ),

                const SizedBox(width: 4),

                // Add Clip button
                InkWell(
                  onTap: widget.onAddClip,
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.primary, width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: AppTheme.primaryLight),
                        SizedBox(width: 4),
                        Text(
                          'Add Clip',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Scrollable Multi-Track Timeline with Playhead
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: timelineWidth,
                child: Stack(
                  children: [
                    // A. Time Ruler Track
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: 24,
                      child: _buildTimeRuler(totalSeconds),
                    ),

                    // B. Main Video Track
                    Positioned(
                      top: 26,
                      left: 10,
                      right: 0,
                      height: 78,
                      child: _buildVideoTrack(project),
                    ),

                    // C. Audio Track
                    Positioned(
                      top: 110,
                      left: 10,
                      right: 0,
                      height: 38,
                      child: _buildAudioTrack(project),
                    ),

                    // D. Text & Overlay Track
                    Positioned(
                      top: 154,
                      left: 10,
                      right: 0,
                      height: 24,
                      child: _buildOverlayTrack(project),
                    ),

                    // E. Playhead Needle (Draggable across the entire timeline)
                    _buildPlayheadNeedle(project.totalDurationMs),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRuler(double totalSec) {
    final int stepSec = _pixelsPerSecond < 30 ? 2 : 1;
    final int count = (totalSec / stepSec).ceil() + 2;

    return Row(
      children: List.generate(count, (index) {
        final sec = index * stepSec;
        return Container(
          width: _pixelsPerSecond * stepSec,
          padding: const EdgeInsets.only(left: 4, top: 4),
          decoration: const BoxDecoration(
            border: Border(
              left: BorderSide(color: Colors.white24, width: 1),
            ),
          ),
          child: Text(
            '${sec}s',
            style: const TextStyle(
              color: AppTheme.textMuted,
              fontSize: 9,
              fontFamily: 'monospace',
            ),
          ),
        );
      }),
    );
  }

  Widget _buildVideoTrack(dynamic project) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < project.clips.length; i++) ...[
          _buildClipBlock(i, project.clips[i]),
          if (i < project.clips.length - 1) _buildTransitionBadge(i, project.clips[i]),
        ],
      ],
    );
  }

  Widget _buildClipBlock(int index, dynamic clip) {
    final isSelected = widget.provider.selectedClipIndex == index;
    final width = ((clip.effectiveDurationMs / 1000) * _pixelsPerSecond).clamp(55.0, 1200.0);

    return GestureDetector(
      onTap: () => widget.provider.selectClip(index),
      child: Container(
        width: width,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surfaceCard : AppTheme.surfaceElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.stroke,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.3),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Thumbnail Filmstrip pattern background
            Positioned.fill(
              child: Opacity(
                opacity: 0.25,
                child: Row(
                  children: List.generate(
                    (width / 30).ceil(),
                    (_) => Container(
                      width: 28,
                      margin: const EdgeInsets.only(right: 2),
                      color: Colors.white12,
                      child: const Center(
                        child: Icon(Icons.movie_outlined, size: 14, color: Colors.white30),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Left yellow trim handle
            if (isSelected)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 14,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.amberHandle,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.chevron_left, size: 14, color: Colors.black),
                  ),
                ),
              ),

            // Right yellow trim handle
            if (isSelected)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 14,
                child: Container(
                  decoration: const BoxDecoration(
                    color: AppTheme.amberHandle,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.chevron_right, size: 14, color: Colors.black),
                  ),
                ),
              ),

            // Clip details overlay
            Positioned(
              left: isSelected ? 18 : 8,
              top: 6,
              right: isSelected ? 18 : 8,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    clip.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${(clip.effectiveDurationMs / 1000).toStringAsFixed(1)}s',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.cyan,
                          ),
                        ),
                      ),
                      if (clip.speed != 1.0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${clip.speed}x',
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransitionBadge(int index, dynamic clip) {
    final hasTransition = clip.transition != VideoTransitionType.none;
    return GestureDetector(
      onTap: () {
        widget.provider.selectClip(index);
        widget.provider.setActiveTool('transition');
      },
      child: Container(
        width: 22,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: hasTransition ? AppTheme.primary : AppTheme.surfaceCard,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24, width: 1),
        ),
        child: Icon(
          hasTransition ? clip.transition.icon : Icons.hourglass_empty,
          size: 11,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAudioTrack(dynamic project) {
    if (project.audioTracks.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white12, style: BorderStyle.solid),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.music_note_outlined, size: 14, color: AppTheme.textMuted),
              SizedBox(width: 6),
              Text(
                'No audio added • Tap Audio tool below to add music or SFX',
                style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
              ),
            ],
          ),
        ),
      );
    }

    final track = project.audioTracks.first;
    final width = ((track.durationMs / 1000) * _pixelsPerSecond).clamp(100.0, 1800.0);

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.cyan.withOpacity(0.18),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.cyan.withOpacity(0.5), width: 1),
      ),
      child: Row(
        children: [
          const Icon(Icons.music_note, size: 14, color: AppTheme.cyan),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '${track.title} • ${track.artist}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black45,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${(track.volume * 100).toInt()}%',
              style: const TextStyle(fontSize: 9, color: AppTheme.cyan),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlayTrack(dynamic project) {
    return Row(
      children: [
        for (final text in project.textLayers)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.35),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.primary, width: 0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.title, size: 10, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  text.text,
                  maxLines: 1,
                  style: const TextStyle(fontSize: 9, color: Colors.white),
                ),
              ],
            ),
          ),
        for (final sticker in project.stickerLayers)
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.pinkNeon.withOpacity(0.35),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: AppTheme.pinkNeon, width: 0.8),
            ),
            child: Text(
              sticker.content,
              style: const TextStyle(fontSize: 9, color: Colors.white),
            ),
          ),
      ],
    );
  }

  Widget _buildPlayheadNeedle(int totalMs) {
    final currentSec = widget.provider.currentTimeMs / 1000;
    final xPosition = 10.0 + (currentSec * _pixelsPerSecond);

    return Positioned(
      left: xPosition - 8,
      top: 0,
      bottom: 0,
      width: 16,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (details) {
          final newX = xPosition + details.delta.dx;
          final newSec = ((newX - 10.0) / _pixelsPerSecond).clamp(0.0, totalMs / 1000);
          widget.provider.seekTo((newSec * 1000).toInt());
        },
        child: Column(
          children: [
            // Playhead triangle handle
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppTheme.redPlayhead,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.redPlayhead,
                    blurRadius: 6,
                  ),
                ],
              ),
              child: const Center(
                child: CircleAvatar(radius: 2, backgroundColor: Colors.white),
              ),
            ),
            // Vertical needle line
            Expanded(
              child: Container(
                width: 2,
                color: AppTheme.redPlayhead,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeDisplay(int ms) {
    final totalSec = ms / 1000;
    final mins = (totalSec ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSec % 60).toStringAsFixed(1).padLeft(4, '0');
    return '$mins:$secs';
  }
}
