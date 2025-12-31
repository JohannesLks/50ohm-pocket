import 'package:flutter/material.dart';

/// A widget that displays progress as a grid of colored squares,
/// where each square represents a question.
/// More scalable than a horizontal bar for large question counts (1000+).
class ProgressPixelGrid extends StatelessWidget {
  /// List of scores for each question.
  /// Score meaning: 0 = not answered/wrong, 1 = 1x correct, 2 = 2x correct, 3+ = learned
  final List<int> questionScores;
  
  /// Size of each square in dp
  final double squareSize;
  
  /// Gap between squares in dp
  final double gap;
  
  const ProgressPixelGrid({
    Key? key,
    required this.questionScores,
    this.squareSize = 6.0,
    this.gap = 1.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (questionScores.isEmpty) {
      return SizedBox.shrink();
    }
    
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate how many columns fit in the available width
        final double availableWidth = constraints.maxWidth;
        final int columnsPerRow = ((availableWidth + gap) / (squareSize + gap)).floor();
        final int totalRows = (questionScores.length / columnsPerRow).ceil();
        final double gridHeight = totalRows * (squareSize + gap) - gap;
        
        return Container(
          height: gridHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: CustomPaint(
            size: Size(availableWidth, gridHeight),
            painter: _ProgressGridPainter(
              scores: questionScores,
              squareSize: squareSize,
              gap: gap,
              columnsPerRow: columnsPerRow,
              isDarkMode: Theme.of(context).brightness == Brightness.dark,
            ),
          ),
        );
      },
    );
  }
}

class _ProgressGridPainter extends CustomPainter {
  final List<int> scores;
  final double squareSize;
  final double gap;
  final int columnsPerRow;
  final bool isDarkMode;

  _ProgressGridPainter({
    required this.scores,
    required this.squareSize,
    required this.gap,
    required this.columnsPerRow,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty || columnsPerRow == 0) return;

    final Paint paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < scores.length; i++) {
      final int row = i ~/ columnsPerRow;
      final int col = i % columnsPerRow;
      
      final double x = col * (squareSize + gap);
      final double y = row * (squareSize + gap);
      
      paint.color = _getColorForScore(scores[i]);
      
      final Rect rect = Rect.fromLTWH(x, y, squareSize, squareSize);
      final RRect roundedRect = RRect.fromRectAndRadius(
        rect,
        Radius.circular(1.0),
      );
      
      canvas.drawRRect(roundedRect, paint);
    }
  }

  Color _getColorForScore(int score) {
    if (score <= 0) {
      // Not answered or wrong - gray
      return isDarkMode 
          ? Colors.grey.shade700 
          : Colors.grey.shade400;
    } else if (score == 1) {
      // 1x correct - orange
      return isDarkMode 
          ? Colors.orange.shade700 
          : Colors.orange.shade400;
    } else if (score == 2) {
      // 2x correct - yellow
      return isDarkMode 
          ? Colors.yellow.shade700 
          : Colors.yellow.shade600;
    } else {
      // 3+ correct - green (learned)
      return isDarkMode 
          ? Colors.green.shade600 
          : Colors.green.shade500;
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressGridPainter oldDelegate) {
    return oldDelegate.scores != scores || 
           oldDelegate.isDarkMode != isDarkMode ||
           oldDelegate.columnsPerRow != columnsPerRow;
  }
}

/// A more detailed progress overview with legend
class ProgressOverviewCard extends StatelessWidget {
  final List<int> questionScores;
  
  const ProgressOverviewCard({
    Key? key,
    required this.questionScores,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final int total = questionScores.length;
    final int learned = questionScores.where((s) => s >= 3).length;
    final int inProgress = questionScores.where((s) => s > 0 && s < 3).length;
    final int notStarted = questionScores.where((s) => s <= 0).length;
    final double percentage = total > 0 ? (learned / total) * 100 : 0;
    
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 8),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lernstand',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}% gelernt',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ProgressPixelGrid(
              questionScores: questionScores,
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _LegendItem(
                  color: Colors.green,
                  label: 'Gelernt',
                  count: learned,
                ),
                _LegendItem(
                  color: Colors.orange,
                  label: 'In Arbeit',
                  count: inProgress,
                ),
                _LegendItem(
                  color: Colors.grey,
                  label: 'Offen',
                  count: notStarted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  
  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 4),
        Text(
          '$label: $count',
          style: TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}
