import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/models/task.dart';

void main() {
  final task = Task(
    id: '1',
    title: 'Estudiar',
    description: 'Repasar Flutter',
    createdAt: DateTime(2026, 11, 21, 10, 30),
  );

  test('una tarea nueva está pendiente por defecto', () {
    expect(task.isCompleted, isFalse);
  });

  test('copyWith cambia solo los campos indicados', () {
    final copy = task.copyWith(isCompleted: true, title: 'Estudiar Dart');

    expect(copy.isCompleted, isTrue);
    expect(copy.title, 'Estudiar Dart');
    expect(copy.description, task.description);
    expect(copy.id, task.id);
    expect(copy.createdAt, task.createdAt);
    // El original no cambia: el modelo es inmutable.
    expect(task.isCompleted, isFalse);
    expect(task.title, 'Estudiar');
  });
}
