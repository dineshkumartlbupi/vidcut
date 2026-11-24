import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

import '../state/editor_provider.dart';
import '../models/video_clip.dart';
import '../models/sticker_layer.dart';
import '../core/theme.dart';
import '../core/sample_assets.dart';
import '../widgets/video_player_viewport.dart';
import '../widgets/timeline_view.dart';
import '../widgets/filter_selector.dart';
import '../widgets/audio_picker_sheet.dart';
import '../widgets/speed_selector_sheet.dart';
import '../widgets/canvas_ratio_sheet.dart';
import '../widgets/text_editor_dialog.dart';
import 'media_picker_screen.dart';
import 'export_screen.dart';

class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editor')),
        body: const Center(child: Text('No project selected')),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            provider.pause();
            provider.saveCurrentProject();
            Navigator.pop(context);
          },
        ),
        title: GestureDetector(
          onTap: () => _showRenameDialog(context, provider),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  project.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.edit, size: 13, color: AppTheme.textMuted),
            ],
          ),
        ),
        actions: [
          // Beginner's Quick Tips button
          IconButton(
            icon: const Icon(Icons.lightbulb_outline, size: 20, color: AppTheme.cyan),
            tooltip: 'Quick Editing Tips',
            onPressed: () => _showTipsDialog(context),
          ),

          // Aspect Ratio pill
          GestureDetector(
            onTap: () => provider.setActiveTool('canvas'),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.stroke),
              ),
              child: Row(
                children: [
                  Icon(project.aspectRatio.icon, size: 13, color: AppTheme.cyan),
                  const SizedBox(width: 4),
                  Text(
                    project.aspectRatio.name,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Export primary button
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 8, bottom: 8),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.file_download_outlined, size: 17),
              label: const Text('Export', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                provider.pause();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ExportScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Video Player Viewport (Live canvas with color matrix, ratio, and overlays)
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: VideoPlayerViewport(provider: provider),
              ),
            ),

            // 2. Multi-Track Interactive Timeline
            TimelineView(
              provider: provider,
              onAddClip: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MediaPickerScreen(isAddingToCurrentProject: true),
                  ),
                );
              },
            ),

            // 3. Dynamic Tool Sheet or Bottom Toolbar
            _buildActiveToolDrawer(context, provider),

            // 4. Primary Bottom Editing Toolbar (CapCut-style horizontal scrolling categories)
            _buildEditingToolbar(context, provider),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveToolDrawer(BuildContext context, EditorProvider provider) {
    switch (provider.activeTool) {
      case 'filters':
        return FilterSelectorSheet(provider: provider);
      case 'music':
        return AudioPickerSheet(provider: provider);
      case 'speed':
        return SpeedSelectorSheet(provider: provider);
      case 'canvas':
        return CanvasRatioSheet(provider: provider);
      case 'stickers':
        return _buildStickersDrawer(context, provider);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildEditingToolbar(BuildContext context, EditorProvider provider) {
    final isMuted = provider.selectedClip?.isMuted ?? false;
    final tools = [
      {'id': 'split', 'name': 'Split', 'icon': Icons.call_split_rounded},
      {'id': 'canvas', 'name': 'Canvas', 'icon': Icons.aspect_ratio_rounded},
      {'id': 'speed', 'name': 'Speed', 'icon': Icons.speed_rounded},
      {'id': 'filters', 'name': 'Filters', 'icon': Icons.auto_fix_high_rounded},
      {'id': 'music', 'name': 'Audio', 'icon': Icons.audiotrack_rounded},
      {'id': 'text', 'name': 'Text', 'icon': Icons.title_rounded},
      {'id': 'stickers', 'name': 'Stickers', 'icon': Icons.layers_rounded},
      {'id': 'mute', 'name': isMuted ? 'Unmute' : 'Mute', 'icon': isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded},
      {'id': 'add_photo', 'name': '+ Photo', 'icon': Icons.add_photo_alternate_rounded},
      {'id': 'rotate', 'name': 'Rotate', 'icon': Icons.rotate_right_rounded},
      {'id': 'flip', 'name': 'Flip', 'icon': Icons.flip_rounded},
    ];

    return Container(
      height: 74,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.stroke)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        itemCount: tools.length,
        itemBuilder: (context, index) {
          final tool = tools[index];
          final toolId = tool['id'] as String;
          final isSelected = provider.activeTool == toolId;

          return GestureDetector(
            onTap: () {
              if (toolId == 'mute') {
                provider.toggleMuteClip();
                final muted = provider.selectedClip?.isMuted ?? false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        Icon(muted ? Icons.volume_off_rounded : Icons.volume_up_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(muted ? 'Original video audio muted (0% volume)' : 'Original video audio unmuted'),
                        ),
                      ],
                    ),
                    duration: const Duration(milliseconds: 1200),
                    backgroundColor: muted ? AppTheme.pinkNeon : AppTheme.primary,
                  ),
                );
              } else if (toolId == 'add_photo') {
                _pickAndAddPhoto(context, provider);
              } else if (toolId == 'split') {
                provider.splitClipAtPlayhead();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Split clip at playhead'),
                    duration: Duration(milliseconds: 1000),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              } else if (toolId == 'text') {
                showDialog(
                  context: context,
                  builder: (_) => TextEditorDialog(provider: provider),
                );
              } else if (toolId == 'rotate') {
                provider.rotateClip(provider.selectedClipIndex);
              } else if (toolId == 'flip') {
                provider.flipClip(provider.selectedClipIndex);
              } else {
                provider.setActiveTool(isSelected ? 'none' : toolId);
              }
            },
            child: Container(
              width: 62,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary.withOpacity(0.25) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? AppTheme.primary : Colors.transparent),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tool['icon'] as IconData,
                    size: 20,
                    color: (toolId == 'mute' && isMuted)
                        ? AppTheme.pinkNeon
                        : (isSelected ? AppTheme.primaryLight : Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tool['name'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: (toolId == 'mute' && isMuted)
                          ? AppTheme.pinkNeon
                          : (isSelected ? Colors.white : AppTheme.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStickersDrawer(BuildContext context, EditorProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
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
                    Icon(Icons.layers_rounded, size: 20, color: AppTheme.cyan),
                    SizedBox(width: 8),
                    Text(
                      'Stickers & Photo Overlays (PIP)',
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
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                // Add Photo Overlay Button (PIP)
                GestureDetector(
                  onTap: () => _pickAndAddStickerImage(context, provider),
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.pinkNeon.withOpacity(0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_photo_alternate_rounded, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          '+ Photo Overlay',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                // Creator Badges & Stickers
                ...SampleAssets.stickerBadges.map((badge) {
                  return GestureDetector(
                    onTap: () {
                      provider.addStickerLayer(
                        StickerLayer(
                          id: const Uuid().v4(),
                          content: badge,
                          xPercent: 0.5,
                          yPercent: 0.25,
                          startOnTimelineMs: provider.currentTimeMs,
                        ),
                      );
                      provider.setActiveTool('none');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceCard,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.stroke),
                      ),
                      child: Center(
                        child: Text(
                          badge,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndAddPhoto(BuildContext context, EditorProvider provider) async {
    try {
      final ImagePicker picker = ImagePicker();
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        final photoClips = images.map((img) {
          return VideoClip(
            id: const Uuid().v4(),
            path: img.path,
            isRemote: false,
            title: img.name.isNotEmpty ? img.name : 'Photo Slide',
            durationMs: 3500,
            volume: 0.0,
            isMuted: true,
          );
        }).toList();

        provider.addClips(photoClips);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Added ${photoClips.length} photo slide(s) to timeline'),
              backgroundColor: AppTheme.primary,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking photo: $e');
    }
  }

  Future<void> _pickAndAddStickerImage(BuildContext context, EditorProvider provider) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        provider.addStickerLayer(
          StickerLayer(
            id: const Uuid().v4(),
            content: image.path,
            xPercent: 0.5,
            yPercent: 0.4,
            scale: 1.5,
            startOnTimelineMs: provider.currentTimeMs,
            durationMs: 5000,
          ),
        );
        provider.setActiveTool('none');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo overlay added to video! Drag anywhere on screen.'),
              backgroundColor: AppTheme.primary,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking sticker image: $e');
    }
  }

  void _showRenameDialog(BuildContext context, EditorProvider provider) {
    final controller = TextEditingController(text: provider.currentProject?.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceElevated,
        title: const Text('Rename Project', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Project title...',
            hintStyle: TextStyle(color: AppTheme.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: AppTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.currentProject?.name = controller.text.trim();
                provider.saveCurrentProject();
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showTipsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb_rounded, color: AppTheme.cyan, size: 22),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Quick Editing Tips (Zero Effort!)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _tipRow('✂️ Cut & Split', 'Drag the red playhead to any frame, then tap "Split Here" on the timeline.'),
            const SizedBox(height: 10),
            _tipRow('◀ Drag to Trim ▶', 'Tap any clip in the timeline and drag the yellow handles on its edges to shorten it.'),
            const SizedBox(height: 10),
            _tipRow('🎵 Add Music & SFX', 'Tap the empty audio track or the "Audio" button to add trending beats or funny sounds.'),
            const SizedBox(height: 10),
            _tipRow('💬 Add Viral Text', 'Tap "Text" to add styled viral hooks and subtitles with 1 tap.'),
            const SizedBox(height: 10),
            _tipRow('↩️ Undo Any Mistake', 'Made a mistake? Tap the ↩️ button on the timeline to revert instantly!'),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Got it! Start Creating ✨'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipRow(String title, String desc) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: const EdgeInsets.only(top: 6, right: 10),
          decoration: const BoxDecoration(
            color: AppTheme.primaryLight,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 13, height: 1.4, color: AppTheme.textSecondary),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
