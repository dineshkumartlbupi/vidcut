import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vidcut/main.dart';
import 'package:vidcut/state/editor_provider.dart';
import 'package:vidcut/models/video_clip.dart';
import 'package:vidcut/models/text_layer.dart';
import 'package:vidcut/models/audio_track.dart';
import 'package:vidcut/core/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('VidCut app smoke test & beginner UI presence', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => EditorProvider()),
        ],
        child: const VidCutApp(),
      ),
    );

    // Verify Brand title & Beginner UI cues
    expect(find.text('VidCut'), findsOneWidget);
    expect(find.text('Easy Guide'), findsOneWidget);
    expect(find.text('1-Tap Viral Reel Presets'), findsOneWidget);
  });

  group('EditorProvider - Zero-Learning UI/UX Logic Tests', () {
    late EditorProvider provider;

    setUp(() {
      provider = EditorProvider();
    });

    test('Project creation and accurate split at playhead with Undo/Redo', () async {
      // 1. Create a project with a 10-second clip
      final clip = VideoClip(
        id: 'clip_1',
        title: 'Test Clip',
        path: 'https://sample.com/video.mp4',
        durationMs: 10000,
        trimStartMs: 0,
        trimEndMs: 10000,
        isRemote: true,
      );

      await provider.createNewProject(
        name: 'My Viral Edit',
        ratio: AspectRatioPreset.ratio9_16,
        initialClips: [clip],
      );

      expect(provider.currentProject, isNotNull);
      expect(provider.currentProject!.clips.length, 1);
      expect(provider.canUndo, isFalse);

      // 2. Seek playhead to 4.0s (4000ms) and split
      provider.seekTo(4000);
      provider.splitClipAtPlayhead();

      // Should now have 2 clips
      expect(provider.currentProject!.clips.length, 2);
      expect(provider.canUndo, isTrue);

      // 3. Test Undo (Zero-fear editing)
      provider.undo();
      expect(provider.currentProject!.clips.length, 1);
      expect(provider.canRedo, isTrue);

      // 4. Test Redo
      provider.redo();
      expect(provider.currentProject!.clips.length, 2);
    });

    test('Interactive trim updates clip duration', () async {
      final clip = VideoClip(
        id: 'clip_trim',
        title: 'Trimmable Clip',
        path: 'https://sample.com/video.mp4',
        durationMs: 15000,
        trimStartMs: 0,
        trimEndMs: 15000,
        isRemote: true,
      );

      await provider.createNewProject(
        name: 'Trim Test',
        initialClips: [clip],
      );

      // Trim from 2s to 8s (6s effective duration)
      provider.updateTrim(0, 2000, 8000);
      expect(provider.selectedClip!.effectiveDurationMs, 6000);
    });

    test('Add styled text layer and audio track', () async {
      await provider.createNewProject(name: 'Layers Test');

      // Add text hook
      provider.addTextLayer(
        TextLayer(
          id: 'text_1',
          text: '🔥 WAIT FOR IT...',
          fontSize: 28,
        ),
      );
      expect(provider.currentProject!.textLayers.length, 1);
      expect(provider.currentProject!.textLayers.first.text, '🔥 WAIT FOR IT...');

      // Add music track
      provider.addAudioTrack(
        AudioTrack(
          id: 'audio_1',
          title: 'Cyberpunk Phonk Beat',
          artist: 'Trending Music',
          audioUrl: 'https://sample.com/beat.mp3',
          durationMs: 30000,
        ),
      );
      expect(provider.currentProject!.audioTracks.length, 1);
    });
  });
}
