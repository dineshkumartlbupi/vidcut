import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../state/editor_provider.dart';
import '../models/audio_track.dart';
import '../core/sample_assets.dart';
import '../core/theme.dart';

class AudioPickerSheet extends StatefulWidget {
  final EditorProvider provider;

  const AudioPickerSheet({super.key, required this.provider});

  @override
  State<AudioPickerSheet> createState() => _AudioPickerSheetState();
}

class _AudioPickerSheetState extends State<AudioPickerSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final clip = widget.provider.selectedClip;
    final isMuted = clip?.isMuted ?? false;
    final videoVolume = clip?.volume ?? 1.0;

    return Container(
      height: 480,
      decoration: const BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.library_music_rounded, color: AppTheme.cyan, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Audio & Music Studio',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => widget.provider.setActiveTool('none'),
                ),
              ],
            ),
          ),

          // Original Video Audio Mixing Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.stroke),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: isMuted ? AppTheme.redPlayhead : AppTheme.cyan,
                    size: 20,
                  ),
                  onPressed: () {
                    widget.provider.updateClipVolume(
                      widget.provider.selectedClipIndex,
                      videoVolume,
                      !isMuted,
                    );
                  },
                ),
                const SizedBox(width: 4),
                const Text(
                  'Original Video:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                Expanded(
                  child: Slider(
                    value: isMuted ? 0.0 : videoVolume.clamp(0.0, 2.0),
                    min: 0.0,
                    max: 2.0,
                    divisions: 20,
                    onChanged: (val) {
                      widget.provider.updateClipVolume(
                        widget.provider.selectedClipIndex,
                        val,
                        val == 0.0,
                      );
                    },
                  ),
                ),
                Text(
                  isMuted ? 'Muted' : '${(videoVolume * 100).toInt()}%',
                  style: const TextStyle(fontSize: 11, color: AppTheme.cyan, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Tabs
          TabBar(
            controller: _tabController,
            indicatorColor: AppTheme.primary,
            indicatorWeight: 3,
            labelColor: Colors.white,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: const [
              Tab(text: 'Royalty-Free Tracks'),
              Tab(text: 'Sound Effects (SFX)'),
            ],
          ),

          // Tab views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. Music Tracks
                _buildMusicList(),

                // 2. Sound Effects
                _buildSfxList(),
              ],
            ),
          ),

          // Custom Import button
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.file_upload_outlined, size: 18, color: AppTheme.primaryLight),
                label: const Text(
                  'Import Custom Audio (MP3/WAV)',
                  style: TextStyle(color: Colors.white, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primary, width: 1.2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _pickCustomAudio,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: SampleAssets.musicTracks.length,
      itemBuilder: (context, index) {
        final track = SampleAssets.musicTracks[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.strokeLight, width: 0.8),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.music_note, color: AppTheme.primaryLight, size: 20),
            ),
            title: Text(
              track.title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white),
            ),
            subtitle: Text(
              '${track.artist} • ${track.category} • ${track.durationStr}',
              style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
            ),
            trailing: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                minimumSize: const Size(60, 32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                widget.provider.addAudioTrack(
                  AudioTrack(
                    id: const Uuid().v4(),
                    title: track.title,
                    artist: track.artist,
                    audioUrl: track.audioUrl,
                    durationMs: (track.durationSeconds * 1000).toInt(),
                    startOnTimelineMs: widget.provider.currentTimeMs,
                  ),
                );
                widget.provider.setActiveTool('none');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${track.title}" to audio track'),
                    backgroundColor: AppTheme.emeraldGreen,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: const Text('Add', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSfxList() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: SampleAssets.soundEffects.length,
      itemBuilder: (context, index) {
        final sfx = SampleAssets.soundEffects[index];

        return InkWell(
          onTap: () {
            widget.provider.addAudioTrack(
              AudioTrack(
                id: const Uuid().v4(),
                title: sfx.title,
                audioUrl: sfx.audioUrl,
                durationMs: 1500,
                startOnTimelineMs: widget.provider.currentTimeMs,
                isSfx: true,
              ),
            );
            widget.provider.setActiveTool('none');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Added SFX "${sfx.title}" at ${widget.provider.currentTimeMs ~/ 1000}s'),
                backgroundColor: AppTheme.cyan,
                duration: const Duration(seconds: 1),
              ),
            );
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.stroke),
            ),
            child: Row(
              children: [
                Text(sfx.icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        sfx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                      ),
                      Text(
                        sfx.durationStr,
                        style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.add_circle_outline, size: 16, color: AppTheme.primaryLight),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickCustomAudio() async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.audio);
      if (files.isNotEmpty && files.first.path != null) {
        final path = files.first.path!;
        final name = files.first.name;
        widget.provider.addAudioTrack(
          AudioTrack(
            id: const Uuid().v4(),
            title: name,
            artist: 'Imported Audio',
            audioUrl: path,
            durationMs: 30000,
            startOnTimelineMs: widget.provider.currentTimeMs,
          ),
        );
        widget.provider.setActiveTool('none');
      }
    } catch (_) {}
  }
}
