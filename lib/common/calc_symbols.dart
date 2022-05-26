class CalcSymbol {
  CalcSymbol(this.symbol);

  final String symbol;

  @override
  String toString() {
    return symbol;
  }
}

class MathSymbolPlus extends CalcSymbol {
  MathSymbolPlus() : super('+');
}

class MathSymbolMinus extends CalcSymbol {
  MathSymbolMinus() : super('−');
}

class MathSymbolMul extends CalcSymbol {
  MathSymbolMul() : super('×');
}

class MathSymbolDiv extends CalcSymbol {
  MathSymbolDiv() : super('÷');
}