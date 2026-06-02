import 'package:groupflow/features/task_management/data/models/task_model.dart';
import 'package:groupflow/features/task_management/domain/entities/task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _table = 'tasks';

class TaskRemoteDatasource {
  final SupabaseClient _client;

  TaskRemoteDatasource(this._client);

  Future<List<TaskModel>> getTasksByProject(String projectId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('project_id', projectId)
        .order('created_at');
    return (data as List).map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<List<TaskModel>> getTasksAssignedToUser(String userId) async {
    final data = await _client
        .from(_table)
        .select()
        .eq('assigned_to', userId)
        .neq('status', 'done')
        .order('due_date', ascending: true);
    return (data as List).map((e) => TaskModel.fromJson(e)).toList();
  }

  Future<TaskModel> getTaskById(String taskId) async {
    final data =
        await _client.from(_table).select().eq('task_id', taskId).single();
    return TaskModel.fromJson(data);
  }

  Future<TaskModel> createTask({
    required String projectId,
    required String title,
    required String description,
    required String createdBy,
    required TaskPriority priority,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    final payload = TaskModel(
      taskId: '',
      projectId: projectId,
      title: title,
      description: description,
      assignedTo: assignedTo,
      createdBy: createdBy,
      priority: priority,
      status: TaskStatus.todo,
      dueDate: dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).toInsertJson(
      projectId: projectId,
      title: title,
      description: description,
      createdBy: createdBy,
      priority: priority,
      assignedTo: assignedTo,
      dueDate: dueDate,
    );

    final data = await _client.from(_table).insert(payload).select().single();
    return TaskModel.fromJson(data);
  }

  Future<TaskModel> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? assignedTo,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) async {
    DateTime? completedAt;
    if (status == TaskStatus.done) {
      completedAt = DateTime.now();
    } else if (status == TaskStatus.todo || status == TaskStatus.doing) {
      // Reopen: clear completedAt
      completedAt = null;
    }

    final existing = TaskModel(
      taskId: taskId,
      projectId: '',
      title: '',
      description: '',
      createdBy: '',
      priority: TaskPriority.medium,
      status: TaskStatus.todo,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final payload = existing.toUpdateJson(
      title: title,
      description: description,
      assignedTo: assignedTo,
      priority: priority,
      status: status,
      dueDate: dueDate,
      completedAt: completedAt,
    );

    if (status != TaskStatus.done && status != null) {
      payload['completed_at'] = null;
    }

    final data = await _client
        .from(_table)
        .update(payload)
        .eq('task_id', taskId)
        .select()
        .single();
    return TaskModel.fromJson(data);
  }

  Future<void> deleteTask(String taskId) async {
    await _client.from(_table).delete().eq('task_id', taskId);
  }

  Stream<List<TaskModel>> watchTasksByProject(String projectId) {
    return _client
        .from(_table)
        .stream(primaryKey: ['task_id'])
        .eq('project_id', projectId)
        .order('created_at')
        .map((rows) => rows.map(TaskModel.fromJson).toList());
  }
}
