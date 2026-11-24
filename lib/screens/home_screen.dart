import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../state/editor_provider.dart';
import '../models/project.dart';
import '../models/video_clip.dart';
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
              'NovaCut',
              style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5),
            ),
          ],
        ),
        actions: [
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
            // Hero "New Project" card
            _buildNewProjectHero(context, provider),

            const SizedBox(height: 24),

            // Quick Tools Bar
            const Text(
              'Quick Studio Tools',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 12),
            _buildQuickToolsRow(context, provider),

            const SizedBox(height: 24),

            // Sample Stock Clips Carousel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Start with Ready-to-Edit Clips',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                Text(
                  '${SampleAssets.stockVideos.length} Clips',
                  style: const TextStyle(fontSize: 12, color: AppTheme.cyan, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStockClipsCarousel(context, provider),

            const SizedBox(height: 28),

            // Recent Projects
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

  Widget _buildNewProjectHero(BuildContext context, EditorProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E1065), Color(0xFF1E1B4B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.25),
            blurRadius: 20,
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
                  'PRO 4K ENGINE',
                  style: TextStyle(color: AppTheme.cyan, fontSize: 10, fontWeight: FontWeight.w800),
                ),
              ),
              const Spacer(),
              const Icon(Icons.auto_awesome, color: AppTheme.cyan, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Create Cinematic Video',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
          ),
          const SizedBox(height: 6),
          const Text(
            'Multi-track timeline, trending transitions, music library, and instant 4K export for Reels & Shorts.',
            style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text(
                'Start New Project',
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
        ],
      ),
    );
  }

  Widget _buildQuickToolsRow(BuildContext context, EditorProvider provider) {
    final tools = [
      {'icon': Icons.content_cut_rounded, 'name': 'Trim & Cut', 'color': AppTheme.amberHandle},
      {'icon': Icons.speed_rounded, 'name': 'Speed Curve', 'color': AppTheme.cyan},
      {'icon': Icons.auto_fix_high_rounded, 'name': 'Color LUTs', 'color': AppTheme.primaryLight},
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
              'Tap Start New Project or choose a stock clip above to begin!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
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
                  'NovaCut Video Editor',
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
                  'NovaCut uses Android 14 Media Storage permissions solely for loading and exporting user-selected videos.',
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
