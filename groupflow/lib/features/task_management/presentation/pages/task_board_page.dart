import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groupflow/features/task_management/domain/entities/task.dart';
import 'package:groupflow/features/task_management/presentation/pages/task_detail_page.dart';
import 'package:groupflow/features/task_management/presentation/providers/task_providers.dart';
import 'package:groupflow/features/task_management/presentation/widgets/task_card.dart';
import 'package:groupflow/features/task_management/presentation/widgets/task_form_sheet.dart';

class TaskBoardPage extends ConsumerStatefulWidget {
  final String projectId;
  final String currentUserId;
  final bool isAdminOrOwner;

  const TaskBoardPage({
    super.key,
    required this.projectId,
    required this.currentUserId,
    required this.isAdminOrOwner,
  });

  @override
  ConsumerState<TaskBoardPage> createState() => _TaskBoardPageState();
}

class _TaskBoardPageState extends ConsumerState<TaskBoardPage> {
  TaskStatus? _filterStatus;

  void _openCreateSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => TaskFormSheet(
        projectId: widget.projectId,
        currentUserId: widget.currentUserId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(projectTasksStreamProvider(widget.projectId));
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          if (widget.isAdminOrOwner)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openCreateSheet,
            ),
        ],
      ),
      body: Column(
        children: [
          // Status filter chips
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filterStatus == null,
                  onTap: () => setState(() => _filterStatus = null),
                ),
                ...TaskStatus.values.map(
                  (s) => _FilterChip(
                    label: s.label,
                    selected: _filterStatus == s,
                    onTap: () => setState(() => _filterStatus = s),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: tasksAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load tasks: $e',
                  style: TextStyle(color: colors.error),
                ),
              ),
              data: (tasks) {
                final filtered = _filterStatus == null
                    ? tasks
                    : tasks.where((t) => t.status == _filterStatus).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_box_outline_blank,
                          size: 48,
                          color: colors.onSurface.withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No tasks yet',
                          style: TextStyle(
                            color: colors.onSurface.withOpacity(0.4),
                          ),
                        ),
                        if (widget.isAdminOrOwner) ...[
                          const SizedBox(height: 16),
                          FilledButton.tonal(
                            onPressed: _openCreateSheet,
                            child: const Text('Create first task'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(14),
                  itemCount: filtered.length,
                  itemBuilder: (_, i) => TaskCard(
                    task: filtered[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TaskDetailPage(
                          task: filtered[i],
                          currentUserId: widget.currentUserId,
                          isAdminOrOwner: widget.isAdminOrOwner,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isAdminOrOwner
          ? FloatingActionButton(
              onPressed: _openCreateSheet,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF534AB7) : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? const Color(0xFFEEEDFE) : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
