# TaskFlow

Aplicación móvil de gestión de tareas desarrollada en **Flutter**. Permite crear tareas, consultar su detalle, marcarlas como completadas o pendientes y eliminarlas, con validación de formularios y navegación entre pantallas.

## 1. Objetivo académico

Proyecto desarrollado para una actividad del **ITM (Instituto Tecnológico Metropolitano)** sobre desarrollo de aplicaciones móviles con Flutter. El objetivo es aplicar:

- Navegación entre pantallas.
- Construcción y validación de formularios.
- Diseño de interfaces con Material Design 3.
- La arquitectura en capas, las convenciones y las buenas prácticas del proyecto de referencia del profesor, `my-vaccine-api`.

## 2. Tecnologías utilizadas

| Tecnología | Uso |
|---|---|
| Flutter 3.47 / Dart 3.13 | Framework y lenguaje |
| Material Design 3 | Componentes y tema visual (`ColorScheme.fromSeed`) |
| `StatefulWidget` + `setState` | Estado y actualización de la interfaz |
| `Navigator.push` / `Navigator.pop` + `MaterialPageRoute` | Navegación |
| `Form`, `GlobalKey<FormState>`, `TextFormField` | Formulario y validación |
| `flutter_test` | Pruebas unitarias y de widgets |
| `flutter_lints` | Análisis estático |

La app **no tiene dependencias externas**: solo usa el SDK de Flutter y `cupertino_icons`, que viene en la plantilla. No usa Firebase, backend, base de datos ni librerías de gestión de estado. Las tareas se guardan **en memoria** y se pierden al cerrar la app.

## 3. Arquitectura implementada

La arquitectura adapta a Flutter las capas del proyecto de referencia:

```
my-vaccine-api (ASP.NET Core):  Controller → Service → Repository → DbContext
TaskFlow (Flutter):             Screen     → Service → Repository (en memoria)
```

```
┌──────────────────────┐   usa el contrato    ┌──────────────────┐   usa el contrato   ┌──────────────────────────┐
│ Screens (UI)         │ ───────────────────▶ │ TaskService      │ ──────────────────▶ │ TaskRepository           │
│ TaskListScreen       │                      │ TaskServiceImpl  │                     │ InMemoryTaskRepository   │
│ TaskFormScreen       │                      │ (lógica negocio) │                     │ (lista privada)          │
│ TaskDetailScreen     │                      └────────┬─────────┘                     └──────────────────────────┘
└──────────────────────┘                               │ valida con
                                                       ▼
                                                 TaskValidator
```

Principios aplicados:

- **Separación de responsabilidades.** Las pantallas solo muestran datos y reaccionan a eventos. El servicio contiene las reglas de negocio: genera el id, valida, normaliza los textos y cambia el estado. El repositorio solo almacena.
- **Contratos mediante interfaces.** `TaskRepository` y `TaskService` son `abstract class`. Las capas dependen del contrato, no de la implementación.
- **Inyección de dependencias por constructor.** `main.dart` crea las implementaciones una sola vez y las entrega por constructor: repositorio → servicio → app → pantallas.
- **Modelo inmutable.** `Task` solo tiene campos `final`; para cambiarla se usa `copyWith`.
- **Encapsulamiento.** La colección interna del repositorio es privada y `getAll()` devuelve una lista no modificable.
- **Validación en dos niveles.** El formulario valida con `TaskValidator` y el servicio vuelve a validar antes de guardar.

## 4. Estructura de carpetas

```
lib/
├── main.dart                         # Punto de entrada y composición de dependencias
├── models/
│   └── task.dart                     # Modelo Task (id, title, description, createdAt, isCompleted)
├── repositories/
│   ├── contracts/
│   │   └── task_repository.dart      # Contrato del repositorio
│   └── implementations/
│       └── in_memory_task_repository.dart
├── services/
│   ├── contracts/
│   │   └── task_service.dart         # Contrato del servicio
│   └── implementations/
│       └── task_service_impl.dart    # Lógica de negocio
├── validators/
│   └── task_validator.dart           # Reglas de validación
├── screens/
│   ├── task_list_screen.dart         # Pantalla principal
│   ├── task_form_screen.dart         # Formulario de creación
│   └── task_detail_screen.dart       # Detalle de la tarea
├── widgets/
│   ├── task_tile.dart                # Tarjeta reutilizable del listado
│   └── task_status_chip.dart         # Etiqueta Completada/Pendiente (listado y detalle)
├── theme/
│   └── app_theme.dart                # Tema Material 3 centralizado
└── utils/
    └── date_formatter.dart           # Fechas en español sin el paquete intl

test/
├── models/            validators/            repositories/            services/
├── screens/task_form_screen_test.dart        # Prueba de widget del formulario
└── app_flow_test.dart                        # Flujo completo entre las tres pantallas
```

Frente a la estructura inicial se agregaron tres archivos pequeños:
- `theme/app_theme.dart`, para no repetir estilos en las pantallas.
- `utils/date_formatter.dart`, para evitar una dependencia externa.
- `widgets/task_status_chip.dart`, que se reutiliza en dos pantallas.

## 5. Funcionalidades

1. **Listado de tareas.** Muestra una bienvenida, los contadores de tareas totales y completadas, una barra de progreso, el listado con `ListView.builder` (la tarea más reciente primero) y un estado vacío cuando no hay tareas.
2. **Crear tareas.** Formulario con título y descripción, botones de guardar y cancelar, y un mensaje de confirmación.
3. **Validaciones.**
   - Título: obligatorio, no puede ser solo espacios, máximo 50 caracteres.
   - Descripción: obligatoria, no puede ser solo espacios, máximo 250 caracteres.
   - Los errores aparecen debajo de cada campo, con un contador de caracteres.
4. **Detalle.** Muestra título, descripción, fecha de creación y estado actual.
5. **Completar o reabrir tareas.** Desde la casilla del listado o desde el botón del detalle.
6. **Diferenciación visual.** Las tareas completadas se ven con el título tachado, una casilla verde, la etiqueta "Completada" y la tarjeta atenuada.
7. **Eliminar.** Desde el detalle, con un diálogo de confirmación.
8. **Tarea inexistente.** Si se abre el detalle de una tarea eliminada, la app muestra "Esta tarea ya no existe" y un botón para volver.

## 6. Requisitos previos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.47 o superior (incluye Dart 3.13).
- Un emulador Android o iOS, un dispositivo físico, o Chrome para ejecutar la versión web.
- Git.

Para comprobar el entorno:

```bash
flutter --version
flutter doctor
```

## 7. Instalación

```bash
git clone <url-del-repositorio> taskflow
cd taskflow
flutter pub get
```

## 8. Ejecución

```bash
flutter devices                # lista los dispositivos disponibles
flutter run                    # ejecuta en el dispositivo por defecto
flutter run -d chrome          # ejecuta en el navegador
flutter run -d <id-dispositivo>
```

Compilaciones:

```bash
flutter build apk              # Android (requiere Android SDK)
flutter build web              # Web, el resultado queda en build/web
```

## 9. Pruebas

```bash
flutter analyze                # análisis estático (sin incidencias)
flutter test                   # 31 pruebas
```

| Archivo | Qué comprueba |
|---|---|
| `test/models/task_test.dart` | Valores por defecto e inmutabilidad con `copyWith` |
| `test/validators/task_validator_test.dart` | Campos obligatorios, solo espacios, límites de 50 y 250 caracteres |
| `test/repositories/in_memory_task_repository_test.dart` | CRUD y que la colección interna no se pueda modificar desde fuera |
| `test/services/task_service_impl_test.dart` | Crear, ids únicos, rechazo de datos inválidos, orden, cambio de estado, contadores, actualizar y eliminar |
| `test/screens/task_form_screen_test.dart` | **Prueba de widget del formulario:** errores debajo de los campos, revalidación, guardado con confirmación y cancelación |
| `test/app_flow_test.dart` | Estado vacío, crear desde el botón flotante, completar desde el listado, detalle y cambio de estado, eliminar con confirmación, tarea inexistente y orden del listado |

## 10. Relación entre la arquitectura del profesor y TaskFlow

| `my-vaccine-api` (C# / ASP.NET Core) | TaskFlow (Dart / Flutter) |
|---|---|
| `Program.cs` | `lib/main.dart` |
| `Configurations/Injections/DependencyInjections.cs` (`SetDependencyInjection`) | Composición manual en `main()`, con inyección por constructor |
| `Models/` (entidades) + `BaseTable.CreatedAt` | `models/task.dart` (`createdAt`) |
| `Repositories/Contracts/IBaseRepository<T>` | `repositories/contracts/task_repository.dart` |
| `Repositories/Implementations/BaseRepository<T>` + `DbContext` | `repositories/implementations/in_memory_task_repository.dart` |
| `Services/Contracts/IXxxService` | `services/contracts/task_service.dart` |
| `Services/Implementations/XxxService` | `services/implementations/task_service_impl.dart` |
| `Configurations/Validators/` con `RuleFor(x => x.Name).NotEmpty().MaximumLength(50)` | `validators/task_validator.dart` con `validateTitle`: obligatorio y máximo 50 |
| `Controllers/` (validan, llaman al servicio y responden) | `screens/` (validan el `Form`, llaman al servicio y redibujan) |
| `Guid.NewGuid().ToString()` | Id local: marca de tiempo + secuencia, sin dependencias |
| `NotFound()` cuando el registro no existe | Estado "Esta tarea ya no existe" en el detalle |
| Campos `private readonly _service` | Campos `final _taskRepository` |
| Interfaces `IXxx` | `abstract class` |

Prácticas del proyecto de referencia que **no** se copiaron a propósito:
- Secretos escritos en el código.
- Accesos sin comprobar `null`.
- Reglas de validación incorrectas, como `NotEmpty` sobre un `bool`.
- La ausencia de pruebas.

## Autor

Proyecto académico — ITM, 2026.
