import '../../models/task.dart';
import '../../repositories/contracts/task_repository.dart';
import '../../validators/task_validator.dart';
import '../contracts/task_service.dart';

/// Implementación del servicio de tareas: aquí vive la lógica de negocio.
///
/// Equivale a las clases de `Services/Implementations/` del proyecto de
/// referencia (por ejemplo `DependentService`): recibe el repositorio por
/// constructor, crea las entidades, les asigna el identificador y decide
/// qué guardar.
class TaskServiceImpl implements TaskService {
  /// Inyección de dependencias por constructor: el servicio recibe el
  /// contrato [TaskRepository], no una implementación concreta.
  /// [clock] permite fijar la fecha en las pruebas; por defecto es la hora
  /// actual.
  TaskServiceImpl(this._taskRepository, {DateTime Function()? clock})
      : _clock = clock ?? DateTime.now;

  final TaskRepository _taskRepository;
  final DateTime Function() _clock;

  /// Contador que evita ids repetidos si se crean dos tareas en el mismo
  /// microsegundo.
  int _sequence = 0;

  @override
  List<Task> getAll() {
    // El repositorio conserva el orden de inserción; se invierte una copia
    // para mostrar primero la tarea más reciente.
    return List<Task>.unmodifiable(_taskRepository.getAll().reversed);
  }

  @override
  Task? getById(String id) => _taskRepository.getById(id);

  @override
  Task create({required String title, required String description}) {
    // Se valida también aquí, no solo en el formulario: el servicio nunca
    // guarda datos inválidos, venga de donde venga la petición.
    _ensureValid(title: title, description: description);

    final task = Task(
      id: _generateId(),
      title: title.trim(),
      description: description.trim(),
      createdAt: _clock(),
    );
    _taskRepository.add(task);
    return task;
  }

  @override
  Task? update(Task task) {
    _ensureValid(title: task.title, description: task.description);

    final normalized = task.copyWith(
      title: task.title.trim(),
      description: task.description.trim(),
    );
    return _taskRepository.update(normalized) ? normalized : null;
  }

  @override
  bool delete(String id) => _taskRepository.delete(id);

  @override
  Task? toggleCompleted(String id) {
    final task = _taskRepository.getById(id);
    if (task == null) return null;

    final updated = task.copyWith(isCompleted: !task.isCompleted);
    _taskRepository.update(updated);
    return updated;
  }

  @override
  int countAll() => _taskRepository.getAll().length;

  @override
  int countCompleted() =>
      _taskRepository.getAll().where((task) => task.isCompleted).length;

  /// Id local sin dependencias externas: marca de tiempo + secuencia.
  /// Cumple el papel de `Guid.NewGuid().ToString()` del proyecto original.
  String _generateId() {
    _sequence++;
    return '${_clock().microsecondsSinceEpoch}-$_sequence';
  }

  void _ensureValid({required String title, required String description}) {
    final error = TaskValidator.validateTitle(title) ??
        TaskValidator.validateDescription(description);
    if (error != null) throw ArgumentError(error);
  }
}
