import 'package:flutter/material.dart';
import 'package:groupflow/features/task_management/domain/entities/task.dart';
import 'package:groupflow/features/task_management/presentation/widgets/task_badges.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback? onTap;
  final bool showProject;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.showProject = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDone = task.status == TaskStatus.done;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            left: BorderSide(
              color: task.isOverdue
                  ? const Color(0xFFA32D2D)
                  : task.status == TaskStatus.doing
                      ? const Color(0xFF534AB7)
                      : Colors.transparent,
              width: 3,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDone
                          ? colors.onSurface.withOpacity(0.4)
                          : colors.onSurface,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(task.status),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                task.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.onSurface.withOpacity(0.5),
                ),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                PriorityBadge(task.priority),
                const Spacer(),
                if (task.dueDate != null)
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: task.isOverdue
                            ? const Color(0xFFA32D2D)
                            : colors.onSurface.withOpacity(0.4),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.isDueTomorrow
                            ? 'Tomorrow'
                            : DateFormat('MMM d').format(task.dueDate!),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: task.isOverdue
                              ? FontWeight.w500
                              : FontWeight.normal,
                          color: task.isOverdue
                              ? const Color(0xFFA32D2D)
                              : colors.onSurface.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
