import 'dart:io';

import 'package:intl/intl.dart';

class CalcSymbol {
  CalcSymbol(this.symbol);

  final String symbol;

  @override
  String toString() {
    return symbol;
  }

  String toMath() {
    return '';
  }
}

class CalcSymbolDot extends CalcSymbol {
  CalcSymbolDot._init()
      : super(NumberFormat.simpleCurrency(locale: Platform.localeName)
            .symbols
            .DECIMAL_SEP);

  static final CalcSymbolDot _instance = CalcSymbolDot._init();

  factory CalcSymbolDot() {
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
