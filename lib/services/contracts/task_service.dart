import '../../models/task.dart';

/// Contrato del servicio de tareas.
///
/// Equivale a las interfaces `IXxxService` de `Services/Contracts/` en el
/// proyecto de referencia. Las pantallas dependen de este contrato y no de
/// una implementación concreta, ni mucho menos del repositorio.
abstract class TaskService {
  /// Todas las tareas, de la más reciente a la más antigua.
  List<Task> getAll();

  /// La tarea con ese [id], o `null` si ya no existe.
  Task? getById(String id);

  /// Crea una tarea pendiente. Lanza [ArgumentError] si los datos no
  /// cumplen las reglas de `TaskValidator`.
  Task create({required String title, required String description});

  /// Actualiza título, descripción o estado de una tarea existente.
  /// Devuelve `null` si la tarea ya no existe.
  Task? update(Task task);

  /// Elimina la tarea. Devuelve `false` si ya no existía.
  bool delete(String id);

  /// Alterna la tarea entre completada y pendiente.
  /// Devuelve la tarea actualizada o `null` si ya no existe.
  Task? toggleCompleted(String id);

  /// Número total de tareas.
  int countAll();

  /// Número de tareas completadas.
  int countCompleted();
}
