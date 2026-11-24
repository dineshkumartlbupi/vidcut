class StickerLayer {
  final String id;
  final String content; // Emoji or badge text
  double xPercent;
  double yPercent;
  double scale;
  double rotation;
  int startOnTimelineMs;
  int durationMs;

  StickerLayer({
    required this.id,
    required this.content,
    this.xPercent = 0.5,
    this.yPercent = 0.3,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.startOnTimelineMs = 0,
    this.durationMs = 5000,
  });

  StickerLayer copyWith({
    String? id,
    String? content,
    double? xPercent,
    double? yPercent,
    double? scale,
    double? rotation,
    int? startOnTimelineMs,
    int? durationMs,
  }) {
    return StickerLayer(
      id: id ?? this.id,
      content: content ?? this.content,
      xPercent: xPercent ?? this.xPercent,
      yPercent: yPercent ?? this.yPercent,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
      startOnTimelineMs: startOnTimelineMs ?? this.startOnTimelineMs,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'content': content,
    'xPercent': xPercent,
    'yPercent': yPercent,
    'scale': scale,
    'rotation': rotation,
    'startOnTimelineMs': startOnTimelineMs,
    'durationMs': durationMs,
  };

  factory StickerLayer.fromJson(Map<String, dynamic> json) {
    return StickerLayer(
      id: json['id'],
      content: json['content'] ?? '🔥',
      xPercent: (json['xPercent'] as num?)?.toDouble() ?? 0.5,
      yPercent: (json['yPercent'] as num?)?.toDouble() ?? 0.3,
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      rotation: (json['rotation'] as num?)?.toDouble() ?? 0.0,
      startOnTimelineMs: json['startOnTimelineMs'] ?? 0,
      durationMs: json['durationMs'] ?? 5000,
    );
  }
}
