import 'package:flutter/material.dart';

import 'repositories/contracts/task_repository.dart';
import 'repositories/implementations/in_memory_task_repository.dart';
import 'screens/task_list_screen.dart';
import 'services/contracts/task_service.dart';
import 'services/implementations/task_service_impl.dart';
import 'theme/app_theme.dart';

/// Punto de entrada de la aplicación (equivale a `Program.cs`).
void main() {
  // Composición de dependencias: equivale a `SetDependencyInjection()` del
  // proyecto de referencia, pero sin contenedor. Se crean las
  // implementaciones una sola vez y se entregan por constructor.
  // Las variables usan el tipo del contrato, no el de la implementación.
  final TaskRepository taskRepository = InMemoryTaskRepository();
  final TaskService taskService = TaskServiceImpl(taskRepository);

  runApp(TaskFlowApp(taskService: taskService));
}

/// Widget raíz: configura el tema y la pantalla inicial.
class TaskFlowApp extends StatelessWidget {
  const TaskFlowApp({super.key, required this.taskService});

  final TaskService taskService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: TaskListScreen(taskService: taskService),
    );
  }
}
