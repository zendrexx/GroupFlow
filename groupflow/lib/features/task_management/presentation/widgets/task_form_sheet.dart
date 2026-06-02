import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groupflow/features/task_management/domain/entities/task.dart';
import 'package:groupflow/features/task_management/presentation/viewmodel/task_viewmodel.dart';
import 'package:intl/intl.dart';

class TaskFormSheet extends ConsumerStatefulWidget {
  final String projectId;
  final String currentUserId;
  final Task? existingTask; // null = create, non-null = edit

  const TaskFormSheet({
    super.key,
    required this.projectId,
    required this.currentUserId,
    this.existingTask,
  });

  bool get isEditing => existingTask != null;

  @override
  ConsumerState<TaskFormSheet> createState() => _TaskFormSheetState();
}

class _TaskFormSheetState extends ConsumerState<TaskFormSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _titleCtrl.text = widget.existingTask!.title;
      _descCtrl.text = widget.existingTask!.description;
      _priority = widget.existingTask!.priority;
      _dueDate = widget.existingTask!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final vm = ref.read(taskViewModelProvider.notifier);

    if (widget.isEditing) {
      await vm.updateTask(
        taskId: widget.existingTask!.taskId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        priority: _priority,
        dueDate: _dueDate,
      );
    } else {
      await vm.createTask(
        projectId: widget.projectId,
        title: _titleCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        createdBy: widget.currentUserId,
        priority: _priority,
        dueDate: _dueDate,
      );
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(taskViewModelProvider).isLoading;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.isEditing ? 'Edit task' : 'New task',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleCtrl,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Task title',
                hintText: 'e.g. Design login screen',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Title is required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional details...',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Priority',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: TaskPriority.values.map((p) {
                final selected = _priority == p;
                final (color, bg) = switch (p) {
                  TaskPriority.high => (
                      const Color(0xFF791F1F),
                      const Color(0xFFFCEBEB)
                    ),
                  TaskPriority.medium => (
                      const Color(0xFF633806),
                      const Color(0xFFFAEEDA)
                    ),
                  TaskPriority.low => (
                      const Color(0xFF27500A),
                      const Color(0xFFEAF3DE)
                    ),
                };
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _priority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: selected ? bg : colors.surfaceVariant,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: selected ? color : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        p.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selected
                              ? color
                              : colors.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  border: Border.all(color: colors.outline.withOpacity(0.4)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: colors.onSurface.withOpacity(0.5),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _dueDate != null
                          ? DateFormat('MMM d, yyyy').format(_dueDate!)
                          : 'Set due date (optional)',
                      style: TextStyle(
                        fontSize: 13,
                        color: _dueDate != null
                            ? colors.onSurface
                            : colors.onSurface.withOpacity(0.4),
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: Icon(
                          Icons.close,
                          size: 16,
                          color: colors.onSurface.withOpacity(0.4),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(widget.isEditing ? 'Save changes' : 'Create task'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
