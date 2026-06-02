import 'package:groupflow/features/task_management/domain/entities/task.dart';
import 'package:groupflow/features/task_management/domain/repositories/task_repository.dart';

class GetProjectTasks {
  final TaskRepository repository;
  GetProjectTasks(this.repository);

  Future<List<Task>> call(String projectId) =>
      repository.getTasksByProject(projectId);
}

class GetMyTasks {
  final TaskRepository repository;
  GetMyTasks(this.repository);

  Future<List<Task>> call(String userId) =>
      repository.getTasksAssignedToUser(userId);
}

class CreateTask {
  final TaskRepository repository;
  CreateTask(this.repository);

  Future<Task> call({
    required String projectId,
    required String title,
    required String description,
    required String createdBy,
    required TaskPriority priority,
    String? assignedTo,
    DateTime? dueDate,
  }) =>
      repository.createTask(
        projectId: projectId,
        title: title,
        description: description,
        createdBy: createdBy,
        priority: priority,
        assignedTo: assignedTo,
        dueDate: dueDate,
      );
}

class UpdateTask {
  final TaskRepository repository;
  UpdateTask(this.repository);

  Future<Task> call({
    required String taskId,
    String? title,
    String? description,
    String? assignedTo,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) =>
      repository.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        assignedTo: assignedTo,
        priority: priority,
        status: status,
        dueDate: dueDate,
      );
}

class UpdateTaskStatus {
  final TaskRepository repository;
  UpdateTaskStatus(this.repository);

  Future<Task> call(String taskId, TaskStatus status) =>
      repository.updateTaskStatus(taskId, status);
}

class DeleteTask {
  final TaskRepository repository;
  DeleteTask(this.repository);

  Future<void> call(String taskId) => repository.deleteTask(taskId);
}

class WatchProjectTasks {
  final TaskRepository repository;
  WatchProjectTasks(this.repository);

  Stream<List<Task>> call(String projectId) =>
      repository.watchTasksByProject(projectId);
}
