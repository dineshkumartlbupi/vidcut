# Google Play Console Data Safety & Content Rating Questionnaire Guide — VidCut

When submitting **VidCut: Video Editor & Maker** (`com.vidcut.videoeditor`) in Google Play Console, use the following exact responses to pass review smoothly on first submission:

---

## 1. Data Safety Section

### A. Data Collection and Security
- **Does your app collect or share any of the required user data types?**  
  👉 **No** (All video editing, trimming, filters, audio mixing, and export processing occurs strictly locally on the user's device).
- **Is all of the user data collected by your app encrypted in transit?**  
  👉 **Yes** (Any network requests, such as loading royalty-free assets, use secure HTTPS/TLS 1.3).
- **Do you provide a way for users to request that their data be deleted?**  
  👉 **Yes** (Users can delete any saved project, audio, or draft directly within the app at any time by clearing project data or clearing app storage).

---

## 2. Permissions Declarations

### A. Media Permissions (`READ_MEDIA_VIDEO`, `READ_MEDIA_IMAGES`, `READ_MEDIA_AUDIO`)
- **Question:** What is the primary purpose for accessing media?  
  👉 **In-app Functionality (Video Editing & Media Splicing).** Users select media from their gallery to edit, trim, and composite into video projects.
- **Is this data collected or shared?**  
  👉 **No.** It is processed on-device and never sent to remote servers.

### B. Camera & Microphone (`CAMERA`, `RECORD_AUDIO`)
- **Question:** Why does the app request camera and mic access?  
  👉 **Optional User-Initiated Capture.** Users can record video clips or voiceover tracks directly into the project timeline.

---

## 3. Content Rating Questionnaire (IARC)
- **Violence:** No
- **Sexual Content:** No
- **Profanity / Crude Humor:** No
- **Controlled Substances:** No
- **Age Rating Result:** **PEGI 3 / Everyone (All ages)**

---

## 4. Target Audience
- **Target Age Group:** 13 and older (Teens, Young Adults, Creators)
- **Is your app designed for children?** 👉 **No**

---

## 5. Photo and Video Permissions Declaration (New Google Play Policy)

### Box 1: Read media images (Max 250 chars)
```
VidCut is a video editor requiring persistent access to photos for multi-clip slideshow reels, timeline thumbnail caching, and real-time PIP overlays, which one-time system pickers cannot sustain for continuous non-linear project editing.
```
*(Length: 238 / 250 characters)*

### Box 2: Read media video (Max 250 chars)
```
VidCut is a video editor requiring persistent file access for multi-track timeline decoding, millisecond frame scrubbing, audio extraction, and 4K GPU rendering, which one-time system pickers cannot sustain for non-linear multi-clip editing.
```
*(Length: 241 / 250 characters)*
