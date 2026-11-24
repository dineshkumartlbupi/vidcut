import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/project.dart';
import '../models/video_clip.dart';
import '../models/audio_track.dart';
import '../models/text_layer.dart';
import '../models/sticker_layer.dart';
import '../core/constants.dart';
import '../core/sample_assets.dart';

class ProjectStorageService {
  static const String _folderName = 'vidcut_projects';

  static Future<Directory> _getProjectDir() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final projDir = Directory('${docsDir.path}/$_folderName');
    if (!await projDir.exists()) {
      await projDir.create(recursive: true);
    }
    return projDir;
  }

  static Future<List<VideoProject>> loadAllProjects() async {
    try {
      final dir = await _getProjectDir();
      final files = dir.listSync().whereType<File>().where((f) => f.path.endsWith('.json'));

      final List<VideoProject> projects = [];
      for (final file in files) {
        try {
          final content = await file.readAsString();
          final map = jsonDecode(content);
          projects.add(VideoProject.fromJson(map));
        } catch (_) {}
      }

      projects.sort((a, b) => b.lastModified.compareTo(a.lastModified));

      // If empty, seed an initial demo project so the user has immediate rich content
      if (projects.isEmpty) {
        final seed = createDemoProject();
        await saveProject(seed);
        projects.add(seed);
      }

      return projects;
    } catch (_) {
      return [createDemoProject()];
    }
  }

  static Future<void> saveProject(VideoProject project) async {
    try {
      final dir = await _getProjectDir();
      final file = File('${dir.path}/${project.id}.json');
      project.lastModified = DateTime.now();
      await file.writeAsString(jsonEncode(project.toJson()));
    } catch (_) {}
  }

  static Future<void> deleteProject(String projectId) async {
    try {
      final dir = await _getProjectDir();
      final file = File('${dir.path}/$projectId.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  static VideoProject createDemoProject() {
    final stock1 = SampleAssets.stockVideos[0];
    final stock2 = SampleAssets.stockVideos[1];

    return VideoProject(
      id: const Uuid().v4(),
      name: 'Cyberpunk Neon Reel',
      thumbnailUrl: stock1.thumbnailUrl,
      aspectRatio: AspectRatioPreset.ratio9_16,
      clips: [
        VideoClip(
          id: const Uuid().v4(),
          path: stock1.videoUrl,
          isRemote: true,
          title: stock1.title,
          thumbnailUrl: stock1.thumbnailUrl,
          durationMs: (stock1.durationSeconds * 1000).toInt(),
          trimStartMs: 0,
          trimEndMs: 8000,
          speed: 1.0,
          filterId: 'cyberpunk',
          transition: VideoTransitionType.dissolve,
        ),
        VideoClip(
          id: const Uuid().v4(),
          path: stock2.videoUrl,
          isRemote: true,
          title: stock2.title,
          thumbnailUrl: stock2.thumbnailUrl,
          durationMs: (stock2.durationSeconds * 1000).toInt(),
          trimStartMs: 2000,
          trimEndMs: 10000,
          speed: 1.25,
          filterId: 'teal_orange',
        ),
      ],
      audioTracks: [
        AudioTrack(
          id: const Uuid().v4(),
          title: SampleAssets.musicTracks[1].title,
          artist: SampleAssets.musicTracks[1].artist,
          audioUrl: SampleAssets.musicTracks[1].audioUrl,
          durationMs: (SampleAssets.musicTracks[1].durationSeconds * 1000).toInt(),
          startOnTimelineMs: 0,
          volume: 0.8,
        ),
      ],
      textLayers: [
        TextLayer(
          id: const Uuid().v4(),
          text: 'Vivid Cyber Nights ✨',
          xPercent: 0.5,
          yPercent: 0.35,
          fontSize: 26,
          startOnTimelineMs: 500,
          durationMs: 4000,
        ),
      ],
      stickerLayers: [
        StickerLayer(
          id: const Uuid().v4(),
          content: '🔥 FIRE',
          xPercent: 0.5,
          yPercent: 0.22,
          startOnTimelineMs: 1000,
          durationMs: 5000,
        ),
      ],
      exportResolution: ExportResolution.res1080p,
    );
  }
}
