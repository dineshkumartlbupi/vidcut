class AudioTrack {
  final String id;
  final String title;
  final String artist;
  final String audioUrl;
  final bool isAsset;
  final int durationMs;
  int startOnTimelineMs;
  double volume;
  bool isMuted;
  final bool isSfx;

  AudioTrack({
    required this.id,
    required this.title,
    this.artist = '',
    required this.audioUrl,
    this.isAsset = false,
    required this.durationMs,
    this.startOnTimelineMs = 0,
    this.volume = 1.0,
    this.isMuted = false,
    this.isSfx = false,
  });

  AudioTrack copyWith({
    String? id,
    String? title,
    String? artist,
    String? audioUrl,
    bool? isAsset,
    int? durationMs,
    int? startOnTimelineMs,
    double? volume,
    bool? isMuted,
    bool? isSfx,
  }) {
    return AudioTrack(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      audioUrl: audioUrl ?? this.audioUrl,
      isAsset: isAsset ?? this.isAsset,
      durationMs: durationMs ?? this.durationMs,
      startOnTimelineMs: startOnTimelineMs ?? this.startOnTimelineMs,
      volume: volume ?? this.volume,
      isMuted: isMuted ?? this.isMuted,
      isSfx: isSfx ?? this.isSfx,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'artist': artist,
    'audioUrl': audioUrl,
    'isAsset': isAsset,
    'durationMs': durationMs,
    'startOnTimelineMs': startOnTimelineMs,
    'volume': volume,
    'isMuted': isMuted,
    'isSfx': isSfx,
  };

  factory AudioTrack.fromJson(Map<String, dynamic> json) {
    return AudioTrack(
      id: json['id'],
      title: json['title'] ?? 'Audio',
      artist: json['artist'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      isAsset: json['isAsset'] ?? false,
      durationMs: json['durationMs'] ?? 10000,
      startOnTimelineMs: json['startOnTimelineMs'] ?? 0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      isMuted: json['isMuted'] ?? false,
      isSfx: json['isSfx'] ?? false,
    );
  }
}
