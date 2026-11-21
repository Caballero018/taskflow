import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/models/task.dart';
import 'package:taskflow/repositories/implementations/in_memory_task_repository.dart';

Task _task(String id) => Task(
      id: id,
      title: 'Tarea $id',
      description: 'Descripción $id',
      createdAt: DateTime(2026, 11, 21),
    );

void main() {
  late InMemoryTaskRepository repository;

  setUp(() => repository = InMemoryTaskRepository());

  test('add y getById guardan y recuperan una tarea', () {
    repository.add(_task('1'));

    expect(repository.getAll(), hasLength(1));
    expect(repository.getById('1')?.title, 'Tarea 1');
    expect(repository.getById('no-existe'), isNull);
  });

  test('getAll devuelve una lista que no se puede modificar', () {
    repository.add(_task('1'));

    expect(() => repository.getAll().add(_task('2')), throwsUnsupportedError);
    expect(repository.getAll(), hasLength(1));
  });

  test('update reemplaza la tarea y avisa si no existe', () {
    repository.add(_task('1'));

    expect(repository.update(_task('1').copyWith(isCompleted: true)), isTrue);
    expect(repository.getById('1')!.isCompleted, isTrue);
    expect(repository.update(_task('2')), isFalse);
  });

  test('delete elimina la tarea y avisa si no existe', () {
    repository.add(_task('1'));

    expect(repository.delete('1'), isTrue);
    expect(repository.getAll(), isEmpty);
    expect(repository.delete('1'), isFalse);
  });
}
