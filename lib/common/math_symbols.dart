class MathSymbol {
  MathSymbol(this.symbol);

  final String symbol;

  @override
  String toString() {
    return symbol;
  }
}

class MathSymbolPlus extends MathSymbol {
  MathSymbolPlus() : super('+');
}

class MathSymbolMinus extends MathSymbol {
  MathSymbolMinus() : super('−');
}

class MathSymbolMul extends MathSymbol {
  MathSymbolMul() : super('×');
}

class MathSymbolDiv extends MathSymbol {
  MathSymbolDiv() : super('÷');
}