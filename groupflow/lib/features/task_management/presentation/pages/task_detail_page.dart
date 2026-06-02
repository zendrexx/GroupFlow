import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groupflow/features/task_management/domain/entities/task.dart';
import 'package:groupflow/features/task_management/presentation/viewmodel/task_viewmodel.dart';
import 'package:groupflow/features/task_management/presentation/widgets/task_badges.dart';
import 'package:groupflow/features/task_management/presentation/widgets/task_form_sheet.dart';
import 'package:intl/intl.dart';

class TaskDetailPage extends ConsumerWidget {
  final Task task;
  final String currentUserId;
  final bool isAdminOrOwner;

  const TaskDetailPage({
    super.key,
    required this.task,
    required this.currentUserId,
    required this.isAdminOrOwner,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(taskViewModelProvider.notifier);
    final colors = Theme.of(context).colorScheme;

    Future<void> changeStatus(TaskStatus newStatus) async {
      await vm.moveTask(task.taskId, newStatus);
      if (context.mounted) Navigator.pop(context);
    }

    Future<void> confirmDelete() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Delete task'),
          content: Text('Delete "${task.title}"? This cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: colors.error),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        final success = await vm.deleteTask(task.taskId);
        if (success && context.mounted) Navigator.pop(context);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Task detail'),
        actions: [
          if (isAdminOrOwner) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: colors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => TaskFormSheet(
                  projectId: task.projectId,
                  currentUserId: currentUserId,
                  existingTask: task,
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: colors.error),
              onPressed: confirmDelete,
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            task.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              PriorityBadge(task.priority),
              StatusBadge(task.status),
              if (task.isOverdue)
                _InfoChip(
                  icon: Icons.warning_amber_outlined,
                  label: 'Overdue',
                  color: const Color(0xFFA32D2D),
                  bg: const Color(0xFFFCEBEB),
                ),
            ],
          ),
          const SizedBox(height: 20),
          if (task.description.isNotEmpty) ...[
            _SectionLabel('Description'),
            const SizedBox(height: 6),
            Text(
              task.description,
              style: TextStyle(
                fontSize: 14,
                color: colors.onSurface.withOpacity(0.7),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
          ],
          _SectionLabel('Details'),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Due date',
            value: task.dueDate != null
                ? DateFormat('MMM d, yyyy').format(task.dueDate!)
                : 'No due date',
          ),
          _DetailRow(
            icon: Icons.person_outline,
            label: 'Assigned to',
            value: task.assignedTo ?? 'Unassigned',
          ),
          _DetailRow(
            icon: Icons.access_time_outlined,
            label: 'Created',
            value: DateFormat('MMM d, yyyy').format(task.createdAt),
          ),
          if (task.completedAt != null)
            _DetailRow(
              icon: Icons.check_circle_outline,
              label: 'Completed',
              value: DateFormat('MMM d, yyyy').format(task.completedAt!),
            ),
          const SizedBox(height: 28),
          _SectionLabel('Update status'),
          const SizedBox(height: 10),
          ...TaskStatus.values.map(
            (s) => _StatusOption(
              status: s,
              isSelected: task.status == s,
              onTap: task.status == s ? null : () => changeStatus(s),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
          letterSpacing: 0.3,
        ),
      );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colors.onSurface.withOpacity(0.4)),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
                fontSize: 13, color: colors.onSurface.withOpacity(0.5)),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  final TaskStatus status;
  final bool isSelected;
  final VoidCallback? onTap;
  const _StatusOption(
      {required this.status, required this.isSelected, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFEEEDFE)
              : colors.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF534AB7) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: isSelected
                  ? const Color(0xFF534AB7)
                  : colors.onSurface.withOpacity(0.3),
            ),
            const SizedBox(width: 10),
            Text(
              status.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? const Color(0xFF3C3489) : colors.onSurface,
              ),
            ),
            const Spacer(),
            StatusBadge(status),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;
  const _InfoChip(
      {required this.icon,
      required this.label,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}
