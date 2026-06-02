import 'package:groupflow/features/task_management/data/datasources/task_remote_datasource.dart';
import 'package:groupflow/features/task_management/domain/entities/task.dart';
import 'package:groupflow/features/task_management/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource _datasource;

  TaskRepositoryImpl(this._datasource);

  @override
  Future<List<Task>> getTasksByProject(String projectId) =>
      _datasource.getTasksByProject(projectId);

  @override
  Future<List<Task>> getTasksAssignedToUser(String userId) =>
      _datasource.getTasksAssignedToUser(userId);

  @override
  Future<Task> getTaskById(String taskId) => _datasource.getTaskById(taskId);

  @override
  Future<Task> createTask({
    required String projectId,
    required String title,
    required String description,
    required String createdBy,
    required TaskPriority priority,
    String? assignedTo,
    DateTime? dueDate,
  }) =>
      _datasource.createTask(
        projectId: projectId,
        title: title,
        description: description,
        createdBy: createdBy,
        priority: priority,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );

  @override
  Future<Task> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? assignedTo,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) =>
      _datasource.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        assignedTo: assignedTo,
        priority: priority,
        status: status,
        dueDate: dueDate,
      );

  @override
  Future<void> deleteTask(String taskId) => _datasource.deleteTask(taskId);

  @override
  Future<Task> updateTaskStatus(String taskId, TaskStatus status) =>
      _datasource.updateTask(taskId: taskId, status: status);

  @override
  Stream<List<Task>> watchTasksByProject(String projectId) =>
      _datasource.watchTasksByProject(projectId);
}
