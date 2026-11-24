import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

import '../state/editor_provider.dart';
import '../models/video_clip.dart';
import '../core/constants.dart';
import '../core/sample_assets.dart';
import '../core/theme.dart';
import 'editor_screen.dart';

class MediaPickerScreen extends StatefulWidget {
  final bool isAddingToCurrentProject;

  const MediaPickerScreen({super.key, this.isAddingToCurrentProject = false});

  @override
  State<MediaPickerScreen> createState() => _MediaPickerScreenState();
}

class _MediaPickerScreenState extends State<MediaPickerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedStockIds = {};
  AspectRatioPreset _selectedRatio = AspectRatioPreset.ratio9_16;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Pre-select first stock video for fast start
    if (SampleAssets.stockVideos.isNotEmpty) {
      _selectedStockIds.add(SampleAssets.stockVideos.first.id);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isAddingToCurrentProject ? 'Add Media to Timeline' : 'Select Video Clips'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: AppTheme.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.movie_creation_outlined, size: 20), text: 'Stock 4K Library'),
            Tab(icon: Icon(Icons.phone_android_rounded, size: 20), text: 'Phone Gallery'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Stock Library
          _buildStockTab(),

          // Tab 2: Gallery Picker
          _buildGalleryTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomActionBar(provider),
    );
  }

  Widget _buildStockTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (!widget.isAddingToCurrentProject) ...[
          const Text(
            'Choose Canvas Aspect Ratio:',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: AspectRatioPreset.values.map((preset) {
                final isSelected = preset == _selectedRatio;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text('${preset.name} (${preset.subtitle.split(' ').first})'),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    backgroundColor: AppTheme.surfaceCard,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _selectedRatio = preset),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
        ],

        const Text(
          'Select One or More Clips:',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: SampleAssets.stockVideos.length,
          itemBuilder: (context, index) {
            final sample = SampleAssets.stockVideos[index];
            final isSelected = _selectedStockIds.contains(sample.id);

            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedStockIds.remove(sample.id);
                  } else {
                    _selectedStockIds.add(sample.id);
                  }
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.stroke,
                    width: isSelected ? 3 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.35),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: sample.thumbnailUrl,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black54, Colors.transparent, Colors.black87],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    // Checkbox tag
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : Colors.black45,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSelected ? Icons.check : Icons.add,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Duration tag
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          sample.durationStr,
                          style: const TextStyle(fontSize: 10, color: AppTheme.cyan, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    // Title
                    Positioned(
                      bottom: 8,
                      left: 8,
                      right: 8,
                      child: Text(
                        sample.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGalleryTab() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primary, width: 2),
              ),
              child: const Icon(Icons.video_library_rounded, size: 40, color: AppTheme.primaryLight),
            ),
            const SizedBox(height: 20),
            const Text(
              'Import Videos From Device',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select any MP4, MOV, or camera video from your gallery to edit with full studio tools.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('Import Video from Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                onPressed: () => _pickGalleryVideo(context),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.photo_library_rounded, color: Colors.white),
                label: const Text(
                  '📸 Photos to Video Reel (Slideshow)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.pinkNeon,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  elevation: 4,
                  shadowColor: AppTheme.pinkNeon.withOpacity(0.5),
                ),
                onPressed: () => _pickGalleryPhotos(context),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.videocam_outlined),
                label: const Text('Record with Camera'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppTheme.stroke),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                onPressed: () => _recordCameraVideo(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar(EditorProvider provider) {
    final count = _selectedStockIds.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        border: Border(top: BorderSide(color: AppTheme.stroke)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: count == 0 ? null : () => _confirmStockImport(provider),
            child: Text(
              widget.isAddingToCurrentProject
                  ? 'Add $count ${count == 1 ? 'Clip' : 'Clips'} to Timeline'
                  : 'Start Project ($count ${count == 1 ? 'Clip' : 'Clips'}) ✨',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmStockImport(EditorProvider provider) async {
    final selectedClips = SampleAssets.stockVideos
        .where((s) => _selectedStockIds.contains(s.id))
        .map((s) => VideoClip.fromSample(s))
        .toList();

    if (widget.isAddingToCurrentProject) {
      provider.addClips(selectedClips);
      Navigator.pop(context);
    } else {
      await provider.createNewProject(
        name: selectedClips.first.title,
        ratio: _selectedRatio,
        initialClips: selectedClips,
      );
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const EditorScreen()),
        );
      }
    }
  }

  Future<void> _pickGalleryVideo(BuildContext context) async {
    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file != null && mounted) {
        final clip = VideoClip(
          id: const Uuid().v4(),
          path: file.path,
          isRemote: false,
          title: file.name.isNotEmpty ? file.name : 'Imported Clip',
          durationMs: 15000,
        );

        final provider = context.read<EditorProvider>();
        if (widget.isAddingToCurrentProject) {
          provider.addClips([clip]);
          Navigator.pop(context);
        } else {
          await provider.createNewProject(
            name: clip.title,
            ratio: _selectedRatio,
            initialClips: [clip],
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const EditorScreen()),
            );
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _pickGalleryPhotos(BuildContext context) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      if (images.isNotEmpty && mounted) {
        final photoClips = images.map((img) {
          return VideoClip(
            id: const Uuid().v4(),
            path: img.path,
            isRemote: false,
            title: img.name.isNotEmpty ? img.name : 'Photo Slide',
            durationMs: 3500, // 3.5 seconds per slide
            volume: 0.0,
            isMuted: true,
          );
        }).toList();

        final provider = context.read<EditorProvider>();
        if (widget.isAddingToCurrentProject) {
          provider.addClips(photoClips);
          Navigator.pop(context);
        } else {
          await provider.createNewProject(
            name: 'Photo Slideshow Reel',
            ratio: _selectedRatio,
            initialClips: photoClips,
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const EditorScreen()),
            );
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _recordCameraVideo(BuildContext context) async {
    try {
      final XFile? file = await _picker.pickVideo(source: ImageSource.camera);
      if (file != null && mounted) {
        final clip = VideoClip(
          id: const Uuid().v4(),
          path: file.path,
          isRemote: false,
          title: 'Recorded Clip',
          durationMs: 10000,
        );

        final provider = context.read<EditorProvider>();
        if (widget.isAddingToCurrentProject) {
          provider.addClips([clip]);
          Navigator.pop(context);
        } else {
          await provider.createNewProject(
            name: 'Camera Recording',
            ratio: _selectedRatio,
            initialClips: [clip],
          );
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const EditorScreen()),
            );
          }
        }
      }
    } catch (_) {}
  }
}
