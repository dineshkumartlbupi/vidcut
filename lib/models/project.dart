import '../core/constants.dart';
import 'video_clip.dart';
import 'audio_track.dart';
import 'text_layer.dart';
import 'sticker_layer.dart';

class VideoProject {
  final String id;
  String name;
  String thumbnailUrl;
  AspectRatioPreset aspectRatio;
  List<VideoClip> clips;
  List<AudioTrack> audioTracks;
  List<TextLayer> textLayers;
  List<StickerLayer> stickerLayers;
  ExportResolution exportResolution;
  DateTime lastModified;

  VideoProject({
    required this.id,
    required this.name,
    this.thumbnailUrl = '',
    this.aspectRatio = AspectRatioPreset.ratio9_16,
    List<VideoClip>? clips,
    List<AudioTrack>? audioTracks,
    List<TextLayer>? textLayers,
    List<StickerLayer>? stickerLayers,
    this.exportResolution = ExportResolution.res1080p,
    DateTime? lastModified,
  })  : clips = clips ?? [],
        audioTracks = audioTracks ?? [],
        textLayers = textLayers ?? [],
        stickerLayers = stickerLayers ?? [],
        lastModified = lastModified ?? DateTime.now();

  int get totalDurationMs {
    if (clips.isEmpty) return 0;
    return clips.fold<int>(0, (sum, clip) => sum + clip.effectiveDurationMs);
  }

  String get formattedDuration {
    final totalSec = (totalDurationMs / 1000).round();
    final mins = (totalSec ~/ 60).toString().padLeft(2, '0');
    final secs = (totalSec % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  VideoProject copyWith({
    String? id,
    String? name,
    String? thumbnailUrl,
    AspectRatioPreset? aspectRatio,
    List<VideoClip>? clips,
    List<AudioTrack>? audioTracks,
    List<TextLayer>? textLayers,
    List<StickerLayer>? stickerLayers,
    ExportResolution? exportResolution,
    DateTime? lastModified,
  }) {
    return VideoProject(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      clips: clips ?? List.from(this.clips),
      audioTracks: audioTracks ?? List.from(this.audioTracks),
      textLayers: textLayers ?? List.from(this.textLayers),
      stickerLayers: stickerLayers ?? List.from(this.stickerLayers),
      exportResolution: exportResolution ?? this.exportResolution,
      lastModified: lastModified ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'thumbnailUrl': thumbnailUrl,
    'aspectRatio': aspectRatio.name,
    'clips': clips.map((c) => c.toJson()).toList(),
    'audioTracks': audioTracks.map((a) => a.toJson()).toList(),
    'textLayers': textLayers.map((t) => t.toJson()).toList(),
    'stickerLayers': stickerLayers.map((s) => s.toJson()).toList(),
    'exportResolution': exportResolution.name,
    'lastModified': lastModified.toIso8601String(),
  };

  factory VideoProject.fromJson(Map<String, dynamic> json) {
    return VideoProject(
      id: json['id'],
      name: json['name'] ?? 'Untitled Project',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      aspectRatio: AspectRatioPreset.values.firstWhere(
        (a) => a.name == json['aspectRatio'],
        orElse: () => AspectRatioPreset.ratio9_16,
      ),
      clips: (json['clips'] as List?)?.map((c) => VideoClip.fromJson(c)).toList() ?? [],
      audioTracks: (json['audioTracks'] as List?)?.map((a) => AudioTrack.fromJson(a)).toList() ?? [],
      textLayers: (json['textLayers'] as List?)?.map((t) => TextLayer.fromJson(t)).toList() ?? [],
      stickerLayers: (json['stickerLayers'] as List?)?.map((s) => StickerLayer.fromJson(s)).toList() ?? [],
      exportResolution: ExportResolution.values.firstWhere(
        (e) => e.name == json['exportResolution'],
        orElse: () => ExportResolution.res1080p,
      ),
      lastModified: json['lastModified'] != null
          ? DateTime.tryParse(json['lastModified']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
