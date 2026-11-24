import 'package:flutter/material.dart';

class TextLayer {
  final String id;
  String text;
  double xPercent; // 0.0 - 1.0 (relative to viewport)
  double yPercent;
  double fontSize;
  Color color;
  String fontFamily;
  Color backgroundColor;
  bool hasBackground;
  bool isBold;
  bool isItalic;
  int startOnTimelineMs;
  int durationMs;

  TextLayer({
    required this.id,
    required this.text,
    this.xPercent = 0.5,
    this.yPercent = 0.5,
    this.fontSize = 24.0,
    this.color = Colors.white,
    this.fontFamily = 'Plus Jakarta Sans',
    this.backgroundColor = Colors.black54,
    this.hasBackground = true,
    this.isBold = true,
    this.isItalic = false,
    this.startOnTimelineMs = 0,
    this.durationMs = 5000,
  });

  TextLayer copyWith({
    String? id,
    String? text,
    double? xPercent,
    double? yPercent,
    double? fontSize,
    Color? color,
    String? fontFamily,
    Color? backgroundColor,
    bool? hasBackground,
    bool? isBold,
    bool? isItalic,
    int? startOnTimelineMs,
    int? durationMs,
  }) {
    return TextLayer(
      id: id ?? this.id,
      text: text ?? this.text,
      xPercent: xPercent ?? this.xPercent,
      yPercent: yPercent ?? this.yPercent,
      fontSize: fontSize ?? this.fontSize,
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      hasBackground: hasBackground ?? this.hasBackground,
      isBold: isBold ?? this.isBold,
      isItalic: isItalic ?? this.isItalic,
      startOnTimelineMs: startOnTimelineMs ?? this.startOnTimelineMs,
      durationMs: durationMs ?? this.durationMs,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'xPercent': xPercent,
    'yPercent': yPercent,
    'fontSize': fontSize,
    'color': color.value,
    'fontFamily': fontFamily,
    'backgroundColor': backgroundColor.value,
    'hasBackground': hasBackground,
    'isBold': isBold,
    'isItalic': isItalic,
    'startOnTimelineMs': startOnTimelineMs,
    'durationMs': durationMs,
  };

  factory TextLayer.fromJson(Map<String, dynamic> json) {
    return TextLayer(
      id: json['id'],
      text: json['text'] ?? 'Title',
      xPercent: (json['xPercent'] as num?)?.toDouble() ?? 0.5,
      yPercent: (json['yPercent'] as num?)?.toDouble() ?? 0.5,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 24.0,
      color: Color(json['color'] ?? 0xFFFFFFFF),
      fontFamily: json['fontFamily'] ?? 'Plus Jakarta Sans',
      backgroundColor: Color(json['backgroundColor'] ?? 0x8A000000),
      hasBackground: json['hasBackground'] ?? true,
      isBold: json['isBold'] ?? true,
      isItalic: json['isItalic'] ?? false,
      startOnTimelineMs: json['startOnTimelineMs'] ?? 0,
      durationMs: json['durationMs'] ?? 5000,
    );
  }
}
