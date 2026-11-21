import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Etiqueta reutilizable que muestra si una tarea está completada o
/// pendiente. Se usa en [TaskTile] y en la pantalla de detalle para que el
/// estado se vea igual en toda la aplicación.
class TaskStatusChip extends StatelessWidget {
  const TaskStatusChip({super.key, required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = isCompleted
        ? AppTheme.completedColor
        : colorScheme.primary;
    final background = isCompleted
        ? AppTheme.completedContainerColor
        : colorScheme.primaryContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: foreground,
          ),
          const SizedBox(width: 4),
          Text(
            isCompleted ? 'Completada' : 'Pendiente',
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
