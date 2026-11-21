import 'package:flutter/material.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import 'task_status_chip.dart';

/// Tarjeta reutilizable que representa una tarea en el listado.
///
/// Es un `StatelessWidget`: no guarda estado propio. Recibe la tarea y dos
/// callbacks; la pantalla que la usa decide qué pasa al tocarla o al marcar
/// la casilla (la tarjeta solo "avisa").
class TaskTile extends StatelessWidget {
  const TaskTile({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleCompleted,
  });

  final Task task;
  final VoidCallback onTap;
  final VoidCallback onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mutedColor = colorScheme.onSurfaceVariant;

    return Card(
      clipBehavior: Clip.antiAlias,
      // Las tareas completadas se ven "apagadas" para diferenciarlas.
      color: task.isCompleted
          ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
          : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 12, 12, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isCompleted,
                shape: const CircleBorder(),
                activeColor: AppTheme.completedColor,
                semanticLabel: task.isCompleted
                    ? 'Marcar "${task.title}" como pendiente'
                    : 'Marcar "${task.title}" como completada',
                onChanged: (_) => onToggleCompleted(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: task.isCompleted ? mutedColor : null,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: mutedColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: mutedColor),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            DateFormatter.short(task.createdAt),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: mutedColor,
                            ),
                          ),
                        ),
                        TaskStatusChip(isCompleted: task.isCompleted),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 10),
                child: Icon(Icons.chevron_right, color: mutedColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
