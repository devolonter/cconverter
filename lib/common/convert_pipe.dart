import 'dart:async';
import 'dart:io';

import 'package:intl/intl.dart';

import 'calc_symbols.dart';

class ConvertPipe {
  ConvertPipe._init();
  static final ConvertPipe _instance = ConvertPipe._init();

  final StreamController<CalcSymbol> numPadController =
      StreamController<CalcSymbol>();
  Stream<CalcSymbol> get input => numPadController.stream;

  final NumberFormat _format = NumberFormat.decimalPattern(Platform.localeName);

  factory ConvertPipe() {
    return _instance;
  }

  String format(String value, {bool stripDecimalSeparator = true}) {
    String formattedValue = _format.format(toDouble(value));
    String dot = CalcSymbolDot().symbol;

    if (!stripDecimalSeparator) {
      if (value.contains(dot) && !formattedValue.contains(dot)) {
        formattedValue += dot;
      }
    }

    return formattedValue;
  }

  double toDouble(String value) {
    return value.isNotEmpty
        ? double.parse(
        double.parse(value.replaceAll(_format.symbols.GROUP_SEP, ''))
            .toStringAsFixed(2))
        : 0;
  }
}
