import '../core/constants.dart';
import '../core/sample_assets.dart';
import 'package:uuid/uuid.dart';

class VideoClip {
  final String id;
  final String path;
  final bool isRemote;
  final String title;
  final String thumbnailUrl;
  final int durationMs;
  int trimStartMs;
  int trimEndMs;
  double speed;
  double volume;
  bool isMuted;
  String filterId;
  double brightness;
  double contrast;
  double saturation;
  int rotationDegrees;
  bool isFlippedHorizontally;
  VideoTransitionType transition;

  VideoClip({
    required this.id,
    required this.path,
    this.isRemote = false,
    required this.title,
    this.thumbnailUrl = '',
    required this.durationMs,
    this.trimStartMs = 0,
    int? trimEndMs,
    this.speed = 1.0,
    this.volume = 1.0,
    this.isMuted = false,
    this.filterId = 'none',
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.rotationDegrees = 0,
    this.isFlippedHorizontally = false,
    this.transition = VideoTransitionType.none,
  }) : trimEndMs = trimEndMs ?? durationMs;

  int get effectiveDurationMs {
    final raw = (trimEndMs - trimStartMs).clamp(200, durationMs);
    return (raw / speed).round();
  }

  bool get isImage {
    final lower = path.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.heic');
  }

  VideoClip copyWith({
    String? id,
    String? path,
    bool? isRemote,
    String? title,
    String? thumbnailUrl,
    int? durationMs,
    int? trimStartMs,
    int? trimEndMs,
    double? speed,
    double? volume,
    bool? isMuted,
    String? filterId,
    double? brightness,
    double? contrast,
    double? saturation,
    int? rotationDegrees,
    bool? isFlippedHorizontally,
    VideoTransitionType? transition,
  }) {
    return VideoClip(
      id: id ?? this.id,
      path: path ?? this.path,
      isRemote: isRemote ?? this.isRemote,
      title: title ?? this.title,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      durationMs: durationMs ?? this.durationMs,
      trimStartMs: trimStartMs ?? this.trimStartMs,
      trimEndMs: trimEndMs ?? this.trimEndMs,
      speed: speed ?? this.speed,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      filterId: filterId ?? this.filterId,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      rotationDegrees: rotationDegrees ?? this.rotationDegrees,
      isFlippedHorizontally: isFlippedHorizontally ?? this.isFlippedHorizontally,
      transition: transition ?? this.transition,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'path': path,
    'isRemote': isRemote,
    'title': title,
    'thumbnailUrl': thumbnailUrl,
    'durationMs': durationMs,
    'trimStartMs': trimStartMs,
    'trimEndMs': trimEndMs,
    'speed': speed,
    'volume': volume,
    'isMuted': isMuted,
    'filterId': filterId,
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
    'rotationDegrees': rotationDegrees,
    'isFlippedHorizontally': isFlippedHorizontally,
    'transition': transition.name,
  };

  factory VideoClip.fromJson(Map<String, dynamic> json) {
    return VideoClip(
      id: json['id'],
      path: json['path'],
      isRemote: json['isRemote'] ?? false,
      title: json['title'] ?? 'Clip',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      durationMs: json['durationMs'] ?? 5000,
      trimStartMs: json['trimStartMs'] ?? 0,
      trimEndMs: json['trimEndMs'],
      speed: (json['speed'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      isMuted: json['isMuted'] ?? false,
      filterId: json['filterId'] ?? 'none',
      brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
      contrast: (json['contrast'] as num?)?.toDouble() ?? 1.0,
      saturation: (json['saturation'] as num?)?.toDouble() ?? 1.0,
      rotationDegrees: json['rotationDegrees'] ?? 0,
      isFlippedHorizontally: json['isFlippedHorizontally'] ?? false,
      transition: VideoTransitionType.values.firstWhere(
        (t) => t.name == json['transition'],
        orElse: () => VideoTransitionType.none,
      ),
    );
  }

  factory VideoClip.fromSample(SampleVideoAsset sample) {
    return VideoClip(
      id: const Uuid().v4(),
      path: sample.videoUrl,
      isRemote: true,
      title: sample.title,
      thumbnailUrl: sample.thumbnailUrl,
      durationMs: (sample.durationSeconds * 1000).toInt(),
      trimStartMs: 0,
      trimEndMs: (sample.durationSeconds * 1000).toInt(),
    );
  }
}
