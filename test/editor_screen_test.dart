import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vidcut/state/editor_provider.dart';
import 'package:vidcut/models/video_clip.dart';
import 'package:vidcut/screens/editor_screen.dart';
import 'package:vidcut/screens/export_screen.dart';
import 'package:vidcut/core/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers.global'), (MethodCall methodCall) async {
      return 1;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('xyz.luan/audioplayers'), (MethodCall methodCall) async {
      return 1;
    });

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('flutter.io/videoPlayer'), (MethodCall methodCall) async {
      if (methodCall.method == 'init') return null;
      if (methodCall.method == 'create') return {'textureId': 0};
      return null;
    });
  });

  Widget buildTestableWidget({required Widget child, required EditorProvider provider}) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: ChangeNotifierProvider<EditorProvider>.value(
        value: provider,
        child: child,
      ),
    );
  }

  group('EditorScreen UI & UX Tests', () {
    late EditorProvider provider;

    setUp(() async {
      provider = EditorProvider();
      final clip = VideoClip(
        id: 'clip_ui_test',
        title: 'Cyberpunk Drone Shot',
        path: 'https://sample.com/cyberpunk.mp4',
        durationMs: 12000,
        trimStartMs: 0,
        trimEndMs: 12000,
        isRemote: true,
      );

      await provider.createNewProject(
        name: 'Cyberpunk Reel Test',
        ratio: AspectRatioPreset.ratio9_16,
        initialClips: [clip],
      );
    });

    testWidgets('EditorScreen displays header, project name, tips button, and export button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(child: const EditorScreen(), provider: provider));
      await tester.pumpAndSettle();

      expect(find.text('Cyberpunk Reel Test'), findsOneWidget);
      expect(find.text('9:16'), findsWidgets);
      expect(find.text('Export'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('Quick Tips bottom sheet opens and displays helpful beginner cues', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(child: const EditorScreen(), provider: provider));
      await tester.pumpAndSettle();

      // Tap Quick Tips button
      await tester.tap(find.byIcon(Icons.lightbulb_outline));
      await tester.pumpAndSettle();

      expect(find.text('Quick Editing Tips (Zero Effort!)'), findsOneWidget);
      expect(find.text('Got it! Start Creating ✨'), findsOneWidget);
    });

    testWidgets('Timeline displays Split Here button, Undo/Redo, and Audio/Text tracks', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(child: const EditorScreen(), provider: provider));
      await tester.pumpAndSettle();

      // Prominent Split Here button
      expect(find.text('Split Here'), findsOneWidget);

      // Direct 1-tap audio & text cues
      expect(find.text('Tap to Add Music or SFX 🎵'), findsOneWidget);
      expect(find.text('Tap to Add Text / Subtitle 💬'), findsOneWidget);

      // Bottom editing toolbar categories
      expect(find.text('Split'), findsWidgets);
      expect(find.text('Speed'), findsOneWidget);
      expect(find.text('Filters'), findsOneWidget);
      expect(find.text('Audio'), findsOneWidget);
      expect(find.text('Text'), findsOneWidget);
      expect(find.text('Stickers'), findsOneWidget);
      expect(find.text('Canvas'), findsOneWidget);
    });

    testWidgets('Tapping Filters opens the horizontal LUT drawer', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(child: const EditorScreen(), provider: provider));
      await tester.pumpAndSettle();

      // Tap Filters in toolbar
      await tester.tap(find.byIcon(Icons.auto_fix_high_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Cinematic Filters & LUTs'), findsOneWidget);
      expect(find.text('Teal & Orange'), findsOneWidget);
      expect(find.text('Cyberpunk Neon'), findsOneWidget);
    });

    testWidgets('Tapping Mute button toggles clip audio mute state', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(child: const EditorScreen(), provider: provider));
      await tester.pumpAndSettle();

      expect(provider.selectedClip?.isMuted, false);
      expect(find.text('Mute'), findsWidgets);

      // Tap Mute in timeline quick tools
      await tester.tap(find.text('Mute').first);
      await tester.pumpAndSettle();

      expect(provider.selectedClip?.isMuted, true);
      expect(find.text('Original video audio muted (0% volume)'), findsOneWidget);
    });

    test('VideoClip correctly identifies photo files with isImage property', () {
      final photoClip = VideoClip(
        id: 'photo_1',
        path: '/storage/DCIM/Camera/IMG_2026.JPG',
        isRemote: false,
        durationMs: 3500,
        title: 'Sunset Photo',
      );
      final videoClip = VideoClip(
        id: 'video_1',
        path: '/storage/DCIM/Camera/VID_2026.mp4',
        isRemote: false,
        durationMs: 12000,
        title: 'City Walk',
      );

      expect(photoClip.isImage, true);
      expect(videoClip.isImage, false);
    });
  });

  group('ExportScreen UI Tests', () {
    late EditorProvider provider;

    setUp(() async {
      provider = EditorProvider();
      await provider.createNewProject(name: 'Export Ready Project');
    });

    testWidgets('ExportScreen displays resolution, FPS, and Start Rendering button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestableWidget(child: const ExportScreen(), provider: provider));
      await tester.pumpAndSettle();

      expect(find.text('Export & Share Video'), findsOneWidget);
      expect(find.text('Export Resolution'), findsOneWidget);
      expect(find.text('Frame Rate (FPS)'), findsOneWidget);
      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });
  });
}
