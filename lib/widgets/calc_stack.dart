import 'dart:async';
import 'dart:io';

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
  String value = '';
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
          value = '';
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
          interactiveExpression.add(NumValue(value: value));
          interactiveExpression.add(Symbol(value: symbol));
          value = '';
        });
      } else {
        if (symbol is CalcSymbolDot) {
          if (value.contains(CalcSymbolDot().symbol)) {
            return;
          }
        }

        setState(() {
          value += symbol.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                textStyle: TextStyle(
                    fontSize: size.maxHeight / 7)),
            child: Wrap(
              spacing: 4,
              children: interactiveExpression + [NumValue(value: value)],
            ),
          );
        },
      ),
    );
  }
}

class NumValue extends StatelessWidget {
  NumValue({Key? key, required this.value}) : super(key: key);

  final String value;
  final NumberFormat format = NumberFormat.decimalPattern(Platform.localeName);

  @override
  Widget build(BuildContext context) {
    String formattedValue =
        format.format(value.isNotEmpty ? double.parse(value) : 0);
    String dot = CalcSymbolDot().symbol;

    if (value.contains(dot) && !formattedValue.contains(dot)) {
      formattedValue += dot;
    }

    return Text(
      formattedValue,
      style: formattedValue == '0'
          ? const TextStyle(color: Color(0xFFAAAAAA))
          : null,
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
