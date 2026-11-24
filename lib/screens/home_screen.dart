import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:uuid/uuid.dart';

import '../state/editor_provider.dart';
import '../models/project.dart';
import '../models/video_clip.dart';
import '../models/audio_track.dart';
import '../models/text_layer.dart';
import '../core/constants.dart';
import '../core/sample_assets.dart';
import '../core/theme.dart';
import 'editor_screen.dart';
import 'media_picker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final projects = provider.projects;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.cyan],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.movie_creation_rounded, size: 20, color: Colors.white),
            ),
            const SizedBox(width: 10),
            const Text(
              'VidCut',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                gradient: AppTheme.accentGradient,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'PRO FREE',
                style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          // Beginner's Quick Guide pill
          GestureDetector(
            onTap: () => _showQuickGuide(context),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryLight, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline, size: 14, color: AppTheme.cyan),
                  SizedBox(width: 4),
                  Text(
                    'Easy Guide',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white70),
            onPressed: () => _showSettings(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Beginner 3-Step "No Learning Curve" Helper Banner
            _buildBeginnerGuideBanner(context),

            const SizedBox(height: 18),

            // 2. Hero "New Project" Action Card
            _buildNewProjectHero(context, provider),

            const SizedBox(height: 24),

            // 3. "1-Tap Viral Reel Themes" (Zero-effort instant creation)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, size: 18, color: AppTheme.primaryLight),
                    SizedBox(width: 8),
                    Text(
                      '1-Tap Viral Reel Presets',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'ZERO EFFORT',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.emeraldGreen),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildViralThemesCarousel(context, provider),

            const SizedBox(height: 24),

            // 4. Quick Studio Tools
            const Text(
              'Quick Studio Tools',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildQuickToolsRow(context, provider),

            const SizedBox(height: 24),

            // 5. Stock Clips Showcase
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Explore Ready Clips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${SampleAssets.stockVideos.length} Stock Clips',
                  style: const TextStyle(fontSize: 12, color: AppTheme.cyan, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStockClipsCarousel(context, provider),

            const SizedBox(height: 28),

            // 6. Draft Projects
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Draft Projects',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${projects.length} Saved',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (projects.isEmpty)
              _buildEmptyProjectsCard(context)
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  return _buildProjectItem(context, provider, projects[index]);
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBeginnerGuideBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => _showQuickGuide(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.cyan.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.cyan.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.flash_on_rounded, size: 16, color: AppTheme.cyan),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Edit in 3 Simple Steps',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    '1. Choose video → 2. Add Filter & Beat → 3. Export 4K',
                    style: TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppTheme.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildNewProjectHero(BuildContext context, EditorProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B0764), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primary.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.cyan.withOpacity(0.4)),
                ),
                child: const Text(
                  'PRO REEL ENGINE',
                  style: TextStyle(color: AppTheme.cyan, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome, color: AppTheme.cyan, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Create Viral Reel in Seconds',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'No learning required. Pick your video, tap a cinematic filter, add trending beats, and export in crystal-clear 4K.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text(
                'Start New Video Project',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MediaPickerScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.photo_library_rounded, size: 14, color: AppTheme.pinkNeon),
                  label: const Text('📸 Photos to Reel', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.pinkNeon.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MediaPickerScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.music_video_rounded, size: 14, color: AppTheme.cyan),
                  label: const Text('🎵 Extract Audio', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppTheme.cyan.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MediaPickerScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildViralThemesCarousel(BuildContext context, EditorProvider provider) {
    final themes = [
      {
        'title': 'Cyberpunk Neon',
        'subtitle': 'Futuristic glow & trap beat',
        'sample': SampleAssets.stockVideos[0],
        'music': SampleAssets.musicTracks[1],
        'filter': 'cyberpunk',
        'text': 'Neon Nights ✨',
        'color': AppTheme.primary,
      },
      {
        'title': 'Teal & Orange Cinema',
        'subtitle': 'Hollywood beach blockbuster',
        'sample': SampleAssets.stockVideos[1],
        'music': SampleAssets.musicTracks[2],
        'filter': 'teal_orange',
        'text': 'Ocean Dreams 🌊',
        'color': AppTheme.cyan,
      },
      {
        'title': 'Vintage Lo-Fi Vlog',
        'subtitle': 'Warm 90s coffee aesthetic',
        'sample': SampleAssets.stockVideos[4],
        'music': SampleAssets.musicTracks[0],
        'filter': 'vintage',
        'text': 'Morning Coffee ☕',
        'color': AppTheme.amberHandle,
      },
      {
        'title': 'High Energy Action',
        'subtitle': 'Fast-paced street hype',
        'sample': SampleAssets.stockVideos[2],
        'music': SampleAssets.musicTracks[3],
        'filter': 'vibrant',
        'text': 'Workout Grind 💯',
        'color': AppTheme.redPlayhead,
      },
    ];

    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final t = themes[index];
          final sample = t['sample'] as SampleVideoAsset;
          final music = t['music'] as SampleAudioAsset;
          final themeColor = t['color'] as Color;

          return GestureDetector(
            onTap: () async {
              // 1-Tap creation: creates full configured project with video, music, filter, and text layer
              final proj = VideoProject(
                id: const Uuid().v4(),
                name: '${t['title']} Reel',
                thumbnailUrl: sample.thumbnailUrl,
                aspectRatio: AspectRatioPreset.ratio9_16,
                clips: [
                  VideoClip(
                    id: const Uuid().v4(),
                    path: sample.videoUrl,
                    isRemote: true,
                    title: sample.title,
                    thumbnailUrl: sample.thumbnailUrl,
                    durationMs: (sample.durationSeconds * 1000).toInt(),
                    filterId: t['filter'] as String,
                  ),
                ],
                audioTracks: [
                  AudioTrack(
                    id: const Uuid().v4(),
                    title: music.title,
                    artist: music.artist,
                    audioUrl: music.audioUrl,
                    durationMs: (music.durationSeconds * 1000).toInt(),
                    volume: 0.85,
                  ),
                ],
                textLayers: [
                  TextLayer(
                    id: const Uuid().v4(),
                    text: t['text'] as String,
                    xPercent: 0.5,
                    yPercent: 0.35,
                    fontSize: 26,
                  ),
                ],
              );

              await provider.createNewProject(
                name: proj.name,
                ratio: proj.aspectRatio,
                initialClips: proj.clips,
              );
              provider.currentProject?.audioTracks = proj.audioTracks;
              provider.currentProject?.textLayers = proj.textLayers;
              await provider.saveCurrentProject();

              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditorScreen()),
                );
              }
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: themeColor.withOpacity(0.6), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: themeColor.withOpacity(0.2),
                    blurRadius: 10,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(imageUrl: sample.thumbnailUrl, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.black54, Colors.transparent, Colors.black.withOpacity(0.9)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: themeColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '1-TAP READY',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t['title'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          t['subtitle'] as String,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
                        ),
                      ],
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

  Widget _buildQuickToolsRow(BuildContext context, EditorProvider provider) {
    final tools = [
      {'icon': Icons.content_cut_rounded, 'name': 'Trim Video', 'color': AppTheme.amberHandle},
      {'icon': Icons.speed_rounded, 'name': 'Slow-Mo', 'color': AppTheme.cyan},
      {'icon': Icons.auto_fix_high_rounded, 'name': 'Color Filters', 'color': AppTheme.primaryLight},
      {'icon': Icons.audiotrack_rounded, 'name': 'Music & SFX', 'color': AppTheme.emeraldGreen},
    ];

    return Row(
      children: tools.map((tool) {
        return Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MediaPickerScreen()),
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.stroke),
              ),
              child: Column(
                children: [
                  Icon(tool['icon'] as IconData, color: tool['color'] as Color, size: 22),
                  const SizedBox(height: 8),
                  Text(
                    tool['name'] as String,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStockClipsCarousel(BuildContext context, EditorProvider provider) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: SampleAssets.stockVideos.length,
        itemBuilder: (context, index) {
          final clip = SampleAssets.stockVideos[index];

          return GestureDetector(
            onTap: () async {
              await provider.createNewProject(
                name: clip.title,
                initialClips: [
                  VideoClip.fromSample(clip),
                ],
              );
              if (context.mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditorScreen()),
                );
              }
            },
            child: Container(
              width: 170,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.stroke),
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: clip.thumbnailUrl,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Colors.black.withOpacity(0.85)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
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
                        clip.category,
                        style: const TextStyle(color: AppTheme.cyan, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          clip.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          clip.durationStr,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
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

  Widget _buildProjectItem(BuildContext context, EditorProvider provider, VideoProject project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.stroke),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(10),
          ),
          clipBehavior: Clip.antiAlias,
          child: project.thumbnailUrl.isNotEmpty
              ? CachedNetworkImage(imageUrl: project.thumbnailUrl, fit: BoxFit.cover)
              : const Center(child: Icon(Icons.movie_outlined, color: Colors.white38)),
        ),
        title: Text(
          project.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
        ),
        subtitle: Text(
          '${project.aspectRatio.name} • ${project.formattedDuration} • ${project.clips.length} Clips',
          style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white70),
          onPressed: () {
            _showProjectOptions(context, provider, project);
          },
        ),
        onTap: () async {
          await provider.openProject(project);
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditorScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildEmptyProjectsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.stroke),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(Icons.video_library_outlined, size: 40, color: AppTheme.textMuted),
            SizedBox(height: 10),
            Text(
              'No projects yet',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 4),
            Text(
              'Tap Start New Project or choose a 1-Tap Theme above to begin!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuickGuide(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppTheme.cyan, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Quick Editing Guide',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildGuideStep('1', 'Drag the Red Line', 'Move the playhead to the exact point in your video where you want to edit or cut.'),
                const SizedBox(height: 12),
                _buildGuideStep('2', 'Tap "Split" to Cut', 'One tap slices your video into two segments so you can delete or style parts independently.'),
                const SizedBox(height: 12),
                _buildGuideStep('3', 'Add Filters, Music & Text', 'Choose from Hollywood color grades, royalty-free audio tracks, and animated viral text overlays.'),
                const SizedBox(height: 12),
                _buildGuideStep('4', 'Export in 4K', 'Tap Export in the top right corner to instantly render and share to Instagram, TikTok, or YouTube.'),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Got it! Let\'s Edit ✨'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGuideStep(String number, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showProjectOptions(BuildContext context, EditorProvider provider, VideoProject project) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.edit_outlined, color: AppTheme.primaryLight),
                  title: const Text('Open in Editor', style: TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.openProject(project);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EditorScreen()));
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: AppTheme.redPlayhead),
                  title: const Text('Delete Project', style: TextStyle(color: AppTheme.redPlayhead)),
                  onTap: () {
                    Navigator.pop(ctx);
                    provider.deleteProject(project.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceElevated,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VidCut Video Editor',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Version 1.0.0 (Release Build) • Target SDK 35',
                  style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
                const Divider(color: AppTheme.stroke, height: 24),
                const Text(
                  'Permissions & Compliance',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.cyan),
                ),
                const SizedBox(height: 4),
                const Text(
                  'VidCut uses Android 14 Media Storage permissions solely for loading and exporting user-selected videos.',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
