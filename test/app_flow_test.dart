import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/main.dart';
import 'package:taskflow/repositories/implementations/in_memory_task_repository.dart';
import 'package:taskflow/screens/task_detail_screen.dart';
import 'package:taskflow/screens/task_form_screen.dart';
import 'package:taskflow/screens/task_list_screen.dart';
import 'package:taskflow/services/contracts/task_service.dart';
import 'package:taskflow/services/implementations/task_service_impl.dart';

/// Pruebas del flujo completo de la app: navegación entre las tres
/// pantallas, creación, cambio de estado, eliminación y estados vacíos.
void main() {
  late TaskService service;

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // Igual que en main.dart, el servicio se inyecta en el widget raíz.
    service = TaskServiceImpl(InMemoryTaskRepository());
    await tester.pumpWidget(TaskFlowApp(taskService: service));
  }

  Finder counter(String key, String value) =>
      find.descendant(of: find.byKey(Key(key)), matching: find.text(value));

  Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> createTask(
    WidgetTester tester,
    String title,
    String description,
  ) async {
    await tapAndSettle(tester, find.byKey(const Key('add_task_button')));
    expect(find.byType(TaskFormScreen), findsOneWidget);

    await tester.enterText(find.byKey(const Key('title_field')), title);
    await tester.enterText(
      find.byKey(const Key('description_field')),
      description,
    );
    await tapAndSettle(tester, find.byKey(const Key('save_task_button')));
  }

  testWidgets('muestra bienvenida, contadores en cero y estado vacío', (
    tester,
  ) async {
    await pumpApp(tester);

    expect(find.text('TaskFlow'), findsOneWidget);
    expect(find.text('Bienvenido a TaskFlow'), findsOneWidget);
    expect(find.text('Aún no tienes tareas'), findsOneWidget);
    expect(counter('total_counter', '0'), findsOneWidget);
    expect(counter('completed_counter', '0'), findsOneWidget);
    expect(find.byKey(const Key('task_list')), findsNothing);
  });

  testWidgets('crea una tarea desde el formulario y aparece en el listado', (
    tester,
  ) async {
    await pumpApp(tester);

    await createTask(tester, 'Estudiar Flutter', 'Repasar Navigator y Form');

    expect(find.byType(TaskListScreen), findsOneWidget);
    expect(find.byType(TaskFormScreen), findsNothing);
    expect(find.text('Aún no tienes tareas'), findsNothing);
    expect(find.text('Estudiar Flutter'), findsOneWidget);
    expect(
      find.text('Tarea "Estudiar Flutter" creada correctamente'),
      findsOneWidget,
    );
    expect(counter('total_counter', '1'), findsOneWidget);
    expect(counter('completed_counter', '0'), findsOneWidget);
    expect(find.text('Te queda 1 tarea pendiente.'), findsOneWidget);
  });

  testWidgets('un formulario inválido no navega ni crea tareas', (
    tester,
  ) async {
    await pumpApp(tester);

    await tapAndSettle(tester, find.byKey(const Key('add_task_button')));
    await tapAndSettle(tester, find.byKey(const Key('save_task_button')));

    expect(find.byType(TaskFormScreen), findsOneWidget);
    expect(find.text('El título es obligatorio.'), findsOneWidget);

    await tapAndSettle(tester, find.byKey(const Key('cancel_button')));
    expect(find.text('Aún no tienes tareas'), findsOneWidget);
    expect(service.countAll(), 0);
  });

  testWidgets('marca una tarea como completada desde el listado', (
    tester,
  ) async {
    await pumpApp(tester);
    await createTask(tester, 'Comprar libros', 'Biblioteca del ITM');

    expect(find.text('Pendiente'), findsOneWidget);

    await tapAndSettle(tester, find.byType(Checkbox));

    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
    expect(find.text('Completada'), findsOneWidget);
    expect(counter('completed_counter', '1'), findsOneWidget);
    expect(
      find.text('¡Todo al día! Completaste todas tus tareas.'),
      findsOneWidget,
    );

    // Volver a pulsar la deja pendiente.
    await tapAndSettle(tester, find.byType(Checkbox));
    expect(counter('completed_counter', '0'), findsOneWidget);
    expect(find.text('Pendiente'), findsOneWidget);
  });

  testWidgets('el detalle muestra la tarea y cambia su estado', (tester) async {
    await pumpApp(tester);
    await createTask(tester, 'Sustentación', 'Presentar TaskFlow al profesor');

    await tapAndSettle(tester, find.text('Sustentación'));

    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(find.text('Detalle de la tarea'), findsOneWidget);
    expect(find.byKey(const Key('detail_title')), findsOneWidget);
    expect(find.text('Presentar TaskFlow al profesor'), findsOneWidget);
    expect(find.text('Fecha de creación'), findsOneWidget);
    // "Pendiente" aparece en la etiqueta y en la fila de estado.
    expect(find.text('Pendiente'), findsNWidgets(2));

    await tapAndSettle(tester, find.text('Marcar como completada'));
    expect(find.text('Completada'), findsNWidgets(2));
    expect(find.text('Marcar como pendiente'), findsOneWidget);

    // Al volver, el listado refleja el cambio hecho en el detalle.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(TaskListScreen), findsOneWidget);
    expect(counter('completed_counter', '1'), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
  });

  testWidgets('elimina una tarea tras confirmar y vuelve al estado vacío', (
    tester,
  ) async {
    await pumpApp(tester);
    await createTask(tester, 'Tarea temporal', 'Se va a eliminar');

    await tapAndSettle(tester, find.text('Tarea temporal'));

    // Cancelar el diálogo no elimina nada.
    await tapAndSettle(tester, find.byKey(const Key('delete_task_button')));
    expect(find.text('¿Eliminar tarea?'), findsOneWidget);
    await tapAndSettle(tester, find.text('Cancelar'));
    expect(find.byType(TaskDetailScreen), findsOneWidget);
    expect(service.countAll(), 1);

    // Confirmar sí elimina y regresa al listado.
    await tapAndSettle(tester, find.byKey(const Key('delete_task_button')));
    await tapAndSettle(tester, find.byKey(const Key('confirm_delete_button')));

    expect(find.byType(TaskDetailScreen), findsNothing);
    expect(find.byType(TaskListScreen), findsOneWidget);
    expect(find.text('Tarea "Tarea temporal" eliminada'), findsOneWidget);
    expect(find.text('Aún no tienes tareas'), findsOneWidget);
    expect(counter('total_counter', '0'), findsOneWidget);
    expect(service.countAll(), 0);
  });

  testWidgets('el detalle controla una tarea que ya no existe', (tester) async {
    await pumpApp(tester);
    await createTask(tester, 'Fantasma', 'Se elimina por fuera');

    await tapAndSettle(tester, find.text('Fantasma'));

    // Se elimina la tarea sin pasar por la pantalla (como si otra parte de
    // la app la hubiera borrado) y luego se intenta cambiar su estado.
    service.delete(service.getAll().single.id);
    await tapAndSettle(tester, find.byKey(const Key('toggle_status_button')));

    expect(find.text('Esta tarea ya no existe'), findsOneWidget);
    expect(find.byKey(const Key('toggle_status_button')), findsNothing);

    await tapAndSettle(tester, find.text('Volver al listado'));
    expect(find.byType(TaskListScreen), findsOneWidget);
    expect(find.text('Aún no tienes tareas'), findsOneWidget);
  });

  testWidgets('muestra varias tareas, la más reciente primero', (tester) async {
    await pumpApp(tester);
    await createTask(tester, 'Primera', 'uno');
    await createTask(tester, 'Segunda', 'dos');

    final first = tester.getTopLeft(find.text('Segunda'));
    final second = tester.getTopLeft(find.text('Primera'));
    expect(first.dy, lessThan(second.dy));
    expect(counter('total_counter', '2'), findsOneWidget);
    expect(find.text('Te quedan 2 tareas pendientes.'), findsOneWidget);
  });
}
