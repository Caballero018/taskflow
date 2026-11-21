import '../../models/task.dart';
import '../contracts/task_repository.dart';

/// Implementación del repositorio que guarda las tareas en memoria.
///
/// Cumple el papel de `BaseRepository<T>` + `DbContext` del proyecto de
/// referencia, pero en lugar de SQL Server usa una lista privada. Los datos
/// se pierden al cerrar la aplicación (persistencia temporal).
class InMemoryTaskRepository implements TaskRepository {
  /// Constructor opcional con tareas iniciales (útil en pruebas).
  InMemoryTaskRepository({List<Task> initialTasks = const []})
      : _tasks = List<Task>.of(initialTasks);

  /// Colección interna. Es privada (`_`) para que nadie fuera de esta clase
  /// pueda modificarla directamente.
  final List<Task> _tasks;

  @override
  List<Task> getAll() {
    // Se devuelve una copia no modificable: la UI puede leer, pero no
    // agregar ni quitar elementos de la colección interna.
    return List<Task>.unmodifiable(_tasks);
  }

  @override
  Task? getById(String id) {
    for (final task in _tasks) {
      if (task.id == id) return task;
    }
    return null;
  }

  @override
  void add(Task task) {
    _tasks.add(task);
  }

  @override
  bool update(Task task) {
    final index = _indexOf(task.id);
    if (index == -1) return false;
    _tasks[index] = task;
    return true;
  }

  @override
  bool delete(String id) {
    final index = _indexOf(id);
    if (index == -1) return false;
    _tasks.removeAt(index);
    return true;
  }

  int _indexOf(String id) => _tasks.indexWhere((task) => task.id == id);
}
