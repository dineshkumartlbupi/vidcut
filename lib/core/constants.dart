import 'package:flutter/material.dart';

enum AspectRatioPreset {
  ratio9_16(name: '9:16', subtitle: 'TikTok / Reels / Shorts', ratio: 9 / 16, icon: Icons.stay_current_portrait),
  ratio16_9(name: '16:9', subtitle: 'YouTube / Widescreen', ratio: 16 / 9, icon: Icons.stay_current_landscape),
  ratio1_1(name: '1:1', subtitle: 'Instagram Square', ratio: 1 / 1, icon: Icons.crop_square),
  ratio4_5(name: '4:5', subtitle: 'Instagram Portrait', ratio: 4 / 5, icon: Icons.crop_portrait),
  ratio21_9(name: '21:9', subtitle: 'Cinematic CinemaScope', ratio: 21 / 9, icon: Icons.movie_filter);

  final String name;
  final String subtitle;
  final double ratio;
  final IconData icon;

  const AspectRatioPreset({
    required this.name,
    required this.subtitle,
    required this.ratio,
    required this.icon,
  });
}

enum ExportResolution {
  res480p(label: '480p', name: 'Standard (SD)', width: 854, height: 480, approxMbPerMin: 12),
  res720p(label: '720p', name: 'High Definition (HD)', width: 1280, height: 720, approxMbPerMin: 28),
  res1080p(label: '1080p', name: 'Full HD 60fps', width: 1920, height: 1080, approxMbPerMin: 55),
  res4k(label: '4K', name: 'Ultra HD Cinema', width: 3840, height: 2160, approxMbPerMin: 180);

  final String label;
  final String name;
  final int width;
  final int height;
  final int approxMbPerMin;

  const ExportResolution({
    required this.label,
    required this.name,
    required this.width,
    required this.height,
    required this.approxMbPerMin,
  });
}

enum VideoTransitionType {
  none(name: 'None', icon: Icons.block),
  fadeBlack(name: 'Fade Black', icon: Icons.brightness_1),
  dissolve(name: 'Cross Dissolve', icon: Icons.blur_on),
  slideLeft(name: 'Slide Left', icon: Icons.arrow_back),
  zoomBurst(name: 'Zoom Burst', icon: Icons.zoom_out_map),
  whiteFlash(name: 'Flash', icon: Icons.flash_on);

  final String name;
  final IconData icon;
  const VideoTransitionType({required this.name, required this.icon});
}
