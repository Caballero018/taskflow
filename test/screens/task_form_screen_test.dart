import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/models/task.dart';
import 'package:taskflow/repositories/implementations/in_memory_task_repository.dart';
import 'package:taskflow/screens/task_form_screen.dart';
import 'package:taskflow/services/contracts/task_service.dart';
import 'package:taskflow/services/implementations/task_service_impl.dart';

void main() {
  late TaskService service;
  // Resultado que TaskFormScreen devuelve con Navigator.pop.
  Task? popResult;
  bool popped = false;

  setUp(() {
    service = TaskServiceImpl(InMemoryTaskRepository());
    popResult = null;
    popped = false;
  });

  /// Monta una pantalla con un botón que abre el formulario, para poder
  /// comprobar lo que devuelve al cerrarse.
  Future<void> openForm(WidgetTester tester) async {
    // Tamaño de pantalla de un teléfono (360 x 800 lógicos).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  popResult = await Navigator.push<Task>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => TaskFormScreen(taskService: service),
                    ),
                  );
                  popped = true;
                },
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskFormScreen), findsOneWidget);
  }

  Future<void> tapByKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra los errores debajo de los campos vacíos', (
    tester,
  ) async {
    await openForm(tester);

    await tapByKey(tester, 'save_task_button');

    expect(find.text('El título es obligatorio.'), findsOneWidget);
    expect(find.text('La descripción es obligatoria.'), findsOneWidget);
    expect(find.byType(TaskFormScreen), findsOneWidget);
    expect(service.countAll(), 0);
  });

  testWidgets('valida espacios en blanco y longitud máxima', (tester) async {
    await openForm(tester);

    await tester.enterText(find.byKey(const Key('title_field')), 'a' * 51);
    await tester.enterText(find.byKey(const Key('description_field')), '   ');
    await tapByKey(tester, 'save_task_button');

    expect(
      find.text('El título no puede superar 50 caracteres.'),
      findsOneWidget,
    );
    expect(
      find.text('La descripción no puede contener solo espacios.'),
      findsOneWidget,
    );
    expect(service.countAll(), 0);

    // Tras el primer intento, los errores se actualizan al escribir.
    await tester.enterText(find.byKey(const Key('title_field')), 'Correcto');
    await tester.pump();
    expect(
      find.text('El título no puede superar 50 caracteres.'),
      findsNothing,
    );
  });

  testWidgets('guarda una tarea válida, confirma y regresa con ella', (
    tester,
  ) async {
    await openForm(tester);

    await tester.enterText(
      find.byKey(const Key('title_field')),
      'Preparar sustentación',
    );
    await tester.enterText(
      find.byKey(const Key('description_field')),
      'Ensayar la demo de TaskFlow',
    );
    await tapByKey(tester, 'save_task_button');

    expect(find.byType(TaskFormScreen), findsNothing);
    expect(popped, isTrue);
    expect(popResult?.title, 'Preparar sustentación');
    expect(service.countAll(), 1);
    expect(
      find.text('Tarea "Preparar sustentación" creada correctamente'),
      findsOneWidget,
    );
  });

  testWidgets('cancelar regresa sin crear ninguna tarea', (tester) async {
    await openForm(tester);

    await tester.enterText(find.byKey(const Key('title_field')), 'Borrador');
    await tapByKey(tester, 'cancel_button');

    expect(find.byType(TaskFormScreen), findsNothing);
    expect(popped, isTrue);
    expect(popResult, isNull);
    expect(service.countAll(), 0);
  });
}
