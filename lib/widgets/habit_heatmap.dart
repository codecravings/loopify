import 'package:flutter/material.dart';
import '../services/analytics_service.dart';

class HabitHeatmap extends StatelessWidget {
  final int days;

  const HabitHeatmap({Key? key, this.days = 90}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DayPerformance>>(
      future: AnalyticsService.getHeatmapData(days),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'No data available yet',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        final heatmapData = snapshot.data!;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF1D1E33),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.calendar_month, color: Colors.purple, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'Activity Heatmap',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Last $days days',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 20),
              // Heatmap grid
              _buildHeatmapGrid(heatmapData),
              const SizedBox(height: 16),
              // Legend
              _buildLegend(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeatmapGrid(List<DayPerformance> data) {
    // Calculate weeks needed
    final int weeksNeeded = (data.length / 7).ceil();

    return SizedBox(
      height: 8 * 7 + 6 * 4.0, // 7 days * 8px height + 6 gaps * 4px
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7, // 7 days per week
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
          childAspectRatio: 1,
        ),
        itemCount: data.length,
        itemBuilder: (context, index) {
          final dayData = data[index];
          return _buildHeatmapCell(dayData);
        },
      ),
    );
  }

  Widget _buildHeatmapCell(DayPerformance dayData) {
    final color = _getColorForCompletion(dayData.completionRate);
    final habits = dayData.habitsCompleted;

    return Tooltip(
      message: '${_formatDate(dayData.date)}\n$habits habits',
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Color _getColorForCompletion(double rate) {
    if (rate == 0) {
      return const Color(0xFF1D1E33); // Dark grey for no habits
    } else if (rate < 0.25) {
      return Colors.red.withValues(alpha: 0.3); // Very low
    } else if (rate < 0.5) {
      return Colors.orange.withValues(alpha: 0.5); // Low
    } else if (rate < 0.75) {
      return Colors.amber.withValues(alpha: 0.7); // Medium
    } else if (rate < 1.0) {
      return Colors.green.withValues(alpha: 0.7); // Good
    } else {
      return Colors.green; // Perfect
    }
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Less',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        const SizedBox(width: 8),
        _buildLegendBox(const Color(0xFF1D1E33)),
        const SizedBox(width: 4),
        _buildLegendBox(Colors.red.withValues(alpha: 0.3)),
        const SizedBox(width: 4),
        _buildLegendBox(Colors.orange.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        _buildLegendBox(Colors.amber.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        _buildLegendBox(Colors.green.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        _buildLegendBox(Colors.green),
        const SizedBox(width: 8),
        Text(
          'More',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendBox(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}';
  }
}
