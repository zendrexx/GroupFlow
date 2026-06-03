import 'package:go_router/go_router.dart';
import 'package:groupflow/features/auth/presentation/pages/sign_in_page.dart';
import 'package:groupflow/features/auth/presentation/pages/sign_up_page.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SignInPage(),
    ),
    GoRoute(
      path: AppRoutes.signUp,
      builder: (context, state) => const SignUpPage(),
    ),
    GoRoute(
      path: AppRoutes.taskBoard,
      builder: (context, state) => const TaskBoardPage(),
    ),
  ],
);
