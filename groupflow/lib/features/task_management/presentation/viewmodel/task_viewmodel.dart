import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groupflow/features/task_management/domain/entities/task.dart';
import 'package:groupflow/features/task_management/presentation/providers/task_providers.dart';

class TaskState {
  final bool isLoading;
  final String? error;
  final Task? selectedTask;

  const TaskState({
    this.isLoading = false,
    this.error,
    this.selectedTask,
  });

  TaskState copyWith({
    bool? isLoading,
    String? error,
    Task? selectedTask,
  }) =>
      TaskState(
        isLoading: isLoading ?? this.isLoading,
        error: error,
        selectedTask: selectedTask ?? this.selectedTask,
      );
}

class TaskViewModel extends StateNotifier<TaskState> {
  final Ref _ref;

  TaskViewModel(this._ref) : super(const TaskState());

  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required String createdBy,
    required TaskPriority priority,
    String? assignedTo,
    DateTime? dueDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(createTaskProvider).call(
            projectId: projectId,
            title: title,
            description: description,
            createdBy: createdBy,
            priority: priority,
            assignedTo: assignedTo,
            dueDate: dueDate,
          );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    String? assignedTo,
    TaskPriority? priority,
    TaskStatus? status,
    DateTime? dueDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(updateTaskProvider).call(
            taskId: taskId,
            title: title,
            description: description,
            assignedTo: assignedTo,
            priority: priority,
            status: status,
            dueDate: dueDate,
          );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> moveTask(String taskId, TaskStatus newStatus) async {
    try {
      await _ref.read(updateTaskStatusProvider).call(taskId, newStatus);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<bool> deleteTask(String taskId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _ref.read(deleteTaskProvider).call(taskId);
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void selectTask(Task? task) => state = state.copyWith(selectedTask: task);

  void clearError() => state = state.copyWith(error: null);
}

final taskViewModelProvider = StateNotifierProvider<TaskViewModel, TaskState>(
  (ref) => TaskViewModel(ref),
);
