import 'dart:async';
import 'dart:math';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/calc_symbols.dart';
import '../common/convert_pipe.dart';

class CalcStack extends StatefulWidget {
  const CalcStack({Key? key, required this.input}) : super(key: key);

  final Stream<CalcSymbol> input;

  @override
  State<CalcStack> createState() => _CalcStackState();
}

class _CalcStackState extends State<CalcStack> {
  String value = ConvertPipe().format('');
  Currency? valueCurrency;
  List<Widget> interactiveExpression = [];
  NumValue? interactiveValue;

  StreamSubscription? listener;

  @override
  void initState() {
    super.initState();

    if (listener != null) {
      listener!.cancel();
    }

    listener = widget.input.listen((CalcSymbol symbol) {
      if (symbol is CalcSymbolAC) {
        setState(() {
          value = ConvertPipe().format('');
          valueCurrency = null;
          interactiveExpression.clear();
        });
      } else if (symbol is CalcSymbolBackspace) {
        _doBackspace();
      } else if (symbol is MathSymbolPlus ||
          symbol is MathSymbolMinus ||
          symbol is MathSymbolMul ||
          symbol is MathSymbolDiv) {
        if (value.isEmpty) {
          return;
        }

        setState(() {
          interactiveExpression.add(interactiveValue!);
          interactiveExpression.add(Symbol(value: symbol));
          value = ConvertPipe().format('');
          valueCurrency = null;
        });
      } else if (symbol is CalcSymbolCurrency) {
        setState(() {
          valueCurrency = symbol.symbol as Currency;
        });
      } else {
        if (symbol is CalcSymbolDot) {
          if (value.contains(CalcSymbolDot().toString())) {
            return;
          }
        }

        setState(() {
          value = ConvertPipe()
              .format(value + symbol.toString(), stripDecimalSeparator: false);
        });
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    List<dynamic> expression = [];

    for (Widget element in interactiveExpression) {
      if (element is NumValue) {
        if (element.currency == null) {
          expression.add(element.value);
        } else {
          expression.add([element.value, element.currency!.code]);
        }
      }

      if (element is Symbol) {
        expression.add(element.value);
      }
    }

    ConvertPipe().eval(
        expression,
        valueCurrency == null
            ? value
            : [value, valueCurrency!.code]);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        if (details.velocity.pixelsPerSecond.dx < 0) {
          _doBackspace();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1A43C))),
        child: LayoutBuilder(
          builder: (context, size) {
            interactiveValue = NumValue(
              value: value,
              currency: valueCurrency,
              currencySize: size.maxHeight / 3.5,
            );
            return DefaultTextStyle(
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: max(size.maxHeight / 7, 20))),
              child: Wrap(
                spacing: 4,
                children: interactiveExpression + [interactiveValue!],
              ),
            );
          },
        ),
      ),
    );
  }

  void _doBackspace() {
    if (value == '0') {
      if (interactiveExpression.isNotEmpty) {
        setState(() {
          interactiveExpression.removeLast();
          value = (interactiveExpression.removeLast() as NumValue).value;
        });
      }

      return;
    }

    setState(() {
      value = ConvertPipe().format(value.substring(0, value.length - 1));
    });
  }
}

class NumValue extends StatelessWidget {
  const NumValue({
    Key? key,
    this.color,
    this.fontSize,
    this.currency,
    this.currencySize,
    required this.value,
  }) : super(key: key);

  final String value;
  final Color? color;
  final double? fontSize;
  final double? currencySize;
  final Currency? currency;

  @override
  Widget build(BuildContext context) {
    final Widget displayNum = Text(
      value,
      style: value == '0'
          ? TextStyle(color: const Color(0xFFAAAAAA), fontSize: fontSize)
          : TextStyle(color: color, fontSize: fontSize),
    );

    if (currency == null) {
      return displayNum;
    }

    String symbol = currency!.symbol;

    if (symbol == '\$' && currency!.code != 'USD') {
      symbol = currency!.code;
    }

    return Wrap(
      spacing: 2,
      children: [
        Text(
          symbol,
          style: TextStyle(
              color: const Color(0xFFFEA00A),
              fontSize: currencySize != null ? currencySize! * 0.5 : null),
        ),
        displayNum
      ],
    );
  }
}

class Symbol extends StatelessWidget {
  const Symbol({Key? key, required this.value}) : super(key: key);

  final CalcSymbol value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value.toString(),
      style: const TextStyle(color: Color(0xFFAAAAAA)),
    );
  }
}
