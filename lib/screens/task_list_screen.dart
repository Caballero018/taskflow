import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/contracts/task_service.dart';
import '../theme/app_theme.dart';
import '../widgets/task_tile.dart';

/// Pantalla principal: resumen y listado de tareas.
///
/// Cumple el papel de un Controller del proyecto de referencia: recibe el
/// servicio por constructor y solo coordina; toda la lógica de negocio está
/// en [TaskService].
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key, required this.taskService});

  final TaskService taskService;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  /// Marca o desmarca la tarea desde el listado.
  void _toggleCompleted(Task task) {
    // setState vuelve a ejecutar build(), que lee los datos actualizados del
    // servicio y redibuja la tarjeta y los contadores.
    setState(() => widget.taskService.toggleCompleted(task.id));
  }

  Future<void> _openCreateForm() async {
    // Se conecta con TaskFormScreen en la etapa de navegación.
  }

  Future<void> _openDetail(Task task) async {
    // Se conecta con TaskDetailScreen en la etapa de navegación.
  }

  @override
  Widget build(BuildContext context) {
    // Los datos se leen del servicio en cada build: la pantalla nunca guarda
    // una copia propia que pueda quedar desactualizada.
    final tasks = widget.taskService.getAll();
    final total = widget.taskService.countAll();
    final completed = widget.taskService.countCompleted();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.task_alt, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('TaskFlow'),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: _SummaryHeader(total: total, completed: completed),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: Text(
                'Mis tareas',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Expanded(
              child: tasks.isEmpty
                  ? const _EmptyState()
                  : ListView.builder(
                      key: const Key('task_list'),
                      // Espacio inferior para que el botón flotante no tape
                      // la última tarjeta.
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                      itemCount: tasks.length,
                      itemBuilder: (context, index) {
                        final task = tasks[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: TaskTile(
                            key: ValueKey(task.id),
                            task: task,
                            onTap: () => _openDetail(task),
                            onToggleCompleted: () => _toggleCompleted(task),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add_task_button'),
        onPressed: _openCreateForm,
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
    );
  }
}

/// Bienvenida y tarjeta de resumen con los contadores y el progreso.
class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({required this.total, required this.completed});

  final int total;
  final int completed;

  String get _message {
    if (total == 0) return 'Empieza creando tu primera tarea.';
    final pending = total - completed;
    if (pending == 0) return '¡Todo al día! Completaste todas tus tareas.';
    return pending == 1
        ? 'Te queda 1 tarea pendiente.'
        : 'Te quedan $pending tareas pendientes.';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final progress = total == 0 ? 0.0 : completed / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bienvenido a TaskFlow',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Organiza tu día, una tarea a la vez.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(AppTheme.radius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _CounterItem(
                      key: const Key('total_counter'),
                      label: 'Tareas',
                      value: total,
                      icon: Icons.list_alt,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Expanded(
                    child: _CounterItem(
                      key: const Key('completed_counter'),
                      label: 'Completadas',
                      value: completed,
                      icon: Icons.check_circle_outline,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  color: AppTheme.completedColor,
                  backgroundColor: colorScheme.surface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CounterItem extends StatelessWidget {
  const _CounterItem({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$value',
              style: textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(label, style: textTheme.labelMedium?.copyWith(color: color)),
          ],
        ),
      ],
    );
  }
}

/// Estado vacío: se muestra cuando todavía no hay tareas.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checklist_rounded,
                size: 48,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Aún no tienes tareas',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Pulsa "Nueva tarea" para crear la primera.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
