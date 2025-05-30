import '../models/conversion_type.dart';

/// Utility class for temperature conversion calculations
class TemperatureCalculator {
  /// Converts Fahrenheit to Celsius using the formula: °C = (°F - 32) × 5/9
  static double fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Converts Celsius to Fahrenheit using the formula: °F = °C × 9/5 + 32
  static double celsiusToFahrenheit(double celsius) {
    return celsius * 9 / 5 + 32;
  }

  /// Performs conversion based on the conversion type
  static double convert(double value, ConversionType type) {
    switch (type) {
      case ConversionType.fahrenheitToCelsius:
        return fahrenheitToCelsius(value);
      case ConversionType.celsiusToFahrenheit:
        return celsiusToFahrenheit(value);
    }
  }

  /// Validates temperature input
  static String? validateTemperatureInput(String? value, ConversionType type) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a temperature value';
    }

    final numericValue = double.tryParse(value.trim());
    if (numericValue == null) {
      return 'Please enter a valid number';
    }

    // Check for extreme temperature values (basic validation)
    if (type == ConversionType.fahrenheitToCelsius) {
      if (numericValue < -459.67) {
        return 'Temperature cannot be below absolute zero (-459.67°F)';
      }
    } else {
      if (numericValue < -273.15) {
        return 'Temperature cannot be below absolute zero (-273.15°C)';
      }
    }

    return null;
  }
}