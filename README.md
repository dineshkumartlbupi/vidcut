# VidCut: Video Editor & Maker

> **100% Free Pro Video Editor & Reels Maker — No Watermark, No Subscriptions.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Platform](https://img.shields.io/badge/Platform-Android-3DDC84?logo=android)](https://developer.android.com)
[![Package](https://img.shields.io/badge/Package-com.vidcut.videoeditor-FFD600)](https://play.google.com)
[![Privacy Policy](https://img.shields.io/badge/Privacy%20Policy-Live%20Hosted-00E5FF)](https://dineshkumartlbupi.github.io/vidcut/)

---

## 🌟 Overview

**VidCut** is a high-performance, VIP-grade video editing application built with Flutter, designed to rival Tier-1 market leaders like YouCut, InShot, VN, and CapCut. 

All video processing, color grading, velocity curve calculation, and 4K 60FPS video encoding occur **100% locally on the device's hardware**, guaranteeing complete user privacy.

---

## 🚀 Key Features

* **🚫 100% Free & No Watermark:** Export watermark-free videos without paying subscriptions or watching banner ads.
* **🎞️ Pro Multi-Track Timeline:** Precision millisecond trimming, clip splitting, timeline zooming, and multi-layer tracks.
* **⚡ 1-Tap Viral Reel Presets:** Pre-styled trending aesthetic themes with beat-synced cuts and cinematic transitions.
* **🏎️ Smooth Velocity Curves (0.25x – 4.0x):** Professional non-linear speed ramping (Montage, Hero Climax, Bullet Time).
* **🎨 Cinema Color LUTs & Filters:** Hollywood Teal & Orange, Cyberpunk, 90s Vintage, Film Noir, and custom adjustments.
* **🔀 50+ Dynamic Transition Effects:** Cross Dissolve, Glitch, Zoom In/Out, Flash Black, and 1-Tap Apply to All Clips.
* **🎵 Audio Studio & Video Audio Ripper:** Extract background audio directly from any video, add royalty-free music, and sound FX.
* **💎 Ultra HD 4K 60FPS Export:** Hardware-accelerated GPU rendering via Android MediaCodec with zero quality loss.
* **📐 Multi-Platform Canvas Ratios:** 9:16 (TikTok & Reels), 16:9 (YouTube), 1:1 (Instagram Feed), 4:5, and 21:9 CinemaScope.

---

## 📜 Privacy Policy

The official Privacy Policy is hosted on GitHub Pages:
- **Webpage:** [https://dineshkumartlbupi.github.io/vidcut/](https://dineshkumartlbupi.github.io/vidcut/)
- **Direct HTML:** [https://dineshkumartlbupi.github.io/vidcut/privacy_policy.html](https://dineshkumartlbupi.github.io/vidcut/privacy_policy.html)
- **Markdown:** [privacy_policy.md](privacy_policy.md)

---

## 🛠️ Project Structure

```
video_editor_app/
├── lib/
│   ├── main.dart
│   ├── core/                  # Theme, Constants, Sample Assets
│   ├── models/                # Project, VideoClip, AudioTrack, FilterPreset
│   ├── screens/               # HomeScreen, EditorScreen, ExportScreen, MediaPicker
│   ├── services/              # VideoExportService, StorageService
│   ├── state/                 # EditorProvider (Riverpod / ChangeNotifier)
│   └── widgets/               # Timeline, Viewport, Sheets (Speed, Filters, Audio)
├── android/                   # Native Android Host (compileSdk 36, targetSdk 36, Keystore & Gradle Wrapper included)
├── VidCut_PlayStore_Assets/   # Play Store Assets (Icon, Feature Graphic, Screenshots)
├── privacy_policy.html        # Hosted Privacy Policy Webpage
└── README.md
```

---

## 💻 Building & Running

### Prerequisites
* Flutter SDK (3.x+)
* Android SDK (API 34/35/36)
* Java JDK 17+

### Run Debug on Connected Device
```bash
flutter pub get
flutter run
```

### Build Production Release
```bash
# Build Android App Bundle (AAB for Google Play Console)
flutter build appbundle --release

# Build Standalone Release APK
flutter build apk --release
```

---

## 📄 License & Attribution

Copyright © 2026 VidCut Studio. Built for content creators worldwide.
