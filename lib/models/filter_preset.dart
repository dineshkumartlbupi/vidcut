import 'package:flutter/material.dart';

class FilterPreset {
  final String id;
  final String name;
  final String description;
  final List<double> matrix;
  final Color previewColor;

  const FilterPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.matrix,
    required this.previewColor,
  });

  static const FilterPreset none = FilterPreset(
    id: 'none',
    name: 'Original',
    description: 'Natural unfiltered camera look',
    previewColor: Colors.grey,
    matrix: [
      1, 0, 0, 0, 0,
      0, 1, 0, 0, 0,
      0, 0, 1, 0, 0,
      0, 0, 0, 1, 0,
    ],
  );

  static const List<FilterPreset> all = [
    none,
    FilterPreset(
      id: 'vibrant',
      name: 'Vibrant Pop',
      description: 'Lush colors, rich saturation & depth',
      previewColor: Color(0xFFF97316),
      matrix: [
        1.3, -0.1, -0.1, 0, 10,
        -0.1, 1.3, -0.1, 0, 10,
        -0.1, -0.1, 1.3, 0, 10,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterPreset(
      id: 'teal_orange',
      name: 'Teal & Orange',
      description: 'Hollywood blockbuster cinema color grade',
      previewColor: Color(0xFF0EA5E9),
      matrix: [
        1.25, 0.0, 0.0, 0, 18,
        0.0, 1.1, 0.0, 0, 5,
        -0.1, 0.2, 1.3, 0, 22,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterPreset(
      id: 'vintage',
      name: 'Vintage 90s',
      description: 'Warm nostalgic 35mm film grain tone',
      previewColor: Color(0xFFD97706),
      matrix: [
        1.1, 0.1, 0.0, 0, 25,
        0.05, 1.0, 0.0, 0, 15,
        0.0, 0.0, 0.85, 0, -10,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterPreset(
      id: 'noir',
      name: 'Film Noir B&W',
      description: 'High-contrast monochrome dramatic grading',
      previewColor: Color(0xFF334155),
      matrix: [
        0.299 * 1.3, 0.587 * 1.3, 0.114 * 1.3, 0, -15,
        0.299 * 1.3, 0.587 * 1.3, 0.114 * 1.3, 0, -15,
        0.299 * 1.3, 0.587 * 1.3, 0.114 * 1.3, 0, -15,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterPreset(
      id: 'cyberpunk',
      name: 'Cyberpunk Neon',
      description: 'Electric violet, ultraviolet and neon tones',
      previewColor: Color(0xFF8B5CF6),
      matrix: [
        1.15, -0.05, 0.1, 0, 15,
        -0.05, 0.85, 0.1, 0, -10,
        0.1, 0.0, 1.45, 0, 30,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterPreset(
      id: 'golden_hour',
      name: 'Golden Hour',
      description: 'Warm golden sunlight aesthetic',
      previewColor: Color(0xFFEAB308),
      matrix: [
        1.25, 0.05, -0.05, 0, 20,
        0.0, 1.15, -0.05, 0, 15,
        -0.05, -0.05, 0.8, 0, -10,
        0, 0, 0, 1, 0,
      ],
    ),
    FilterPreset(
      id: 'cold_fade',
      name: 'Cold Glacier',
      description: 'Crisp chilled Nordic mountain tones',
      previewColor: Color(0xFF38BDF8),
      matrix: [
        0.85, 0.0, 0.0, 0, -10,
        0.0, 1.05, 0.05, 0, 5,
        0.05, 0.1, 1.35, 0, 25,
        0, 0, 0, 1, 0,
      ],
    ),
  ];
}
