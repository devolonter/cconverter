import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eval_ex/expression.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:currency_picker/currency_picker.dart';
import 'calc_symbols.dart';

class ConvertPipe extends ChangeNotifier {
  ConvertPipe._init();
  static final ConvertPipe _instance = ConvertPipe._init();

  final StreamController<CalcSymbol> _numPadController =
      StreamController<CalcSymbol>();
  final StreamController<String> _evalController = StreamController<String>();
  final StreamController<List<Currency>> _dirController =
      StreamController<List<Currency>>.broadcast();

  Currency? _from;
  Currency? _to;
  RatesData? _ratesData;
  RatesData? _inverseRatesData;
  double? _rate;
  List<dynamic> _lastExpression = [];
  double? _lastCalc;

  final NumberFormat _format = NumberFormat.decimalPattern(Platform.localeName);
  final CurrencyService _currencyService = CurrencyService();

  Stream<CalcSymbol> get input => _numPadController.stream;
  Stream<String> get output => _evalController.stream;
  Stream<List<Currency>> get direction => _dirController.stream;
  String? get rate => (_rate != null) ? _format.format(_rate) : null;
  Currency? get userCurrency =>
      _currencyService.findByCode(_format.currencySymbol);

  Currency get from {
    if (_from != null) {
      return _from!;
    }

    final String? name = _format.currencyName;
    final Currency? result =
        _currencyService.findByCode(name) ?? _currencyService.findByCode('USD');

    _from = result!;
    return result;
  }

  set from(Currency value) {
    _from = value;
    if (_from == _to) {
      to = (_from!.code != 'USD'
          ? _currencyService.findByCode('USD')
          : _currencyService.findByCode('EUR'))!;
      _dirController.add([from, to]);
    }
    loadRates().then((value) => eval(_lastExpression));
  }

  Currency get to {
    if (_to != null) {
      return _to!;
    }

    final Currency? result =
        _currencyService.findByCode(from.code == 'USD' ? 'EUR' : 'USD');
    _to = result!;
    return result;
  }

  set to(Currency value) {
    _to = value;
    if (_from == _to) {
      from = (_to!.code != 'USD'
          ? _currencyService.findByCode('USD')
          : _currencyService.findByCode('EUR'))!;
      _dirController.add([from, to]);
    }

    loadInverseRates().then((value) => eval(_lastExpression));
    _rate = _ratesData?.rates[_to!.code];
    notifyListeners();
  }

  CurrencyService get currencies => _currencyService;

  factory ConvertPipe() {
    return _instance;
  }

  void switchConversion() {
    final Currency from = _from!;
    _from = _to;
    _to = from;

    Future.wait([loadInverseRates(), loadRates()]).then((_) {
      _rate = _ratesData?.rates[_to!.code];
      eval(_lastExpression);
    });

    _dirController.add([_from!, _to!]);
  }

  String format(String? value, {bool stripDecimalSeparator = true}) {
    value ??= '';

    if (value == '00' || value == '000') {
      value = '0.';
    }

    String formattedValue = _format.format(toDouble(value));

    if (value.length >= 3 &&
        value.endsWith('0') &&
        value.substring(value.length - 3, value.length - 1) ==
            '0${_format.symbols.DECIMAL_SEP}') {
      formattedValue = '$formattedValue${_format.symbols.DECIMAL_SEP}0';
    }

    String dot = CalcSymbolDot().toString();

    if (!stripDecimalSeparator) {
      if (value.contains(dot) && !formattedValue.contains(dot)) {
        formattedValue += dot;
      }
    }

    return formattedValue;
  }

  double toDouble(String value) {
    return value.isNotEmpty
        ? double.parse(double.parse(value
                .replaceAll(_format.symbols.GROUP_SEP, '')
                .replaceAll(_format.symbols.DECIMAL_SEP, '.'))
            .toStringAsFixed(2))
        : 0;
  }

  void emit(CalcSymbol symbol) {
    _numPadController.add(symbol);
  }

  void eval(List<dynamic> expression, [dynamic tail]) {
    //to avoid side effects
    expression = expression.toList();

    if (tail != null) {
      if (tail != '0' && tail != '0${_format.symbols.DECIMAL_SEP}') {
        expression.add(tail);
      } else if (expression.isNotEmpty) {
        expression = expression.sublist(0, expression.length - 1);
      }
    }

    _lastExpression = expression;

    if (expression.isEmpty) {
      _evalController.add('0');
      _lastCalc = null;
      return;
    }

    CalcSymbol? prevSymbol;

    final Expression calc = Expression(expression.map((e) {
      if (e is String) {
        if ((prevSymbol != null) &&
            (prevSymbol == MathSymbolMul() || prevSymbol == MathSymbolDiv())) {
          return toDouble(e);
        }

        return (toDouble(e) * (_rate ?? 1));
      } else if (e is List<dynamic>) {
        return (toDouble(e[0]) * _inverseRatesData!.rates[e[1]]!.toDouble());
      }

      prevSymbol = e;
      return prevSymbol!.toMath();
    }).join());

    _lastCalc = calc.eval()?.toDouble();
    _evalController.add(((_lastCalc ?? 0)).toString());
  }

  Future<void> loadRates() async {
    _ratesData = null;
    _rate = null;
    notifyListeners();

    _ratesData = await _loadRates(from);
    if (_ratesData != null && _ratesData!.rates.containsKey(to.code)) {
      _rate = _ratesData?.rates[to.code];
      notifyListeners();
    }
  }

  Future<void> loadInverseRates() async {
    _inverseRatesData = await _loadRates(to, inverse: true);
  }

  Future<RatesData?> _loadRates(Currency base, {bool inverse = false}) async {
    final String symbols =
        currencies.getAll().map((Currency currency) => currency.code).join(',');
    final http.Response response = await http.get(Uri.parse(
        'https://api.exchangerate.host/latest?symbols=$symbols&base=${base.code}'));

    if (response.statusCode == 200) {
      return RatesData.fromJson(response.body, inverse: inverse);
    }

    return null;
  }
}

class RatesData {
  RatesData(this.rates);

  final Map<String, double> rates;

  static RatesData? fromJson(String json, {bool inverse = false}) {
    final Map<String, dynamic> result = jsonDecode(json);

    if (!(result['success'] as bool)) {
      return null;
    }

    return RatesData(
        (result['rates'] as Map<String, dynamic>).map((key, value) {
      final double result = value.runtimeType == int
          ? (value as int).toDouble()
          : value as double;
      return MapEntry(key, inverse ? 1.0 / result : result);
    }));
  }
}
