/// Temperature conversion utilities.
class TemperatureUtils {
  TemperatureUtils._();

  /// Convert Celsius to Fahrenheit.
  static double celsiusToFahrenheit(double celsius) {
    return (celsius * 9 / 5) + 32;
  }

  /// Convert Fahrenheit to Celsius.
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Format temperature with unit label.
  static String format(double celsius, {bool useFahrenheit = false, int decimals = 1}) {
    if (useFahrenheit) {
      final f = celsiusToFahrenheit(celsius);
      return '${f.toStringAsFixed(decimals)}°F';
    }
    return '${celsius.toStringAsFixed(decimals)}°C';
  }

  /// Get a descriptive label for battery temperature.
  static String getTemperatureLabel(double celsius) {
    if (celsius < 30) return 'Cool';
    if (celsius < 35) return 'Normal';
    if (celsius < 40) return 'Warm';
    if (celsius < 45) return 'Hot';
    return 'Very Hot';
  }

  /// Get a color-like severity level (0=cool, 1=normal, 2=warm, 3=hot, 4=very hot).
  static int getSeverityLevel(double celsius) {
    if (celsius < 30) return 0;
    if (celsius < 35) return 1;
    if (celsius < 40) return 2;
    if (celsius < 45) return 3;
    return 4;
  }
}
