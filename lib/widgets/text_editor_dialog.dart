import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../state/editor_provider.dart';
import '../models/text_layer.dart';
import '../core/theme.dart';

class TextEditorDialog extends StatefulWidget {
  final EditorProvider provider;
  final TextLayer? existingLayer;

  const TextEditorDialog({
    super.key,
    required this.provider,
    this.existingLayer,
  });

  @override
  State<TextEditorDialog> createState() => _TextEditorDialogState();
}

class _TextEditorDialogState extends State<TextEditorDialog> {
  late TextEditingController _textController;
  late double _fontSize;
  late Color _selectedColor;
  late bool _hasBackground;
  late bool _isBold;
  late bool _isItalic;

  final List<Color> _colorPalette = [
    Colors.white,
    const Color(0xFFFACC15), // Vibrant Yellow
    const Color(0xFF06B6D4), // Cyber Cyan
    const Color(0xFFF43F5E), // Coral Pink
    const Color(0xFF10B981), // Emerald Green
    const Color(0xFF8B5CF6), // Electric Violet
    Colors.black,
  ];

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.existingLayer?.text ?? 'Reel Title ✨');
    _fontSize = widget.existingLayer?.fontSize ?? 26.0;
    _selectedColor = widget.existingLayer?.color ?? Colors.white;
    _hasBackground = widget.existingLayer?.hasBackground ?? true;
    _isBold = widget.existingLayer?.isBold ?? true;
    _isItalic = widget.existingLayer?.isItalic ?? false;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppTheme.stroke, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.title, color: AppTheme.primaryLight, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Animated Text & Subtitle',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20, color: Colors.white70),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Live Preview Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.stroke),
              ),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _hasBackground ? Colors.black87 : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    _textController.text.isEmpty ? 'Your Text Here' : _textController.text,
                    style: TextStyle(
                      fontSize: _fontSize * 0.7,
                      color: _selectedColor,
                      fontWeight: _isBold ? FontWeight.bold : FontWeight.normal,
                      fontStyle: _isItalic ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Text Input Field
            TextField(
              controller: _textController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.surfaceCard,
                hintText: 'Enter caption or title...',
                hintStyle: const TextStyle(color: AppTheme.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.stroke),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.stroke),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),

            // Font Size Slider
            Row(
              children: [
                const Icon(Icons.format_size, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                const Text('Size:', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 14.0,
                    max: 42.0,
                    divisions: 14,
                    onChanged: (val) => setState(() => _fontSize = val),
                  ),
                ),
                Text(
                  '${_fontSize.toInt()}px',
                  style: const TextStyle(fontSize: 12, color: AppTheme.cyan, fontWeight: FontWeight.bold),
                ),
              ],
            ),

            // Style Toggles (Bold, Italic, Background)
            Row(
              children: [
                FilterChip(
                  label: const Text('Bold'),
                  selected: _isBold,
                  selectedColor: AppTheme.primary,
                  checkmarkColor: Colors.white,
                  onSelected: (val) => setState(() => _isBold = val),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Italic'),
                  selected: _isItalic,
                  selectedColor: AppTheme.primary,
                  checkmarkColor: Colors.white,
                  onSelected: (val) => setState(() => _isItalic = val),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Box Badge'),
                  selected: _hasBackground,
                  selectedColor: AppTheme.cyan,
                  checkmarkColor: Colors.white,
                  onSelected: (val) => setState(() => _hasBackground = val),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Color Swatches
            SizedBox(
              height: 36,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colorPalette.length,
                itemBuilder: (context, index) {
                  final color = _colorPalette[index];
                  final isSelected = color == _selectedColor;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? Colors.white : Colors.white24,
                          width: isSelected ? 2.5 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              size: 16,
                              color: color == Colors.white ? Colors.black : Colors.white,
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // Actions
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  final text = _textController.text.trim();
                  if (text.isEmpty) return;

                  if (widget.existingLayer != null) {
                    widget.existingLayer!.text = text;
                    widget.existingLayer!.fontSize = _fontSize;
                    widget.existingLayer!.color = _selectedColor;
                    widget.existingLayer!.hasBackground = _hasBackground;
                    widget.existingLayer!.isBold = _isBold;
                    widget.existingLayer!.isItalic = _isItalic;
                    widget.provider.updateTextLayer(widget.existingLayer!);
                  } else {
                    widget.provider.addTextLayer(
                      TextLayer(
                        id: const Uuid().v4(),
                        text: text,
                        fontSize: _fontSize,
                        color: _selectedColor,
                        hasBackground: _hasBackground,
                        isBold: _isBold,
                        isItalic: _isItalic,
                        startOnTimelineMs: widget.provider.currentTimeMs,
                      ),
                    );
                  }
                  Navigator.pop(context);
                },
                child: const Text('Add Text Layer ✨'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
