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

        if (value.contains(CalcSymbolDot().toString())) {
          if (!value.startsWith('0') && value.length == 4) {
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

    ConvertPipe().eval(expression,
        valueCurrency == null ? value : [value, valueCurrency!.code]);
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
            color: const Color(0x15FFFFFF),
            borderRadius: BorderRadius.circular(16)),
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
          interactiveValue = (interactiveExpression.removeLast() as NumValue);
          value = interactiveValue!.value;
          valueCurrency = interactiveValue!.currency;
        });
      } else {
        setState(() {
          valueCurrency = null;
        });
      }

      return;
    }

    setState(() {
      value = ConvertPipe().format(value.substring(0, value.length - 1),
          stripDecimalSeparator: false);
    });
  }
}

class NumValue extends StatefulWidget {
  const NumValue({
    Key? key,
    this.color,
    this.fontSize,
    this.currency,
    this.currencySize,
    this.fontWeight,
    required this.value,
  }) : super(key: key);

  final String value;
  final Color? color;
  final double? fontSize;
  final double? currencySize;
  final Currency? currency;
  final FontWeight? fontWeight;

  @override
  State<NumValue> createState() => _NumValueState();
}

class _NumValueState extends State<NumValue> {
  bool animated = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant NumValue oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      animated = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          animated = true;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle style = widget.value == '0'
        ? TextStyle(
            color: const Color(0xFFAAAAAA),
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight)
        : TextStyle(
            color: widget.color,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight);

    final Widget displayNum = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.value.substring(0, widget.value.length - 1),
          style: style,
        ),
        AnimatedScale(
          scale: animated ? 1 : 1.24,
          duration: Duration(milliseconds: animated ? 250 : 0),
          curve: Curves.easeOutCubic,
          child: Text(
            widget.value.substring(widget.value.length - 1),
            style: style,
          ),
        ),
      ],
    );

    if (widget.currency == null) {
      return displayNum;
    }

    String symbol = widget.currency!.symbol;

    if (symbol == '\$' && widget.currency!.code != 'USD') {
      symbol = widget.currency!.code;
    }

    return Wrap(
      spacing: 2,
      children: [
        Text(
          symbol,
          style: TextStyle(
              color: const Color(0xFFFEA00A),
              fontSize: widget.currencySize != null
                  ? (widget.currencySize! * 0.5).clamp(12, 15)
                  : null),
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
