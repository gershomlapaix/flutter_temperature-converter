import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ConversionType { fahrenheitToCelsius, celsiusToFahrenheit }

class ConversionHistory {
  final ConversionType type;
  final double inputValue;
  final double outputValue;

  ConversionHistory({
    required this.type,
    required this.inputValue,
    required this.outputValue,
  });

  String get displayText {
    final input = type == ConversionType.fahrenheitToCelsius ? '°F' : '°C';
    final output = type == ConversionType.fahrenheitToCelsius ? '°C' : '°F';
    return '${inputValue.toStringAsFixed(1)}$input => ${outputValue.toStringAsFixed(1)}$output';
  }
}

class TemperatureConverterScreen extends StatefulWidget {
  const TemperatureConverterScreen({super.key});

  @override
  State<TemperatureConverterScreen> createState() => _TemperatureConverterScreenState();
}

class _TemperatureConverterScreenState extends State<TemperatureConverterScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ConversionType _conversionType = ConversionType.fahrenheitToCelsius;
  double? _result;
  List<ConversionHistory> _history = [];
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  double _fahrenheitToCelsius(double fahrenheit) => (fahrenheit - 32) * 5 / 9;
  double _celsiusToFahrenheit(double celsius) => celsius * 9 / 5 + 32;

  void _performConversion() {
    if (!_formKey.currentState!.validate()) return;

    final input = double.tryParse(_controller.text.trim());
    if (input == null) {
      _showError('Please enter a valid number');
      return;
    }

    final result = _conversionType == ConversionType.fahrenheitToCelsius
        ? _fahrenheitToCelsius(input)
        : _celsiusToFahrenheit(input);

    setState(() {
      _result = result;
      _history.insert(0, ConversionHistory(
        type: _conversionType,
        inputValue: input,
        outputValue: result,
      ));
    });

    _animationController.forward().then((_) => _animationController.reset());
    HapticFeedback.lightImpact();
    _controller.clear();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text('Are you sure you want to clear all conversion history?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _history.clear();
                _result = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  String? _validateInput(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a temperature value';
    }
    if (double.tryParse(value.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Temperature Converter',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              onPressed: _clearHistory,
              icon: const Icon(Icons.clear_all),
              tooltip: 'Clear History',
            ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return orientation == Orientation.portrait
              ? _buildPortraitLayout()
              : _buildLandscapeLayout();
        },
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildConverterCard(),
          const SizedBox(height: 24),
          if (_result != null) _buildResultCard(),
          const SizedBox(height: 24),
          _buildHistorySection(),
        ],
      ),
    );
  }

  Widget _buildLandscapeLayout() {
    return Row(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildConverterCard(),
                if (_result != null) ...[
                  const SizedBox(height: 20),
                  _buildResultCard(),
                ],
              ],
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: _buildHistorySection(),
          ),
        ),
      ],
    );
  }

  Widget _buildConverterCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
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
              _buildConversionSelector(),
              const SizedBox(height: 20),
              _buildInputField(),
              const SizedBox(height: 24),
              _buildConvertButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConversionSelector() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          RadioListTile<ConversionType>(
            title: const Text('Fahrenheit to Celsius (°F → °C)'),
            subtitle: const Text('°C = (°F - 32) × 5/9'),
            value: ConversionType.fahrenheitToCelsius,
            groupValue: _conversionType,
            onChanged: (value) => setState(() {
              _conversionType = value!;
              _result = null;
            }),
          ),
          const Divider(height: 1),
          RadioListTile<ConversionType>(
            title: const Text('Celsius to Fahrenheit (°C → °F)'),
            subtitle: const Text('°F = °C × 9/5 + 32'),
            value: ConversionType.celsiusToFahrenheit,
            groupValue: _conversionType,
            onChanged: (value) => setState(() {
              _conversionType = value!;
              _result = null;
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    final unit = _conversionType == ConversionType.fahrenheitToCelsius ? '°F' : '°C';

    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Enter temperature value',
        hintText: 'e.g., 32.0',
        suffixText: unit,
        prefixIcon: const Icon(Icons.thermostat),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: _validateInput,
      onFieldSubmitted: (_) => _performConversion(),
    );
  }

  Widget _buildConvertButton() {
    return ElevatedButton.icon(
      onPressed: _performConversion,
      icon: const Icon(Icons.calculate),
      label: const Text('Convert', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildResultCard() {
    final unit = _conversionType == ConversionType.fahrenheitToCelsius ? '°C' : '°F';

    return ScaleTransition(
      scale: CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
      child: Card(
        color: Colors.green.shade50,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.check_circle, size: 48, color: Colors.green.shade600),
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
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  '${_result!.toStringAsFixed(2)}$unit',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (_history.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.history, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No Conversion History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 8),
              Text(
                'Perform a conversion to see your history here',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Conversion History',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              '${_history.length} conversion${_history.length != 1 ? 's' : ''}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _history.length > 10 ? 10 : _history.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversion = _history[index];
              final inputUnit = conversion.type == ConversionType.fahrenheitToCelsius ? '°F' : '°C';

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  child: Text(
                    inputUnit,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(
                  conversion.displayText,
                  style: const TextStyle(fontWeight: FontWeight.w600),
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
      ],
    );
  }
}