import 'dart:async';
import 'dart:io';

import 'package:cconverter/common/convert_pipe.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../common/calc_symbols.dart';

class CalcStack extends StatefulWidget {
  const CalcStack({Key? key, required this.input}) : super(key: key);

  final Stream<CalcSymbol> input;

  @override
  State<CalcStack> createState() => _CalcStackState();
}

class _CalcStackState extends State<CalcStack> {
  String value = ConvertPipe().format('');
  List<Widget> interactiveExpression = [];

  StreamSubscription? listener;

  @override
  void initState() {
    super.initState();

    if (listener != null) {
      listener!.cancel();
    }

    widget.input.listen((CalcSymbol symbol) {
      if (symbol is CalcSymbolAC) {
        setState(() {
          value = ConvertPipe().format('');
          interactiveExpression.clear();
        });
      } else if (symbol is MathSymbolPlus ||
          symbol is MathSymbolMinus ||
          symbol is MathSymbolMul ||
          symbol is MathSymbolDiv) {
        if (value.isEmpty) {
          return;
        }

        setState(() {
          interactiveExpression
              .add(NumValue(value: ConvertPipe().format(value)));
          interactiveExpression.add(Symbol(value: symbol));
          value = ConvertPipe().format('');
        });
      } else {
        if (symbol is CalcSymbolDot) {
          if (value.contains(CalcSymbolDot().symbol)) {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanEnd: (details) {
        if (value == '0') {
          if (interactiveExpression.isNotEmpty) {
            setState(() {
              interactiveExpression.removeLast();
              value = (interactiveExpression.removeLast() as NumValue).value;
            });
          }

          return;
        }

        if (details.velocity.pixelsPerSecond.dx < 0) {
          setState(() {
            value = ConvertPipe().format(value.substring(0, value.length - 1));
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        width: double.infinity,
        decoration: BoxDecoration(
            color: const Color(0xFF333333),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1A43C))),
        child: LayoutBuilder(
          builder: (context, size) {
            return DefaultTextStyle(
              style: GoogleFonts.poppins(
                  textStyle: TextStyle(fontSize: size.maxHeight / 7)),
              child: Wrap(
                spacing: 4,
                children: interactiveExpression + [NumValue(value: value)],
              ),
            );
          },
        ),
      ),
    );
  }
}

class NumValue extends StatelessWidget {
  const NumValue({Key? key, required this.value}) : super(key: key);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: value == '0' ? const TextStyle(color: Color(0xFFAAAAAA)) : null,
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
