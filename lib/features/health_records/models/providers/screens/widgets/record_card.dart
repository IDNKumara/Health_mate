import 'package:flutter/material.dart';
import 'package:health_mate/features/health_records/models/health_record.dart';
import 'package:intl/intl.dart';


class RecordCard extends StatelessWidget {
  final HealthRecord record;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const RecordCard({
    super.key,
    required this.record,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(record.date);
    final isToday = DateTime.now().difference(date).inDays == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isToday
                    ? [const Color(0xFF6C63FF), const Color(0xFF5A52D5)]
                    : [Colors.grey[700]!, Colors.grey[600]!],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(date),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isToday)
                        const Text(
                          'Today',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_rounded),
                  color: Colors.white,
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_rounded),
                  color: Colors.white,
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
          
          // Stats
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.directions_walk_rounded,
                    label: 'Steps',
                    value: record.steps.toString(),
                    color: const Color(0xFF6C63FF),
                  ),
                ),
                Container(
                  height: 60,
                  width: 1,
                  color: Colors.grey[200],
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Calories',
                    value: '${record.calories} kcal',
                    color: const Color(0xFFFF6B6B),
                  ),
                ),
                Container(
                  height: 60,
                  width: 1,
                  color: Colors.grey[200],
                ),
                Expanded(
                  child: _buildStatItem(
                    icon: Icons.water_drop_rounded,
                    label: 'Water',
                    value: '${(record.water / 1000).toStringAsFixed(1)}L',
                    color: const Color(0xFF4ECDC4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }
}