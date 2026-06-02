import 'package:groupflow/features/task_management/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> getTasksByProject(String projectId);
  Future<List<Task>> getTasksAssignedToUser(String userId);
  Future<Task> getTaskById(String taskId);
  Future<Task> createTask({
    required String projectId,
    required String title,
    required String description,
    required String createdBy,
    required TaskPriority priority,
    String? assignedTo,
    DateTime? dueDate,
  });
  Future<Task> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? assignedTo,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  });
  Future<void> deleteTask(String taskId);
  Future<Task> updateTaskStatus(String taskId, TaskStatus status);

  /// Real-time stream of tasks for a project (for kanban live updates)
  Stream<List<Task>> watchTasksByProject(String projectId);
}
