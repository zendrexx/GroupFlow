import 'package:flutter/material.dart';
import 'package:groupflow/features/task_management/domain/entities/task.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  const PriorityBadge(this.priority, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (priority) {
      TaskPriority.high => (const Color(0xFF791F1F), const Color(0xFFFCEBEB)),
      TaskPriority.medium => (const Color(0xFF633806), const Color(0xFFFAEEDA)),
      TaskPriority.low => (const Color(0xFF27500A), const Color(0xFFEAF3DE)),
    };
    return _Badge(label: priority.label, color: color, bg: bg);
  }
}

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const StatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      TaskStatus.todo => (const Color(0xFF444441), const Color(0xFFF1EFE8)),
      TaskStatus.doing => (const Color(0xFF633806), const Color(0xFFFAEEDA)),
      TaskStatus.done => (const Color(0xFF085041), const Color(0xFFE1F5EE)),
    };
    return _Badge(label: status.label, color: color, bg: bg);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  const _Badge({required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
