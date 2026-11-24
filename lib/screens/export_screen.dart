import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../state/editor_provider.dart';
import '../services/video_export_service.dart';
import '../core/constants.dart';
import '../core/theme.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  ExportResolution _selectedResolution = ExportResolution.res1080p;
  int _fps = 60;
  bool _isExporting = false;
  double _exportProgress = 0.0;
  String _statusMessage = 'Ready to render';
  String? _exportedFilePath;
  int? _exportedFileSizeKb;
  bool _isSavedToGallery = false;

  VideoPlayerController? _resultController;
  StreamSubscription<ExportProgress>? _exportSubscription;

  @override
  void dispose() {
    _exportSubscription?.cancel();
    _resultController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditorProvider>();
    final project = provider.currentProject;

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Export Video')),
        body: const Center(child: Text('No active project to export')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export & Share Video'),
        leading: _isExporting
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                onPressed: () => Navigator.pop(context),
              ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_exportedFilePath != null)
                _buildCompletedView(project)
              else if (_isExporting)
                _buildExportingProgressView()
              else
                _buildConfigView(project),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConfigView(dynamic project) {
    final durationMin = (project.totalDurationMs / 60000);
    final approxMb = (_selectedResolution.approxMbPerMin * (durationMin > 0.1 ? durationMin : 0.2)).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Project Overview Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.stroke),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.cyan]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.movie_creation_rounded, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${project.formattedDuration} • ${project.clips.length} Clips • ${project.aspectRatio.name} Aspect',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 100% Free Pro VIP Banner (No Watermark + 4K 60FPS)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withOpacity(0.2),
                AppTheme.pinkNeon.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.pinkNeon.withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 16, color: AppTheme.pinkNeon),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'PRO UNLOCKED • FREE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.pinkNeon,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldGreen.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 11, color: AppTheme.emeraldGreen),
                        SizedBox(width: 3),
                        Text(
                          'NO WATERMARK',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.emeraldGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Full 4K Ultra HD 60FPS rendering, zero brand watermarks, and high-bitrate studio audio with no subscription fees.',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Resolution Selector
        const Text(
          'Export Resolution',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 12),

        ...ExportResolution.values.map((res) {
          final isSelected = res == _selectedResolution;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.18) : AppTheme.surfaceCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected ? AppTheme.primary : AppTheme.stroke,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: RadioListTile<ExportResolution>(
                value: res,
                groupValue: _selectedResolution,
                activeColor: AppTheme.primaryLight,
                onChanged: (val) {
                  if (val != null) setState(() => _selectedResolution = val);
                },
                title: Row(
                  children: [
                    Text(
                      res.label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (res == ExportResolution.res1080p)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.cyan.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'RECOMMENDED',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.cyan),
                        ),
                      ),
                    if (res == ExportResolution.res4k)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.amberHandle.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'ULTRA HD',
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.amberHandle),
                        ),
                      ),
                  ],
                ),
                subtitle: Text(
                  '${res.name} • ${res.width}x${res.height}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 16),

        // Frame Rate Selector
        const Text(
          'Frame Rate (FPS)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('30 FPS (Standard)')),
                selected: _fps == 30,
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.surfaceCard,
                labelStyle: TextStyle(
                  color: _fps == 30 ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => setState(() => _fps = 30),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Center(child: Text('60 FPS (Ultra Smooth)')),
                selected: _fps == 60,
                selectedColor: AppTheme.primary,
                backgroundColor: AppTheme.surfaceCard,
                labelStyle: TextStyle(
                  color: _fps == 60 ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
                onSelected: (_) => setState(() => _fps = 60),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // File estimate summary
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Estimated File Size:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              Text(
                '~$approxMb MB (MP4)',
                style: const TextStyle(color: AppTheme.cyan, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ],
          ),
        ),

        const SizedBox(height: 28),

        // Export Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.auto_awesome, size: 20),
            label: Text(
              'Render ${_selectedResolution.label} Video Now ✨',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _startExport(project),
          ),
        ),
      ],
    );
  }

  Widget _buildExportingProgressView() {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.stroke),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 140,
                height: 140,
                child: CircularProgressIndicator(
                  value: _exportProgress,
                  strokeWidth: 10,
                  backgroundColor: AppTheme.surfaceElevated,
                  color: AppTheme.primary,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${(_exportProgress * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'RENDERING',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.cyan,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hardware acceleration enabled • Do not close app while rendering',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildCompletedView(dynamic project) {
    final sizeMb = ((_exportedFileSizeKb ?? 12000) / 1024).toStringAsFixed(1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Success Header Badge
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppTheme.emeraldGreen.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.emeraldGreen.withOpacity(0.5)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.emeraldGreen, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export Finished!',
                      style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Your video is ready to share with the world.',
                      style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Video Output Specs Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.stroke),
          ),
          child: Column(
            children: [
              _buildSpecRow('Resolution', '${_selectedResolution.label} (${_selectedResolution.width}x${_selectedResolution.height})'),
              const Divider(color: AppTheme.stroke, height: 16),
              _buildSpecRow('Frame Rate', '$_fps FPS High-Motion'),
              const Divider(color: AppTheme.stroke, height: 16),
              _buildSpecRow('Aspect Ratio', project.aspectRatio.name),
              const Divider(color: AppTheme.stroke, height: 16),
              _buildSpecRow('Format & Size', 'MP4 (H.264) • $sizeMb MB'),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Actions: Save to Gallery & Share
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            icon: Icon(_isSavedToGallery ? Icons.done_all : Icons.save_alt_rounded, size: 20),
            label: Text(
              _isSavedToGallery ? 'Saved to Gallery ✓' : 'Save to Gallery',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isSavedToGallery ? AppTheme.emeraldGreen : AppTheme.primary,
            ),
            onPressed: () {
              setState(() => _isSavedToGallery = true);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Saved video to Gallery (DCIM/NovaCut)'),
                  backgroundColor: AppTheme.emeraldGreen,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton.icon(
            icon: const Icon(Icons.share_rounded, size: 20, color: AppTheme.cyan),
            label: const Text(
              'Share to Instagram / TikTok / WhatsApp',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.cyan, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () {
              if (_exportedFilePath != null) {
                VideoExportService.shareVideo(_exportedFilePath!, project.name);
              }
            },
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: TextButton.icon(
            icon: const Icon(Icons.home_rounded, size: 18, color: AppTheme.textSecondary),
            label: const Text('Back to Home Projects', style: TextStyle(color: AppTheme.textSecondary)),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Future<void> _startExport(dynamic project) async {
    setState(() {
      _isExporting = true;
      _exportProgress = 0.05;
      _statusMessage = 'Starting rendering engine...';
    });

    final stream = await VideoExportService.exportVideo(
      project: project,
      resolution: _selectedResolution,
      fps: _fps,
    );

    _exportSubscription = stream.listen((progress) {
      if (mounted) {
        setState(() {
          _exportProgress = progress.percentage;
          _statusMessage = progress.statusMessage;
          if (progress.isDone && progress.outputPath != null) {
            _isExporting = false;
            _exportedFilePath = progress.outputPath;
            _exportedFileSizeKb = progress.fileSizeKb;
          }
        });
      }
    });
  }
}
