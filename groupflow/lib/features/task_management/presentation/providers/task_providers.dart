import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:groupflow/features/task_management/data/datasources/task_remote_datasource.dart';
import 'package:groupflow/features/task_management/data/repositories/task_repository_impl.dart';
import 'package:groupflow/features/task_management/domain/entities/task.dart';
import 'package:groupflow/features/task_management/domain/repositories/task_repository.dart';
import 'package:groupflow/features/task_management/domain/usecases/task_usecases.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Supabase client ────────────────────────────────────────────────────────────
final supabaseClientProvider = Provider<SupabaseClient>(
  (_) => Supabase.instance.client,
);

// ── Data layer ─────────────────────────────────────────────────────────────────
final taskDatasourceProvider = Provider<TaskRemoteDatasource>(
  (ref) => TaskRemoteDatasource(ref.read(supabaseClientProvider)),
);

final taskRepositoryProvider = Provider<TaskRepository>(
  (ref) => TaskRepositoryImpl(ref.read(taskDatasourceProvider)),
);

// ── Use case providers ─────────────────────────────────────────────────────────
final getProjectTasksProvider = Provider(
  (ref) => GetProjectTasks(ref.read(taskRepositoryProvider)),
);
final getMyTasksProvider = Provider(
  (ref) => GetMyTasks(ref.read(taskRepositoryProvider)),
);
final createTaskProvider = Provider(
  (ref) => CreateTask(ref.read(taskRepositoryProvider)),
);
final updateTaskProvider = Provider(
  (ref) => UpdateTask(ref.read(taskRepositoryProvider)),
);
final updateTaskStatusProvider = Provider(
  (ref) => UpdateTaskStatus(ref.read(taskRepositoryProvider)),
);
final deleteTaskProvider = Provider(
  (ref) => DeleteTask(ref.read(taskRepositoryProvider)),
);
final watchProjectTasksProvider = Provider(
  (ref) => WatchProjectTasks(ref.read(taskRepositoryProvider)),
);

// ── Real-time stream: tasks for a project ──────────────────────────────────────
final projectTasksStreamProvider =
    StreamProvider.family<List<Task>, String>((ref, projectId) {
  return ref.read(watchProjectTasksProvider).call(projectId);
});

// ── Async: my assigned tasks ───────────────────────────────────────────────────
final myTasksProvider =
    FutureProvider.family<List<Task>, String>((ref, userId) {
  return ref.read(getMyTasksProvider).call(userId);
});

// ── Derived: tasks grouped by status (for kanban) ─────────────────────────────
final tasksByStatusProvider =
    Provider.family<Map<TaskStatus, List<Task>>, String>(
  (ref, projectId) {
    final asyncTasks = ref.watch(projectTasksStreamProvider(projectId));
    final tasks = asyncTasks.valueOrNull ?? [];
    return {
      TaskStatus.todo: tasks.where((t) => t.status == TaskStatus.todo).toList(),
      TaskStatus.doing:
          tasks.where((t) => t.status == TaskStatus.doing).toList(),
      TaskStatus.done: tasks.where((t) => t.status == TaskStatus.done).toList(),
    };
  },
);
