// Formatos de texto en español.

/// 12.5 → "12,50 €"
String euros(double value) => '${value.toStringAsFixed(2).replaceAll('.', ',')} €';

/// 12.5 → "+12,50 €", -3 → "−3,00 €"
String signedEuros(double value) =>
    value >= 0 ? '+${euros(value)}' : '−${euros(-value)}';

/// 78.4 → "78 %"
String percent(double value) => '${value.round()} %';

const _weekdays = ['lun', 'mar', 'mié', 'jue', 'vie', 'sáb', 'dom'];
const _months = [
  'ene', 'feb', 'mar', 'abr', 'may', 'jun',
  'jul', 'ago', 'sep', 'oct', 'nov', 'dic',
];

/// "sáb 24 oct"
String shortDate(DateTime d) =>
    '${_weekdays[d.weekday - 1]} ${d.day} ${_months[d.month - 1]}';

/// "1 persona" / "4 personas"
String people(int n) => n == 1 ? '1 persona' : '$n personas';
