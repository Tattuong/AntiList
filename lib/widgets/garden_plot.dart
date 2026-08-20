import 'package:flutter/material.dart';

import '../models/garden.dart';

class GardenPlot extends StatelessWidget {
  final GardenBed bed;
  final void Function(int index) onTapCell;

  const GardenPlot({super.key, required this.bed, required this.onTapCell});

  static const _letters = ['A', 'B', 'C', 'D', 'E', 'F'];
  static const _labelStyle = TextStyle(
    color: Color(0xFFF6E7C8),
    fontWeight: FontWeight.w800,
    fontSize: 11,
    height: 1,
    shadows: [Shadow(color: Color(0x88000000), blurRadius: 4)],
  );

  @override
  Widget build(BuildContext context) {
    final rows = bed.rows.clamp(1, 6);
    final cols = bed.cols.clamp(1, 6);
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, box) {
          const label = 22.0;
          const header = 20.0;
          const wood = 7.0;
          final innerW = box.maxWidth - wood * 2 - 18;
          final cell = ((innerW - label) / cols).clamp(48.0, 96.0);
          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFD7B07A), Color(0xFF8B5E34), Color(0xFF6A4324)],
              ),
              boxShadow: [
                BoxShadow(color: const Color(0xFF3A2410).withValues(alpha: 0.28), blurRadius: 18, offset: const Offset(0, 10)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFF5C3A22), Color(0xFF3E2716), Color(0xFF2C1A0E)],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 10, 10),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: header,
                          child: Row(
                            children: [
                              const SizedBox(width: label),
                              for (var c = 0; c < cols; c++)
                                SizedBox(
                                  width: cell,
                                  child: Text('${c + 1}', textAlign: TextAlign.center, style: _labelStyle),
                                ),
                            ],
                          ),
                        ),
                        for (var r = 0; r < rows; r++)
                          SizedBox(
                            height: cell,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: label,
                                  child: Text(_letters[r], textAlign: TextAlign.center, style: _labelStyle.copyWith(fontSize: 12)),
                                ),
                                for (var c = 0; c < cols; c++)
                                  SizedBox(
                                    width: cell,
                                    height: cell,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: _PlotCell(
                                        cell: bed.cellAt(r, c),
                                        compact: cell < 62,
                                        onTap: () => onTapCell(r * cols + c),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PlotCell extends StatelessWidget {
  final BedCell cell;
  final bool compact;
  final VoidCallback onTap;

  const _PlotCell({required this.cell, required this.compact, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final planted = !cell.crop.isEmpty;
    final tint = planted ? cell.crop.color : const Color(0xFF5C4030);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: planted
                  ? [
                      Color.lerp(tint, const Color(0xFF3D2A1C), 0.45)!,
                      const Color(0xFF2C1A10),
                    ]
                  : const [Color(0xFF5A3C28), Color(0xFF3A2418)],
            ),
            border: Border.all(color: planted ? tint.withValues(alpha: 0.55) : const Color(0xFF2A1810), width: 1.2),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 6, offset: const Offset(0, 3)),
              BoxShadow(color: const Color(0x66F6E7C8), blurRadius: 0, offset: const Offset(0, -1), spreadRadius: -1),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (planted)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: compact ? 10 : 16,
                    margin: const EdgeInsets.fromLTRB(6, 0, 6, 5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: tint.withValues(alpha: 0.28),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (planted)
                      Text(cell.crop.emoji, style: TextStyle(fontSize: compact ? 20 : 28, height: 1))
                    else
                      Icon(Icons.add_rounded, size: compact ? 16 : 20, color: const Color(0x66F6E7C8)),
                    if (planted && !compact) ...[
                      const SizedBox(height: 2),
                      Text(
                        cell.crop.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFFF6E7C8),
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
