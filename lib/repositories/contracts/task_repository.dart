import '../../models/task.dart';

/// Contrato del repositorio de tareas.
///
/// Equivale a `IBaseRepository<T>` del proyecto de referencia: define QUÉ
/// operaciones de almacenamiento existen, sin decir CÓMO se implementan.
/// En Dart las interfaces se declaran con `abstract class`.
///
/// Gracias a este contrato, el servicio no depende de la memoria: mañana se
/// podría crear otra implementación (archivo, base de datos, API) sin cambiar
/// el servicio ni las pantallas.
///
/// Las operaciones son síncronas porque el almacenamiento es en memoria.
abstract class TaskRepository {
  /// Devuelve todas las tareas en una lista de solo lectura.
  List<Task> getAll();

  /// Devuelve la tarea con ese [id] o `null` si no existe.
  Task? getById(String id);

  /// Agrega una tarea nueva.
  void add(Task task);

  /// Reemplaza la tarea que tenga el mismo id.
  /// Devuelve `false` si la tarea no existe.
  bool update(Task task);

  /// Elimina la tarea con ese [id]. Devuelve `false` si no existía.
  bool delete(String id);
}
