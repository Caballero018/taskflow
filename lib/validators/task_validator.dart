/// Reglas de validación de una tarea.
///
/// Equivale a los validadores de `Configurations/Validators/` del proyecto de
/// referencia, por ejemplo:
///   `RuleFor(dto => dto.Name).NotEmpty().MaximumLength(50);`
///
/// Cada método recibe el texto del campo y devuelve:
///   * `null` si el valor es válido.
///   * Un mensaje de error si no lo es.
/// Esa es exactamente la firma que espera `TextFormField.validator`, por eso
/// los métodos se pueden pasar directamente al formulario. El servicio
/// también los usa para no guardar nunca datos inválidos.
class TaskValidator {
  // Constructor privado: la clase solo agrupa métodos estáticos.
  TaskValidator._();

  static const int titleMaxLength = 50;
  static const int descriptionMaxLength = 250;

  /// Título: obligatorio, no vacío y máximo [titleMaxLength] caracteres.
  static String? validateTitle(String? value) {
    return _validateRequiredText(
      value,
      maxLength: titleMaxLength,
      requiredMessage: 'El título es obligatorio.',
      blankMessage: 'El título no puede contener solo espacios.',
      tooLongMessage: 'El título no puede superar $titleMaxLength caracteres.',
    );
  }

  /// Descripción: obligatoria, no vacía y máximo [descriptionMaxLength]
  /// caracteres.
  static String? validateDescription(String? value) {
    return _validateRequiredText(
      value,
      maxLength: descriptionMaxLength,
      requiredMessage: 'La descripción es obligatoria.',
      blankMessage: 'La descripción no puede contener solo espacios.',
      tooLongMessage:
          'La descripción no puede superar $descriptionMaxLength caracteres.',
    );
  }

  /// Regla común: equivalente a `NotEmpty().MaximumLength(n)`.
  /// La longitud se mide sobre el texto sin espacios al inicio ni al final,
  /// que es el valor que finalmente se guarda.
  static String? _validateRequiredText(
    String? value, {
    required int maxLength,
    required String requiredMessage,
    required String blankMessage,
    required String tooLongMessage,
  }) {
    if (value == null || value.isEmpty) return requiredMessage;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return blankMessage;
    if (trimmed.length > maxLength) return tooLongMessage;

    return null;
  }
}
