import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/validators/task_validator.dart';

void main() {
  group('TaskValidator.validateTitle', () {
    test('rechaza un título nulo o vacío', () {
      expect(TaskValidator.validateTitle(null), 'El título es obligatorio.');
      expect(TaskValidator.validateTitle(''), 'El título es obligatorio.');
    });

    test('rechaza un título con solo espacios', () {
      expect(
        TaskValidator.validateTitle('   '),
        'El título no puede contener solo espacios.',
      );
    });

    test('acepta exactamente 50 caracteres y rechaza 51', () {
      expect(TaskValidator.validateTitle('a' * 50), isNull);
      expect(
        TaskValidator.validateTitle('a' * 51),
        'El título no puede superar 50 caracteres.',
      );
    });

    test('ignora los espacios de los extremos al medir la longitud', () {
      expect(TaskValidator.validateTitle('  ${'a' * 50}  '), isNull);
    });
  });

  group('TaskValidator.validateDescription', () {
    test('rechaza una descripción vacía o con solo espacios', () {
      expect(
        TaskValidator.validateDescription(''),
        'La descripción es obligatoria.',
      );
      expect(
        TaskValidator.validateDescription('\n  '),
        'La descripción no puede contener solo espacios.',
      );
    });

    test('acepta 250 caracteres y rechaza 251', () {
      expect(TaskValidator.validateDescription('d' * 250), isNull);
      expect(
        TaskValidator.validateDescription('d' * 251),
        'La descripción no puede superar 250 caracteres.',
      );
    });
  });
}
