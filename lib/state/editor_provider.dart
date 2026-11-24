import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:uuid/uuid.dart';

import '../models/project.dart';
import '../models/video_clip.dart';
import '../models/audio_track.dart';
import '../models/text_layer.dart';
import '../models/sticker_layer.dart';
import '../core/constants.dart';
import '../services/project_storage_service.dart';

class EditorProvider extends ChangeNotifier {
  List<VideoProject> _projects = [];
  VideoProject? _currentProject;
  int _selectedClipIndex = 0;
  int _currentTimeMs = 0;
  bool _isPlaying = false;
  String _activeTool = 'none'; // 'none', 'trim', 'canvas', 'speed', 'filters', 'adjust', 'music', 'text', 'stickers', 'transition'

  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  Timer? _playbackTicker;

  // Undo / Redo history stacks (Zero-fear editing)
  final List<String> _undoStack = [];
  final List<String> _redoStack = [];

  // Getters
  List<VideoProject> get projects => _projects;
  VideoProject? get currentProject => _currentProject;
  int get selectedClipIndex => _selectedClipIndex;
  int get currentTimeMs => _currentTimeMs;
  bool get isPlaying => _isPlaying;
  String get activeTool => _activeTool;
  VideoPlayerController? get videoController => _videoController;
  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  VideoClip? get selectedClip {
    if (_currentProject == null || _currentProject!.clips.isEmpty) return null;
    if (_selectedClipIndex >= 0 && _selectedClipIndex < _currentProject!.clips.length) {
      return _currentProject!.clips[_selectedClipIndex];
    }
    return _currentProject!.clips.first;
  }

  EditorProvider() {
    loadProjects();
  }

  Future<void> loadProjects() async {
    _projects = await ProjectStorageService.loadAllProjects();
    notifyListeners();
  }

  void setActiveTool(String tool) {
    _activeTool = tool;
    notifyListeners();
  }

  Future<void> openProject(VideoProject project) async {
    _currentProject = project;
    _selectedClipIndex = 0;
    _currentTimeMs = 0;
    _isPlaying = false;
    _activeTool = 'none';

    await _initVideoForCurrentClip();
    notifyListeners();
  }

  Future<void> createNewProject({
    String name = 'New Edit',
    AspectRatioPreset ratio = AspectRatioPreset.ratio9_16,
    List<VideoClip>? initialClips,
  }) async {
    final newProj = VideoProject(
      id: const Uuid().v4(),
      name: name,
      aspectRatio: ratio,
      clips: initialClips ?? [],
    );

    _projects.insert(0, newProj);
    await ProjectStorageService.saveProject(newProj);
    await openProject(newProj);
  }

  Future<void> deleteProject(String id) async {
    await ProjectStorageService.deleteProject(id);
    _projects.removeWhere((p) => p.id == id);
    if (_currentProject?.id == id) {
      _currentProject = null;
      _disposeControllers();
    }
    notifyListeners();
  }

  Future<void> saveCurrentProject() async {
    if (_currentProject != null) {
      await ProjectStorageService.saveProject(_currentProject!);
    }
  }

  // Playback Control
  void togglePlay() {
    if (_isPlaying) {
      pause();
    } else {
      play();
    }
  }

  void play() {
    if (_currentProject == null || _currentProject!.clips.isEmpty) return;
    _isPlaying = true;

    // Start background music in exact lockstep
    if (_currentProject!.audioTracks.isNotEmpty && !_currentProject!.audioTracks.first.isMuted) {
      final track = _currentProject!.audioTracks.first;
      _audioPlayer.setVolume(track.volume.clamp(0.0, 1.0));
      _audioPlayer.seek(Duration(milliseconds: _currentTimeMs));
      _audioPlayer.play(UrlSource(track.audioUrl));
    }

    final clip = selectedClip;
    if (clip != null && !clip.isImage && _videoController != null && _videoController!.value.isInitialized) {
      _videoController!.setVolume(clip.isMuted ? 0.0 : clip.volume.clamp(0.0, 1.0));
      _videoController!.play();
    }

    _startPlaybackTicker();
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    _videoController?.pause();
    _audioPlayer.pause();
    _playbackTicker?.cancel();
    notifyListeners();
  }

  void seekTo(int ms) {
    if (_currentProject == null) return;
    final total = _currentProject!.totalDurationMs;
    _currentTimeMs = ms.clamp(0, total > 0 ? total : 0);

    // Sync active clip index based on playhead position
    _syncClipIndexToTime();

    // Calculate relative time inside current clip for millisecond-exact video seek
    int clipStartOnTimeline = 0;
    for (int i = 0; i < _selectedClipIndex; i++) {
      clipStartOnTimeline += _currentProject!.clips[i].effectiveDurationMs;
    }
    final offsetInsideClip = (_currentTimeMs - clipStartOnTimeline).clamp(0, 3600000);
    final clip = selectedClip;
    if (clip != null && !clip.isImage && _videoController != null && _videoController!.value.isInitialized) {
      final actualVideoMs = clip.trimStartMs + (offsetInsideClip * clip.speed).round();
      _videoController!.seekTo(Duration(milliseconds: actualVideoMs));
    }

    // Keep background audio in exact sync with playhead scrub
    if (_currentProject!.audioTracks.isNotEmpty) {
      _audioPlayer.seek(Duration(milliseconds: _currentTimeMs));
    }

    notifyListeners();
  }

  void _syncClipIndexToTime() {
    if (_currentProject == null || _currentProject!.clips.isEmpty) return;

    int accumulatedMs = 0;
    for (int i = 0; i < _currentProject!.clips.length; i++) {
      final clipDuration = _currentProject!.clips[i].effectiveDurationMs;
      if (_currentTimeMs >= accumulatedMs && _currentTimeMs < accumulatedMs + clipDuration) {
        if (_selectedClipIndex != i) {
          _selectedClipIndex = i;
          _initVideoForCurrentClip();
        }
        break;
      }
      accumulatedMs += clipDuration;
    }
  }

  void _startPlaybackTicker() {
    _playbackTicker?.cancel();
    _playbackTicker = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!_isPlaying || _currentProject == null) {
        timer.cancel();
        return;
      }

      final total = _currentProject!.totalDurationMs;
      if (total <= 0) return;

      _currentTimeMs += 50;
      if (_currentTimeMs >= total) {
        _currentTimeMs = 0;
        pause();
      } else {
        _syncClipIndexToTime();
      }
      notifyListeners();
    });
  }

  Future<void> _initVideoForCurrentClip() async {
    _videoController?.pause();
    await _videoController?.dispose();
    _videoController = null;

    final clip = selectedClip;
    if (clip == null || clip.isImage) return;

    try {
      if (clip.isRemote) {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(clip.path));
      } else {
        _videoController = VideoPlayerController.file(File(clip.path));
      }

      await _videoController!.initialize();
      _videoController!.setLooping(true);
      _videoController!.setVolume(clip.isMuted ? 0.0 : clip.volume.clamp(0.0, 1.0));
      _videoController!.setPlaybackSpeed(clip.speed.clamp(0.25, 4.0));
      if (_isPlaying) {
        _videoController!.play();
      }
    } catch (_) {}
  }

  void toggleMuteClip([int? clipIndex]) {
    final idx = clipIndex ?? _selectedClipIndex;
    if (_currentProject == null || idx >= _currentProject!.clips.length) return;
    _recordHistory();
    final clip = _currentProject!.clips[idx];
    clip.isMuted = !clip.isMuted;
    if (idx == _selectedClipIndex) {
      _videoController?.setVolume(clip.isMuted ? 0.0 : clip.volume.clamp(0.0, 1.0));
    }
    saveCurrentProject();
    notifyListeners();
  }

  // History recording for zero-fear editing
  void _recordHistory() {
    if (_currentProject != null) {
      _undoStack.add(jsonEncode(_currentProject!.toJson()));
      if (_undoStack.length > 25) {
        _undoStack.removeAt(0);
      }
      _redoStack.clear();
    }
  }

  void undo() {
    if (_undoStack.isNotEmpty && _currentProject != null) {
      _redoStack.add(jsonEncode(_currentProject!.toJson()));
      final previousState = _undoStack.removeLast();
      _currentProject = VideoProject.fromJson(jsonDecode(previousState));
      _selectedClipIndex = _selectedClipIndex.clamp(0, (_currentProject!.clips.length - 1).clamp(0, 999));
      _initVideoForCurrentClip();
      saveCurrentProject();
      notifyListeners();
    }
  }

  void redo() {
    if (_redoStack.isNotEmpty && _currentProject != null) {
      _undoStack.add(jsonEncode(_currentProject!.toJson()));
      final nextState = _redoStack.removeLast();
      _currentProject = VideoProject.fromJson(jsonDecode(nextState));
      _selectedClipIndex = _selectedClipIndex.clamp(0, (_currentProject!.clips.length - 1).clamp(0, 999));
      _initVideoForCurrentClip();
      saveCurrentProject();
      notifyListeners();
    }
  }

  // Timeline & Editing Tools
  void selectClip(int index) {
    if (_currentProject == null) return;
    if (index >= 0 && index < _currentProject!.clips.length) {
      _selectedClipIndex = index;
      _initVideoForCurrentClip();
      notifyListeners();
    }
  }

  void addClips(List<VideoClip> newClips) {
    if (_currentProject == null) return;
    _recordHistory();
    _currentProject!.clips.addAll(newClips);
    if (_currentProject!.thumbnailUrl.isEmpty && newClips.isNotEmpty) {
      _currentProject!.thumbnailUrl = newClips.first.thumbnailUrl;
    }
    saveCurrentProject();
    notifyListeners();
  }

  void removeClip(int index) {
    if (_currentProject == null || _currentProject!.clips.isEmpty) return;
    if (index >= 0 && index < _currentProject!.clips.length) {
      _recordHistory();
      _currentProject!.clips.removeAt(index);
      if (_selectedClipIndex >= _currentProject!.clips.length) {
        _selectedClipIndex = (_currentProject!.clips.length - 1).clamp(0, 999);
      }
      _initVideoForCurrentClip();
      saveCurrentProject();
      notifyListeners();
    }
  }

  void reorderClips(int oldIndex, int newIndex) {
    if (_currentProject == null) return;
    _recordHistory();
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _currentProject!.clips.removeAt(oldIndex);
    _currentProject!.clips.insert(newIndex, item);
    _selectedClipIndex = newIndex;
    saveCurrentProject();
    notifyListeners();
  }

  void splitClipAtPlayhead() {
    if (_currentProject == null || selectedClip == null) return;
    final clip = selectedClip!;

    _recordHistory();

    // Calculate exact playhead position relative to this clip
    int clipStartOnTimeline = 0;
    for (int i = 0; i < _selectedClipIndex; i++) {
      clipStartOnTimeline += _currentProject!.clips[i].effectiveDurationMs;
    }

    final offsetWithinClipMs = _currentTimeMs - clipStartOnTimeline;
    final effectiveDuration = clip.effectiveDurationMs;

    int splitOffsetMs;
    // If the playhead is located inside this clip with at least 250ms on each side
    if (offsetWithinClipMs >= 250 && offsetWithinClipMs <= effectiveDuration - 250) {
      splitOffsetMs = (offsetWithinClipMs * clip.speed).round();
    } else {
      // Fallback to exact midpoint
      splitOffsetMs = ((clip.trimEndMs - clip.trimStartMs) / 2).round();
    }

    final clipA = clip.copyWith(
      id: const Uuid().v4(),
      trimEndMs: clip.trimStartMs + splitOffsetMs,
    );

    final clipB = clip.copyWith(
      id: const Uuid().v4(),
      trimStartMs: clip.trimStartMs + splitOffsetMs,
    );

    _currentProject!.clips.removeAt(_selectedClipIndex);
    _currentProject!.clips.insert(_selectedClipIndex, clipA);
    _currentProject!.clips.insert(_selectedClipIndex + 1, clipB);

    _initVideoForCurrentClip();
    saveCurrentProject();
    notifyListeners();
  }

  void updateTrim(int clipIndex, int startMs, int endMs) {
    if (_currentProject == null || clipIndex >= _currentProject!.clips.length) return;
    _recordHistory();
    final clip = _currentProject!.clips[clipIndex];
    clip.trimStartMs = startMs.clamp(0, clip.durationMs);
    clip.trimEndMs = endMs.clamp(clip.trimStartMs + 200, clip.durationMs);
    saveCurrentProject();
    notifyListeners();
  }

  void updateClipSpeed(int clipIndex, double speed) {
    if (_currentProject == null || clipIndex >= _currentProject!.clips.length) return;
    _recordHistory();
    _currentProject!.clips[clipIndex].speed = speed;
    _videoController?.setPlaybackSpeed(speed.clamp(0.25, 4.0));
    saveCurrentProject();
    notifyListeners();
  }

  void updateClipVolume(int clipIndex, double volume, bool isMuted) {
    if (_currentProject == null || clipIndex >= _currentProject!.clips.length) return;
    final clip = _currentProject!.clips[clipIndex];
    clip.volume = volume;
    clip.isMuted = isMuted;
    _videoController?.setVolume(isMuted ? 0.0 : volume.clamp(0.0, 1.0));
    saveCurrentProject();
    notifyListeners();
  }

  void setClipFilter(int clipIndex, String filterId) {
    if (_currentProject == null || clipIndex >= _currentProject!.clips.length) return;
    _recordHistory();
    _currentProject!.clips[clipIndex].filterId = filterId;
    saveCurrentProject();
    notifyListeners();
  }

  void updateClipAdjustments(int clipIndex, {double? brightness, double? contrast, double? saturation}) {
    if (_currentProject == null || clipIndex >= _currentProject!.clips.length) return;
    _recordHistory();
    final clip = _currentProject!.clips[clipIndex];
    if (brightness != null) clip.brightness = brightness;
    if (contrast != null) clip.contrast = contrast;
    if (saturation != null) clip.saturation = saturation;
    saveCurrentProject();
    notifyListeners();
  }

  void rotateClip(int clipIndex) {
    if (_currentProject == null || clipIndex >= _currentProject!.clips.length) return;
    _recordHistory();
    final clip = _currentProject!.clips[clipIndex];
    clip.rotationDegrees = (clip.rotationDegrees + 90) % 360;
    saveCurrentProject();
    notifyListeners();
  }

  void flipClip(int clipIndex) {
    if (_currentProject == null || clipIndex >= _currentProject!.clips.length) return;
    _recordHistory();
    final clip = _currentProject!.clips[clipIndex];
    clip.isFlippedHorizontally = !clip.isFlippedHorizontally;
    saveCurrentProject();
    notifyListeners();
  }

  void setTransition(int clipIndex, VideoTransitionType transition) {
    if (_currentProject == null || clipIndex >= _currentProject!.clips.length) return;
    _recordHistory();
    _currentProject!.clips[clipIndex].transition = transition;
    saveCurrentProject();
    notifyListeners();
  }

  void setTransitionToAll(VideoTransitionType transition) {
    if (_currentProject == null) return;
    _recordHistory();
    for (final clip in _currentProject!.clips) {
      clip.transition = transition;
    }
    saveCurrentProject();
    notifyListeners();
  }

  void reverseClip([int? clipIndex]) {
    final idx = clipIndex ?? _selectedClipIndex;
    if (_currentProject == null || idx >= _currentProject!.clips.length) return;
    _recordHistory();
    final clip = _currentProject!.clips[idx];
    final originalStart = clip.trimStartMs;
    clip.trimStartMs = (clip.durationMs - clip.trimEndMs).clamp(0, clip.durationMs);
    clip.trimEndMs = (clip.durationMs - originalStart).clamp(clip.trimStartMs + 200, clip.durationMs);
    saveCurrentProject();
    notifyListeners();
  }

  Future<bool> extractAndAddAudioFromVideo(String videoPath, [String? title]) async {
    if (_currentProject == null) return false;
    try {
      final cacheDir = await getTemporaryDirectory();
      final id = const Uuid().v4();
      final outputPath = '${cacheDir.path}/extracted_${id}.m4a';
      const platform = MethodChannel('com.vidcut.videoeditor/media_engine');
      final resultPath = await platform.invokeMethod<String>('extractAudioFromVideo', {
        'videoPath': videoPath,
        'outputPath': outputPath,
      });

      if (resultPath != null && await File(resultPath).exists() && await File(resultPath).length() > 0) {
        final track = AudioTrack(
          id: id,
          title: title ?? 'Extracted Audio',
          artist: 'Extracted from Video',
          audioUrl: resultPath,
          durationMs: _currentProject!.totalDurationMs,
          volume: 1.0,
        );
        addAudioTrack(track);
        return true;
      }
    } catch (e) {
      debugPrint('Error extracting audio from video: $e');
    }
    return false;
  }

  void setAspectRatio(AspectRatioPreset ratio) {
    if (_currentProject == null) return;
    _recordHistory();
    _currentProject!.aspectRatio = ratio;
    saveCurrentProject();
    notifyListeners();
  }

  // Audio Layers
  void addAudioTrack(AudioTrack track) {
    if (_currentProject == null) return;
    _recordHistory();
    _currentProject!.audioTracks.add(track);
    saveCurrentProject();
    notifyListeners();
  }

  void removeAudioTrack(String id) {
    if (_currentProject == null) return;
    _recordHistory();
    _currentProject!.audioTracks.removeWhere((a) => a.id == id);
    saveCurrentProject();
    notifyListeners();
  }

  // Text Layers
  void addTextLayer(TextLayer layer) {
    if (_currentProject == null) return;
    _recordHistory();
    _currentProject!.textLayers.add(layer);
    saveCurrentProject();
    notifyListeners();
  }

  void updateTextLayer(TextLayer layer) {
    if (_currentProject == null) return;
    _recordHistory();
    final idx = _currentProject!.textLayers.indexWhere((t) => t.id == layer.id);
    if (idx != -1) {
      _currentProject!.textLayers[idx] = layer;
      saveCurrentProject();
      notifyListeners();
    }
  }

  void removeTextLayer(String id) {
    if (_currentProject == null) return;
    _recordHistory();
    _currentProject!.textLayers.removeWhere((t) => t.id == id);
    saveCurrentProject();
    notifyListeners();
  }

  // Sticker Layers
  void addStickerLayer(StickerLayer layer) {
    if (_currentProject == null) return;
    _recordHistory();
    _currentProject!.stickerLayers.add(layer);
    saveCurrentProject();
    notifyListeners();
  }

  void removeStickerLayer(String id) {
    if (_currentProject == null) return;
    _recordHistory();
    _currentProject!.stickerLayers.removeWhere((s) => s.id == id);
    saveCurrentProject();
    notifyListeners();
  }

  void _disposeControllers() {
    _playbackTicker?.cancel();
    _videoController?.dispose();
    _videoController = null;
    _audioPlayer.stop();
  }

  @override
  void dispose() {
    _disposeControllers();
    _audioPlayer.dispose();
    super.dispose();
  }
}
