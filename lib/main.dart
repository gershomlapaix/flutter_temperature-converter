import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const TemperatureConverterApp());
}

/// Main application widget that sets up the app theme and home screen
class TemperatureConverterApp extends StatelessWidget {
  const TemperatureConverterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
      home: const TemperatureConverterScreen(),
    );
  }
}

/// Enum to represent the two conversion types available
enum ConversionType {
  fahrenheitToCelsius,
  celsiusToFahrenheit,
}

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
    required this.timestamp,
  });

  /// Returns a formatted string representation of the conversion
  String get formattedConversion {
    switch (type) {
      case ConversionType.fahrenheitToCelsius:
        return 'F to C: ${inputValue.toStringAsFixed(1)} => ${outputValue.toStringAsFixed(1)}';
      case ConversionType.celsiusToFahrenheit:
        return 'C to F: ${inputValue.toStringAsFixed(1)} => ${outputValue.toStringAsFixed(1)}';
    }
  }

  /// Returns the unit symbol for the input temperature
  String get inputUnit {
    return type == ConversionType.fahrenheitToCelsius ? '°F' : '°C';
  }

  /// Returns the unit symbol for the output temperature
  String get outputUnit {
    return type == ConversionType.fahrenheitToCelsius ? '°C' : '°F';
  }
}

/// Main screen widget that handles all temperature conversion functionality
class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() => _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen>
    with TickerProviderStateMixin {
  // Controllers and state variables
  final TextEditingController _temperatureController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ConversionType _selectedConversionType = ConversionType.fahrenheitToCelsius;
  double? _convertedValue;
  List<ConversionHistory> _conversionHistory = [];

  // Animation controllers for enhanced UI experience
  late AnimationController _resultAnimationController;
  late AnimationController _historyAnimationController;
  late Animation<double> _resultScaleAnimation;
  late Animation<Offset> _historySlideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  /// Initialize animation controllers and animations
  void _initializeAnimations() {
    _resultAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _historyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _resultScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _resultAnimationController,
      curve: Curves.elasticOut,
    ));

    _historySlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _historyAnimationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _temperatureController.dispose();
    _resultAnimationController.dispose();
    _historyAnimationController.dispose();
    super.dispose();
  }

  /// Converts Fahrenheit to Celsius using the formula: °C = (°F - 32) × 5/9
  double _fahrenheitToCelsius(double fahrenheit) {
    return (fahrenheit - 32) * 5 / 9;
  }

  /// Converts Celsius to Fahrenheit using the formula: °F = °C × 9/5 + 32
  double _celsiusToFahrenheit(double celsius) {
    return celsius * 9 / 5 + 32;
  }

  /// Validates and performs the temperature conversion
  void _performConversion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inputText = _temperatureController.text.trim();
    final inputValue = double.tryParse(inputText);

    if (inputValue == null) {
      _showErrorSnackBar('Please enter a valid number');
      return;
    }

    // Perform the appropriate conversion
    double convertedValue;
    switch (_selectedConversionType) {
      case ConversionType.fahrenheitToCelsius:
        convertedValue = _fahrenheitToCelsius(inputValue);
        break;
      case ConversionType.celsiusToFahrenheit:
        convertedValue = _celsiusToFahrenheit(inputValue);
        break;
    }

    // Update state and add to history
    setState(() {
      _convertedValue = convertedValue;
      _conversionHistory.insert(
        0,
        ConversionHistory(
          type: _selectedConversionType,
          inputValue: inputValue,
          outputValue: convertedValue,
          timestamp: DateTime.now(),
        ),
      );
    });

    // Trigger animations
    _resultAnimationController.forward();
    _historyAnimationController.forward();

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Clear the input field for the next conversion
    _temperatureController.clear();
  }

  /// Shows an error message using SnackBar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  /// Clears all conversion history with confirmation dialog
  void _clearHistory() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text('Are you sure you want to clear all conversion history?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _conversionHistory.clear();
                  _convertedValue = null;
                });
                _resultAnimationController.reset();
                _historyAnimationController.reset();
                Navigator.of(context).pop();
                HapticFeedback.mediumImpact();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  /// Validates temperature input to ensure it's a valid number
  String? _validateTemperatureInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a temperature value';
    }

    final numericValue = double.tryParse(value.trim());
    if (numericValue == null) {
      return 'Please enter a valid number';
    }

    // Check for extreme temperature values (basic validation)
    if (_selectedConversionType == ConversionType.fahrenheitToCelsius) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Temperature Converter',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          if (_conversionHistory.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: SafeArea(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return orientation == Orientation.portrait
                ? _buildPortraitLayout()
                : _buildLandscapeLayout();
          },
        ),
      ),
    );
  }

  /// Builds the UI layout for portrait orientation
  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConversionCard(),
          const SizedBox(height: 24),
          _buildResultCard(),
          const SizedBox(height: 24),
          _buildHistorySection(),
        ],
      ),
    );
  }

  /// Builds the UI layout for landscape orientation
  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                _buildConversionCard(),
                const SizedBox(height: 16),
                _buildResultCard(),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: _buildHistorySection(),
          ),
        ),
      ],
    );
  }

  /// Builds the main conversion input card
  Widget _buildConversionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Convert Temperature',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildConversionTypeSelector(),
              const SizedBox(height: 20),
              _buildTemperatureInputField(),
              const SizedBox(height: 24),
              _buildConvertButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the conversion type selector (Radio buttons)
  Widget _buildConversionTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conversion Type:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
            ),
          ),
          child: Column(
            children: [
              RadioListTile<ConversionType>(
                title: const Text('Fahrenheit to Celsius (°F → °C)'),
                subtitle: const Text('°C = (°F - 32) × 5/9'),
                value: ConversionType.fahrenheitToCelsius,
                groupValue: _selectedConversionType,
                onChanged: (ConversionType? value) {
                  setState(() {
                    _selectedConversionType = value!;
                    _convertedValue = null;
                  });
                  _resultAnimationController.reset();
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              RadioListTile<ConversionType>(
                title: const Text('Celsius to Fahrenheit (°C → °F)'),
                subtitle: const Text('°F = °C × 9/5 + 32'),
                value: ConversionType.celsiusToFahrenheit,
                groupValue: _selectedConversionType,
                onChanged: (ConversionType? value) {
                  setState(() {
                    _selectedConversionType = value!;
                    _convertedValue = null;
                  });
                  _resultAnimationController.reset();
                },
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the temperature input text field
  Widget _buildTemperatureInputField() {
    final inputUnit = _selectedConversionType == ConversionType.fahrenheitToCelsius ? '°F' : '°C';

    return TextFormField(
      controller: _temperatureController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d*')),
      ],
      decoration: InputDecoration(
        labelText: 'Enter temperature value',
        hintText: 'e.g., 32.0',
        suffixText: inputUnit,
        prefixIcon: const Icon(Icons.thermostat),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      validator: _validateTemperatureInput,
      onFieldSubmitted: (_) => _performConversion(),
    );
  }

  /// Builds the convert button
  Widget _buildConvertButton() {
    return ElevatedButton.icon(
      onPressed: _performConversion,
      icon: const Icon(Icons.calculate, size: 24),
      label: const Text(
        'Convert',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  /// Builds the result display card
  Widget _buildResultCard() {
    if (_convertedValue == null) {
      return const SizedBox.shrink();
    }

    final inputUnit = _selectedConversionType == ConversionType.fahrenheitToCelsius ? '°F' : '°C';
    final outputUnit = _selectedConversionType == ConversionType.fahrenheitToCelsius ? '°C' : '°F';

    return ScaleTransition(
      scale: _resultScaleAnimation,
      child: Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green.shade600,
              ),
              const SizedBox(height: 12),
              Text(
                'Result',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade700,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.shade200,
                  ),
                ),
                child: Text(
                  '${_convertedValue!.toStringAsFixed(2)}$outputUnit',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the conversion history section
  Widget _buildHistorySection() {
    if (_conversionHistory.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: Theme.of(context).colorScheme.outline,
              ),
              const SizedBox(height: 16),
              Text(
                'No Conversion History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Perform a conversion to see your history here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Conversion History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_conversionHistory.length} conversion${_conversionHistory.length != 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SlideTransition(
          position: _historySlideAnimation,
          child: Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _conversionHistory.length,
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
              itemBuilder: (context, index) {
                final conversion = _conversionHistory[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      conversion.inputUnit,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    conversion.formattedConversion,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${conversion.inputValue.toStringAsFixed(2)}${conversion.inputUnit} = ${conversion.outputValue.toStringAsFixed(2)}${conversion.outputUnit}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: Icon(
                    Icons.arrow_forward,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}