import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:eval_ex/expression.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:currency_picker/currency_picker.dart';
import 'package:path_provider/path_provider.dart';
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
  Currency? _base;
  double? _rate;
  List<dynamic> _lastExpression = [];
  double? _lastCalc;

  final NumberFormat _fiatFormat =
      NumberFormat('#,##0.##', Platform.localeName.split('_')[1]);
  final NumberFormat _cryptoFormat =
      NumberFormat('#,##0.${'#' * 16}', Platform.localeName.split('_')[1]);
  final NumberFormat _rateFormat =
    NumberFormat('#,##0.${'#' * 6}', Platform.localeName.split('_')[1]);
  final CurrencyService _currencyService = CurrencyService();

  Stream<CalcSymbol> get input => _numPadController.stream;
  Stream<String> get output => _evalController.stream;
  Stream<List<Currency>> get direction => _dirController.stream;
  String? get rate => (_rate != null) ? _rateFormat.format(_rate) : null;
  Currency? get userCurrency =>
      _currencyService.findByCode(_fiatFormat.currencySymbol);
  String get decimalSeparator => _fiatFormat.symbols.DECIMAL_SEP;
  String get groupSeparator => _fiatFormat.symbols.GROUP_SEP;

  Currency get from {
    if (_from != null) {
      return _from!;
    }

    final String? name = _fiatFormat.currencyName;
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

  String format(String? value,
      {bool stripDecimalSeparator = true, bool highPrecision = false}) {
    value ??= '';

    if (value == '00' || value == '000') {
      value = '0.';
    }

    double doubleValue = toDouble(value, highPrecision: highPrecision);
    NumberFormat format = highPrecision ? _cryptoFormat : _fiatFormat;
    String formattedValue = format.format(doubleValue);

    if (value.length >= 3 &&
        value.endsWith('0') &&
        value.substring(value.length - 3, value.length - 1) ==
            '0${format.symbols.DECIMAL_SEP}') {
      formattedValue = '$formattedValue${format.symbols.DECIMAL_SEP}0';
    }

    String dot = CalcSymbolDot().toString();

    if (!stripDecimalSeparator) {
      if (value.contains(dot) && !formattedValue.contains(dot)) {
        formattedValue += dot;
      }

      if (value.endsWith('0') && !formattedValue.endsWith('0')) {
        formattedValue += '0';
      }

      if (format == _cryptoFormat &&
          formattedValue.endsWith('0') &&
          value.contains(dot)) {
        formattedValue =
            formattedValue + '0' * (value.length - formattedValue.length);
      }
    }

    return formattedValue;
  }

  double toDouble(String value, {bool highPrecision = false}) {
    final int decimalRange = highPrecision ? 16 : 2;

    return double.tryParse((double.tryParse(value
                    .replaceAll(_fiatFormat.symbols.GROUP_SEP, '')
                    .replaceAll(_fiatFormat.symbols.DECIMAL_SEP, '.')) ??
                0)
            .toStringAsFixed(decimalRange)) ??
        0;
  }

  void emit(CalcSymbol symbol) {
    _numPadController.add(symbol);
  }

  void eval(List<dynamic> expression, [dynamic tail]) {
    //to avoid side effects
    expression = expression.toList();

    if (tail != null) {
      if (tail != '0' && tail != '0${_fiatFormat.symbols.DECIMAL_SEP}') {
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
    if (base == _base) {
      if (inverse && _inverseRatesData != null) {
        return _inverseRatesData;
      }

      if (!inverse && _ratesData != null) {
        return _ratesData;
      }
    }

    final String date =
        DateTime.now().toUtc().toIso8601String().substring(0, 10);
    Directory dir =
        Directory('${(await getTemporaryDirectory()).path}/rates/${base.code}');

    File file = File('${dir.path}/$date.json');
    String? result;

    if (await file.exists()) {
      result = await file.readAsString();
    } else {
      final String symbols = currencies
          .getAll()
          .map((Currency currency) => currency.code)
          .join(',');
      final http.Response response = await http.get(Uri.parse(
          'https://api.exchangerate.host/latest?symbols=$symbols&base=${base.code}'));

      if (response.statusCode == 200) {
        result = response.body;
        await file.create(recursive: true);
        file.writeAsString(result);
      } else {
        final List<FileSystemEntity> files = dir.listSync().toList();

        if (files.isNotEmpty) {
          files.sort((FileSystemEntity a, FileSystemEntity b) {
            return b.statSync().modified.compareTo(a.statSync().modified);
          });

          result = await File(files.first.path).readAsString();
        }
      }
    }

    if (result != null) {
      _base = base;
      return RatesData.fromJson(result, inverse: inverse);
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
