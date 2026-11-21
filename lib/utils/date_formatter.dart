/// Formato de fechas en español sin depender del paquete `intl`.
class DateFormatter {
  DateFormatter._();

  static const List<String> _shortMonths = [
    'ene',
    'feb',
    'mar',
    'abr',
    'may',
    'jun',
    'jul',
    'ago',
    'sep',
    'oct',
    'nov',
    'dic',
  ];

  static const List<String> _longMonths = [
    'enero',
    'febrero',
    'marzo',
    'abril',
    'mayo',
    'junio',
    'julio',
    'agosto',
    'septiembre',
    'octubre',
    'noviembre',
    'diciembre',
  ];

  /// Ejemplo: `21 nov 2026, 09:05`.
  static String short(DateTime date) =>
      '${date.day} ${_shortMonths[date.month - 1]} ${date.year}, '
      '${_time(date)}';

  /// Ejemplo: `21 de noviembre de 2026, 09:05`.
  static String long(DateTime date) =>
      '${date.day} de ${_longMonths[date.month - 1]} de ${date.year}, '
      '${_time(date)}';

  static String _time(DateTime date) =>
      '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
