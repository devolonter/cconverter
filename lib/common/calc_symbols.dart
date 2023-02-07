import 'dart:io';

import 'package:cconverter/common/convert_pipe.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:intl/intl.dart';

class CalcSymbol {
  CalcSymbol(this.symbol);

  final dynamic symbol;

  @override
  String toString() {
    return (symbol is Currency) ? symbol.code : symbol as String;
  }

  String toMath() {
    return '';
  }
}

class CalcSymbolCurrency extends CalcSymbol {
  CalcSymbolCurrency(dynamic symbol) : super(symbol);
}

class CalcSymbolDot extends CalcSymbol {
  CalcSymbolDot._init()
      : super(ConvertPipe().decimalSeparator);

  static final CalcSymbolDot _instance = CalcSymbolDot._init();

  factory CalcSymbolDot() {
    return _instance;
  }
}

class CalcSymbolBackspace extends CalcSymbol {
  CalcSymbolBackspace._init() : super('');

  static final CalcSymbolBackspace _instance = CalcSymbolBackspace._init();

  factory CalcSymbolBackspace() {
    return _instance;
  }
}

class CalcSymbolAC extends CalcSymbol {
  CalcSymbolAC._init() : super('AC');
  static final CalcSymbolAC _instance = CalcSymbolAC._init();

  factory CalcSymbolAC() {
    return _instance;
  }
}

class MathSymbolPlus extends CalcSymbol {
  MathSymbolPlus._init() : super('+');
  static final MathSymbolPlus _instance = MathSymbolPlus._init();

  factory MathSymbolPlus() {
    return _instance;
  }

  @override
  String toMath() {
    return '+';
  }
}

class MathSymbolMinus extends CalcSymbol {
  MathSymbolMinus._init() : super('−');
  static final MathSymbolMinus _instance = MathSymbolMinus._init();

  factory MathSymbolMinus() {
    return _instance;
  }

  @override
  String toMath() {
    return '-';
  }
}

class MathSymbolMul extends CalcSymbol {
  MathSymbolMul._init() : super('×');
  static final MathSymbolMul _instance = MathSymbolMul._init();

  factory MathSymbolMul() {
    return _instance;
  }

  @override
  String toMath() {
    return '*';
  }
}

class MathSymbolDiv extends CalcSymbol {
  MathSymbolDiv._init() : super('÷');
  static final MathSymbolDiv _instance = MathSymbolDiv._init();

  factory MathSymbolDiv() {
    return _instance;
  }

  @override
  String toMath() {
    return '/';
  }
}
