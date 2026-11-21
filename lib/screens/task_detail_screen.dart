import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/contracts/task_service.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../widgets/task_status_chip.dart';

/// Detalle de una tarea: permite cambiar su estado o eliminarla.
///
/// Recibe solo el `taskId` y consulta la tarea al servicio en cada build.
/// Así siempre muestra los datos actuales y detecta si la tarea ya no existe
/// (equivale al `NotFound()` de los controladores del proyecto de
/// referencia).
class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    super.key,
    required this.taskService,
    required this.taskId,
  });

  final TaskService taskService;
  final String taskId;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  void _toggleCompleted() {
    // Si la tarea desapareció, toggleCompleted devuelve null y el build
    // siguiente muestra el estado "no encontrada".
    setState(() => widget.taskService.toggleCompleted(widget.taskId));
  }

  Future<void> _confirmDelete(Task task) async {
    // showDialog devuelve el valor con que se cierre el diálogo
    // (Navigator.pop(context, true/false)).
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('¿Eliminar tarea?'),
        content: Text(
          'Se eliminará "${task.title}". Esta acción no se puede '
          'deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            key: const Key('confirm_delete_button'),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              minimumSize: const Size(0, 40),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    // Después de un await la pantalla pudo cerrarse: se comprueba `mounted`
    // antes de volver a usar el context.
    if (confirmed != true || !mounted) return;

    final deleted = widget.taskService.delete(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted ? 'Tarea "${task.title}" eliminada' : 'La tarea ya no existe',
        ),
      ),
    );
    // Regresa al listado, que se actualiza al recuperar el control.
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.taskService.getById(widget.taskId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de la tarea'),
        actions: [
          if (task != null)
            IconButton(
              tooltip: 'Eliminar tarea',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _confirmDelete(task),
            ),
        ],
      ),
      body: SafeArea(
        child: task == null ? const _TaskNotFound() : _buildDetail(task),
      ),
    );
  }

  Widget _buildDetail(Task task) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TaskStatusChip(isCompleted: task.isCompleted),
        ),
        const SizedBox(height: 12),
        Text(
          task.title,
          key: const Key('detail_title'),
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted ? colorScheme.onSurfaceVariant : null,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionLabel(icon: Icons.notes, text: 'Descripción'),
                const SizedBox(height: 8),
                Text(task.description, style: theme.textTheme.bodyLarge),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Fecha de creación',
                value: DateFormatter.long(task.createdAt),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              _InfoRow(
                icon: task.isCompleted
                    ? Icons.check_circle
                    : Icons.radio_button_unchecked,
                iconColor: task.isCompleted
                    ? AppTheme.completedColor
                    : colorScheme.primary,
                label: 'Estado actual',
                value: task.isCompleted ? 'Completada' : 'Pendiente',
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        FilledButton.icon(
          key: const Key('toggle_status_button'),
          style: task.isCompleted
              ? null
              : FilledButton.styleFrom(
                  backgroundColor: AppTheme.completedColor,
                ),
          onPressed: _toggleCompleted,
          icon: Icon(task.isCompleted ? Icons.undo : Icons.check),
          label: Text(
            task.isCompleted
                ? 'Marcar como pendiente'
                : 'Marcar como completada',
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          key: const Key('delete_task_button'),
          style: OutlinedButton.styleFrom(
            foregroundColor: colorScheme.error,
            side: BorderSide(color: colorScheme.error),
          ),
          onPressed: () => _confirmDelete(task),
          icon: const Icon(Icons.delete_outline),
          label: const Text('Eliminar tarea'),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.onSurfaceVariant;
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Text(text, style: theme.textTheme.labelLarge?.copyWith(color: color)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: iconColor ?? theme.colorScheme.primary),
      title: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      subtitle: Text(
        value,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// Se muestra si la tarea fue eliminada o el id no existe.
class _TaskNotFound extends StatelessWidget {
  const _TaskNotFound();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Esta tarea ya no existe',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Puede que haya sido eliminada.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Volver al listado'),
            ),
          ],
        ),
      ),
    );
  }
}
