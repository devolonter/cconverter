import 'dart:async';
import 'dart:io';

import 'package:eval_ex/expression.dart';
import 'package:intl/intl.dart';

import 'package:currency_picker/currency_picker.dart';
import 'calc_symbols.dart';

class ConvertPipe {
  ConvertPipe._init();
  static final ConvertPipe _instance = ConvertPipe._init();

  Stream<CalcSymbol> get input => _numPadController.stream;
  Stream<String> get output => _evalController.stream;

  Currency get from {
    if (_from != null) {
      return _from!;
    }

    final String? name =
        NumberFormat.simpleCurrency(locale: Platform.localeName).currencyName;
    final Currency? result =
        _currencyService.findByCode(name) ?? _currencyService.findByCode('USD');
    return result!;
  }

  set from(Currency value) {
    _from = value;
  }

  CurrencyService get currencies => _currencyService;

  final StreamController<CalcSymbol> _numPadController =
      StreamController<CalcSymbol>();
  final StreamController<String> _evalController = StreamController<String>();

  Currency? _from;

  final NumberFormat _format = NumberFormat.decimalPattern(Platform.localeName);
  final CurrencyService _currencyService = CurrencyService();

  factory ConvertPipe() {
    return _instance;
  }

  String format(String? value, {bool stripDecimalSeparator = true}) {
    value ??= '';
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

  void emit(CalcSymbol symbol) {
    _numPadController.add(symbol);
  }

  void eval(List<dynamic> expression, String tail) {
    if (tail != '0' && tail != '0.') {
      expression.add(tail);
    } else if (expression.isNotEmpty) {
      expression = expression.sublist(0, expression.length - 1);
    }

    if (expression.isEmpty) {
      _evalController.add('0');
      return;
    }

    final Expression calc = Expression(expression.map((e) {
      if (e is String) {
        return toDouble(e).toString();
      }

      return (e as CalcSymbol).toMath();
    }).join());

    _evalController.add(calc.eval().toString());
  }
}
