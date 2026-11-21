import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/repositories/implementations/in_memory_task_repository.dart';
import 'package:taskflow/services/contracts/task_service.dart';
import 'package:taskflow/services/implementations/task_service_impl.dart';

void main() {
  final fixedDate = DateTime(2026, 11, 21, 9, 15);
  late TaskService service;

  setUp(() {
    // Se inyecta el repositorio y un reloj fijo, igual que en la app real
    // se inyecta el repositorio en main.dart.
    service = TaskServiceImpl(InMemoryTaskRepository(), clock: () => fixedDate);
  });

  test('create guarda una tarea pendiente con datos normalizados', () {
    final task = service.create(title: '  Comprar  ', description: ' Leche ');

    expect(task.title, 'Comprar');
    expect(task.description, 'Leche');
    expect(task.isCompleted, isFalse);
    expect(task.createdAt, fixedDate);
    expect(service.getById(task.id), isNotNull);
  });

  test('create genera ids únicos aunque la hora sea la misma', () {
    final a = service.create(title: 'A', description: 'a');
    final b = service.create(title: 'B', description: 'b');

    expect(a.id, isNot(b.id));
  });

  test('create rechaza datos inválidos', () {
    expect(
      () => service.create(title: '', description: 'algo'),
      throwsArgumentError,
    );
    expect(
      () => service.create(title: 'Título', description: 'x' * 251),
      throwsArgumentError,
    );
    expect(service.countAll(), 0);
  });

  test('getAll devuelve primero la tarea más reciente', () {
    service.create(title: 'Primera', description: 'p');
    service.create(title: 'Segunda', description: 's');

    expect(service.getAll().map((t) => t.title), ['Segunda', 'Primera']);
  });

  test('toggleCompleted alterna el estado y actualiza los contadores', () {
    final task = service.create(title: 'Tarea', description: 'd');
    service.create(title: 'Otra', description: 'd');

    expect(service.toggleCompleted(task.id)!.isCompleted, isTrue);
    expect(service.countAll(), 2);
    expect(service.countCompleted(), 1);

    expect(service.toggleCompleted(task.id)!.isCompleted, isFalse);
    expect(service.countCompleted(), 0);
    expect(service.toggleCompleted('no-existe'), isNull);
  });

  test('update modifica una tarea existente y devuelve null si no existe', () {
    final task = service.create(title: 'Tarea', description: 'd');

    final updated = service.update(task.copyWith(title: 'Nuevo título'));
    expect(updated?.title, 'Nuevo título');
    expect(service.getById(task.id)!.title, 'Nuevo título');

    service.delete(task.id);
    expect(service.update(task), isNull);
  });

  test('delete elimina la tarea', () {
    final task = service.create(title: 'Tarea', description: 'd');

    expect(service.delete(task.id), isTrue);
    expect(service.getById(task.id), isNull);
    expect(service.delete(task.id), isFalse);
  });
}
