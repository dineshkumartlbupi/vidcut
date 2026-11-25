# Privacy Policy for VidCut: Video Editor & Maker

**Effective Date:** November 25, 2026  
**Last Updated:** November 25, 2026  
**Application Name:** VidCut: Video Editor & Maker  
**Package Name (Application ID):** `com.vidcut.videoeditor`  
**Developer Contact:** `support@vidcut.app` / `vidcut.editor.team@gmail.com`

---

## 1. Introduction

Welcome to **VidCut: Video Editor & Maker** ("VidCut", "we", "our", or "us"). We are committed to protecting your privacy and ensuring you have a positive, transparent experience while creating videos, reels, and slideshows.

This Privacy Policy explains how VidCut handles your personal data, media files, and device permissions when you use our mobile application downloaded from the Google Play Store.

> **Key Privacy Guarantee:**  
> **VidCut operates as a local, on-device video editor.** Your personal videos, photos, and audio files are processed directly on your mobile device's hardware. We do **NOT** upload, transmit, store, or sell your private media files to remote cloud servers.

---

## 2. Information We Access and Process

### A. User Media (Videos, Photos, Audio Files)
- **Local Access Only:** When you import video clips, photos, or music into VidCut, the app accesses those files locally on your device to decode video frames, render transitions, apply color filters, sync audio tracks, and encode exported video files.
- **No Remote Uploads:** Your media files remain exclusively on your device. We do not have access to your personal videos or photos, and we do not maintain cloud servers that store your content.

### B. Project Drafts & Settings
- Project timelines, edit states, text layers, filter choices, velocity curves, and transition settings are saved strictly in the application's local sandbox storage (`/data/user/0/com.vidcut.videoeditor/`).
- If you uninstall the app or clear app data, these locally saved draft settings are permanently removed.

### C. Technical & Diagnostic Information (Non-Personal)
To ensure app performance, stability, and compatibility across various Android device chipsets:
- **Device Information:** Device model, operating system version (e.g., Android 14), screen resolution, CPU/GPU hardware capabilities for hardware-accelerated video encoding.
- **Crash & Diagnostic Logs:** Anonymous crash logs and rendering error diagnostics (such as codec failure or out-of-memory logs) to identify and patch bugs. These logs contain **no** personal identity, facial data, or media content.

---

## 3. Device Permissions & Why We Need Them

To deliver video editing features, VidCut requests specific Android operating system permissions. You can grant or revoke these permissions at any time via your device's **Settings > Apps > VidCut > Permissions**.

| Permission | Android Version | Purpose |
|---|---|---|
| `READ_MEDIA_VIDEO` | Android 13+ (API 33+) | Allows you to select and import videos from your device into the VidCut editor timeline. |
| `READ_MEDIA_IMAGES` | Android 13+ (API 33+) | Allows you to select photos for slideshow reels, thumbnail generation, and picture-in-picture (PIP) overlays. |
| `READ_MEDIA_AUDIO` | Android 13+ (API 33+) | Allows you to import local MP3/WAV audio files from your storage as background music. |
| `READ_EXTERNAL_STORAGE` | Android 12 and below | Allows importing videos, photos, and music from device storage on older Android versions. |
| `WRITE_EXTERNAL_STORAGE` | Android 9 and below | Allows saving exported 1080p and 4K videos directly to your device's Gallery / Movies directory. (On Android 10+, modern scoped MediaStore API is used without requiring broad write access). |
| `CAMERA` *(Optional)* | All versions | Used only if you tap "Record with Camera" to record live video directly into an editing project. |
| `RECORD_AUDIO` *(Optional)* | All versions | Used only if you choose to record a live microphone voiceover onto your video timeline. |

> **Note on Permissions:** VidCut never accesses your camera, microphone, or storage in the background. Permissions are invoked only when you explicitly trigger the corresponding feature (e.g., tapping camera record or selecting a video clip).

---

## 4. How We Use Information

We process technical data solely to:
1. Provide, maintain, and optimize video editing, color LUT grading, velocity curve calculation, and 4K 60FPS video encoding.
2. Enable hardware acceleration through Android MediaCodec for fast, stutter-free video exports.
3. Diagnose and fix app crashes, codec failures, and memory leaks.
4. Comply with legal and Google Play Developer Policy obligations.

---

## 5. Third-Party Services & Libraries

VidCut uses standard industry SDKs and open-source libraries that adhere to Google Play Developer policies:

- **Google Play Services:** Used for app integrity, core runtime services, and standard Google Play in-app updates.  
  [Google Privacy Policy](https://policies.google.com/privacy)
- **Google Play Core:** Used to manage app delivery, split APK modules, and feature updates.
- **ExoPlayer / Media3 / Flutter Engine:** Open-source video playback and rendering components that run 100% locally on your hardware.

**We do NOT sell, rent, or trade your personal data or user media to third-party data brokers or advertisers.**

---

## 6. Data Security & Storage

- **Local Storage:** All video editing happens on-device. No user videos or photos are transmitted over the internet by VidCut.
- **Industry Standards:** When the app interacts with external services (such as downloading stock royalty-free sound effects or checking for app updates), all communications are encrypted using HTTPS / TLS 1.3 encryption.
- **Data Retention:** Because we do not store your media on cloud servers, we retain zero personal user data. Exported videos remain in your device's public media folder until you choose to delete them.

---

## 7. Children's Privacy (COPPA & GDPR-K Compliance)

VidCut is designed for general audiences and content creators. We do not knowingly collect, solicit, or store personal identifiable information from children under the age of 13 (or under 16 in the European Economic Area). If you are a parent or guardian and believe your child has provided us with personal information, please contact us immediately at `support@vidcut.app` so we can take appropriate steps.

---

## 8. International User Rights (GDPR, UK GDPR & CCPA / CPRA)

Depending on your geographic location, you possess specific data privacy rights:

### European Union & UK (GDPR):
- **Right to Access & Portability:** You have full control over your local files. Your media never leaves your device.
- **Right to Erasure (Right to be Forgotten):** You can delete all projects, cached thumbnails, and exported videos at any time by clearing the app cache/data or uninstalling VidCut.
- **Right to Withdraw Consent:** You can withdraw camera, microphone, or storage permissions at any time through Android System Settings.

### California Residents (CCPA / CPRA):
- We do **NOT** sell personal information.
- We do **NOT** share personal information for cross-context behavioral advertising.
- You have the right to request information regarding any collected categories of data and the right to non-discrimination for exercising your privacy rights.

---

## 9. Changes to This Privacy Policy

We may update this Privacy Policy from time to time to reflect changes in our app features, Android operating system updates, or legal requirements. When updates occur:
- We will update the **"Last Updated"** date at the top of this document.
- Significant changes will be announced via an in-app notice or release notes on the Google Play Store.
- Continued use of VidCut following any modifications indicates your acceptance of the updated Privacy Policy.

---

## 10. Contact Us

If you have questions, feedback, or concerns regarding this Privacy Policy or VidCut's privacy practices, please contact our privacy compliance team:

- **Email:** `support@vidcut.app`
- **Alternative Email:** `vidcut.editor.team@gmail.com`
- **Developer Name:** VidCut Studio
- **Application:** VidCut: Video Editor & Maker (`com.vidcut.videoeditor`)
- **Website:** `https://vidcut.app`
