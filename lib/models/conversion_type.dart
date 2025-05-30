/// Enum to represent the two conversion types available
enum ConversionType {
  fahrenheitToCelsius,
  celsiusToFahrenheit
}

/// Extension to add helpful methods to ConversionType
extension ConversionTypeExtension on ConversionType {
  /// Returns the input unit symbol
  String get inputUnit {
    switch (this) {
      case ConversionType.fahrenheitToCelsius:
        return '°F';
      case ConversionType.celsiusToFahrenheit:
        return '°C';
    }
  }

  /// Returns the output unit symbol
  String get outputUnit {
    switch (this) {
      case ConversionType.fahrenheitToCelsius:
        return '°C';
      case ConversionType.celsiusToFahrenheit:
        return '°F';
    }
  }

  /// Returns the conversion title
  String get title {
    switch (this) {
      case ConversionType.fahrenheitToCelsius:
        return 'Fahrenheit to Celsius (°F → °C)';
      case ConversionType.celsiusToFahrenheit:
        return 'Celsius to Fahrenheit (°C → °F)';
    }
  }

  /// Returns the conversion formula
  String get formula {
    switch (this) {
      case ConversionType.fahrenheitToCelsius:
        return '°C = (°F - 32) × 5/9';
      case ConversionType.celsiusToFahrenheit:
        return '°F = °C × 9/5 + 32';
    }
  }
}