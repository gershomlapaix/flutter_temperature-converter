import 'conversion_type.dart';

/// Data class to represent a single conversion history entry
class ConversionHistory {
  final ConversionType type;
  final double inputValue;
  final double outputValue;
  final DateTime timestamp;

  ConversionHistory({
    required this.type,
    required this.inputValue,
    required this.outputValue,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Returns a formatted string representation of the conversion
  String get displayText {
    return '${inputValue.toStringAsFixed(1)}${type.inputUnit} => ${outputValue.toStringAsFixed(1)}${type.outputUnit}';
  }

  /// Returns a detailed conversion string
  String get detailText {
    return '${inputValue.toStringAsFixed(2)}${type.inputUnit} = ${outputValue.toStringAsFixed(2)}${type.outputUnit}';
  }
}