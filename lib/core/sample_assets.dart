class SampleVideoAsset {
  final String id;
  final String title;
  final String durationStr;
  final double durationSeconds;
  final String videoUrl;
  final String thumbnailUrl;
  final String category;

  const SampleVideoAsset({
    required this.id,
    required this.title,
    required this.durationStr,
    required this.durationSeconds,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.category,
  });
}

class SampleAudioAsset {
  final String id;
  final String title;
  final String artist;
  final String durationStr;
  final double durationSeconds;
  final String audioUrl;
  final String category;

  const SampleAudioAsset({
    required this.id,
    required this.title,
    required this.artist,
    required this.durationStr,
    required this.durationSeconds,
    required this.audioUrl,
    required this.category,
  });
}

class SampleSfxAsset {
  final String id;
  final String title;
  final String durationStr;
  final String audioUrl;
  final String icon;

  const SampleSfxAsset({
    required this.id,
    required this.title,
    required this.durationStr,
    required this.audioUrl,
    required this.icon,
  });
}

class SampleAssets {
  static const List<SampleVideoAsset> stockVideos = [
    SampleVideoAsset(
      id: 'stock_1',
      title: 'Neon Cyberpunk Metropolis',
      durationStr: '00:15',
      durationSeconds: 15.0,
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=500&auto=format&fit=crop',
      category: 'Cinematic',
    ),
    SampleVideoAsset(
      id: 'stock_2',
      title: 'Majestic Ocean Surf & Sunset',
      durationStr: '00:12',
      durationSeconds: 12.0,
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=500&auto=format&fit=crop',
      category: 'Nature',
    ),
    SampleVideoAsset(
      id: 'stock_3',
      title: 'Urban Street Workout & Energy',
      durationStr: '00:10',
      durationSeconds: 10.0,
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1517838277536-f5f99be501cd?w=500&auto=format&fit=crop',
      category: 'Lifestyle',
    ),
    SampleVideoAsset(
      id: 'stock_4',
      title: 'Alpine Mountain Flight Drone',
      durationStr: '00:14',
      durationSeconds: 14.0,
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyBlazes.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=500&auto=format&fit=crop',
      category: 'Travel',
    ),
    SampleVideoAsset(
      id: 'stock_5',
      title: 'Modern Coffee Brewing Aesthetic',
      durationStr: '00:11',
      durationSeconds: 11.0,
      videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
      thumbnailUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500&auto=format&fit=crop',
      category: 'Aesthetic',
    ),
  ];

  static const List<SampleAudioAsset> musicTracks = [
    SampleAudioAsset(
      id: 'music_1',
      title: 'Midnight Lo-Fi Coffee',
      artist: 'Aesthetic Chill Lab',
      durationStr: '02:30',
      durationSeconds: 150.0,
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      category: 'Lo-Fi Chill',
    ),
    SampleAudioAsset(
      id: 'music_2',
      title: 'Cyberpunk Neon Pulse',
      artist: 'Synthwave Masters',
      durationStr: '03:10',
      durationSeconds: 190.0,
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      category: 'Electronic',
    ),
    SampleAudioAsset(
      id: 'music_3',
      title: 'Sunlight Acoustic Horizon',
      artist: 'Acoustic Soul',
      durationStr: '02:45',
      durationSeconds: 165.0,
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      category: 'Acoustic',
    ),
    SampleAudioAsset(
      id: 'music_4',
      title: 'High Octane Trap Anthem',
      artist: 'Urban Beats 808',
      durationStr: '02:15',
      durationSeconds: 135.0,
      audioUrl: 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3',
      category: 'Upbeat',
    ),
  ];

  static const List<SampleSfxAsset> soundEffects = [
    SampleSfxAsset(
      id: 'sfx_whoosh',
      title: 'Cinematic Whoosh',
      durationStr: '00:01',
      audioUrl: 'https://actions.google.com/sounds/v1/cartoon/whoosh_swish.ogg',
      icon: '💨',
    ),
    SampleSfxAsset(
      id: 'sfx_camera',
      title: 'Camera Shutter',
      durationStr: '00:01',
      audioUrl: 'https://actions.google.com/sounds/v1/household/camera_shutter.ogg',
      icon: '📸',
    ),
    SampleSfxAsset(
      id: 'sfx_pop',
      title: 'Subtle Pop',
      durationStr: '00:01',
      audioUrl: 'https://actions.google.com/sounds/v1/cartoon/pop.ogg',
      icon: '✨',
    ),
    SampleSfxAsset(
      id: 'sfx_ding',
      title: 'Bell Ding',
      durationStr: '00:01',
      audioUrl: 'https://actions.google.com/sounds/v1/bell/small_bell.ogg',
      icon: '🔔',
    ),
    SampleSfxAsset(
      id: 'sfx_glitch',
      title: 'Glitch Transition',
      durationStr: '00:01',
      audioUrl: 'https://actions.google.com/sounds/v1/science_fiction/teleport_glitch.ogg',
      icon: '⚡',
    ),
  ];

  static const List<String> stickerBadges = [
    '🔥 FIRE',
    '✨ VIBES',
    '❤️ LOVE IT',
    '🚀 TRENDING',
    '🔴 SUBSCRIBE',
    '⚡ EPIC',
    '🎬 REEL',
    '💯 BEST',
    '👀 WATCH',
    '⭐ 5 STARS',
    '🎉 PARTY',
    '📸 VLOG',
  ];
}
