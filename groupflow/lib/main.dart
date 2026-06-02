import 'package:flutter/material.dart';
import 'package:groupflow/features/task_management/presentation/pages/task_board_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const TaskBoardPage(
          projectId: 'default',
          currentUserId: 'default',
          isAdminOrOwner: false),
    );
  }
}
