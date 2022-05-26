import 'dart:async';

import 'calc_symbols.dart';

class ConvertPipe {
  ConvertPipe._init();
  static final ConvertPipe _instance = ConvertPipe._init();

  final StreamController<CalcSymbol> numPadController = StreamController<CalcSymbol>();
  Stream<CalcSymbol> get input => numPadController.stream;

  factory ConvertPipe() {
    return _instance;
  }
}