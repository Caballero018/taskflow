/// Modelo de dominio de una tarea.
///
/// Equivale a las entidades de la carpeta `Models/` del proyecto de
/// referencia: solo contiene datos, no sabe nada de la interfaz ni de cómo
/// se almacena.
///
/// Es inmutable (todos sus campos son `final`). Para "modificar" una tarea se
/// crea una copia con [copyWith], lo que evita cambios accidentales desde la UI.
class Task {
  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.isCompleted = false,
  });

  /// Identificador único generado localmente por el servicio.
  final String id;
  final String title;
  final String description;

  /// Fecha de creación (cumple el papel de `CreatedAt` en `BaseTable`).
  final DateTime createdAt;
  final bool isCompleted;

  /// Devuelve una copia de la tarea cambiando solo los campos indicados.
  /// El `id` y la fecha de creación nunca cambian.
  Task copyWith({String? title, String? description, bool? isCompleted}) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  String toString() =>
      'Task(id: $id, title: $title, isCompleted: $isCompleted)';
}
