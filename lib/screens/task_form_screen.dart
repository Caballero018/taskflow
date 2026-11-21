import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/contracts/task_service.dart';
import '../validators/task_validator.dart';

/// Formulario para crear una tarea.
///
/// Técnicas utilizadas:
///   * `Form` + `GlobalKey<FormState>` para validar todos los campos a la vez.
///   * `TextFormField` con `validator`, que recibe los métodos de
///     [TaskValidator]. Flutter muestra el mensaje devuelto debajo del campo.
///   * `TextEditingController` para leer el texto escrito.
///   * `Navigator.pop(context, task)` para devolver la tarea creada a la
///     pantalla anterior.
class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({super.key, required this.taskService});

  final TaskService taskService;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  // Llave que identifica al Form y da acceso a validate().
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Antes del primer intento de guardar no se muestran errores; después, los
  // campos se revalidan mientras el usuario escribe.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    // Los controladores reservan recursos: se liberan al cerrar la pantalla.
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _save() {
    // validate() ejecuta el validator de cada TextFormField. Si alguno
    // devuelve un mensaje, el formulario no es válido y no se guarda nada.
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    // hideCurrentSnackBar: el aviso nuevo reemplaza al anterior en vez de
    // esperar en cola.
    final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
    try {
      final task = widget.taskService.create(
        title: _titleController.text,
        description: _descriptionController.text,
      );

      // Mensaje de confirmación. El ScaffoldMessenger es de toda la app, así
      // que el aviso sigue visible al volver al listado.
      messenger.showSnackBar(
        SnackBar(content: Text('Tarea "${task.title}" creada correctamente')),
      );
      Navigator.pop(context, task);
    } on ArgumentError catch (error) {
      // Segunda línea de defensa: el servicio también valida.
      messenger.showSnackBar(SnackBar(content: Text('${error.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva tarea')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: _autovalidateMode,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Describe lo que necesitas hacer',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Todos los campos son obligatorios.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('title_field'),
                controller: _titleController,
                textInputAction: TextInputAction.next,
                textCapitalization: TextCapitalization.sentences,
                // maxLength muestra el contador; con enforcement "none" el
                // usuario puede pasarse y el validador le muestra el error.
                maxLength: TaskValidator.titleMaxLength,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                decoration: const InputDecoration(
                  labelText: 'Título',
                  hintText: 'Ej.: Preparar la sustentación',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: TaskValidator.validateTitle,
              ),
              const SizedBox(height: 12),
              TextFormField(
                key: const Key('description_field'),
                controller: _descriptionController,
                textCapitalization: TextCapitalization.sentences,
                minLines: 4,
                maxLines: 6,
                maxLength: TaskValidator.descriptionMaxLength,
                maxLengthEnforcement: MaxLengthEnforcement.none,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  hintText: 'Detalla qué hay que hacer y cómo',
                  alignLabelWithHint: true,
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 72),
                    child: Icon(Icons.notes),
                  ),
                ),
                validator: TaskValidator.validateDescription,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                key: const Key('save_task_button'),
                onPressed: _save,
                icon: const Icon(Icons.check),
                label: const Text('Guardar tarea'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('cancel_button'),
                // Volver sin resultado: el listado no cambia.
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
