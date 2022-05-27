import 'dart:async';

import '../common/calc_symbols.dart';
import 'package:flutter/material.dart';

class NumPad extends StatelessWidget {
  const NumPad({Key? key, required this.controller}) : super(key: key);

  final StreamController<CalcSymbol> controller;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final double buttonWidth = size.maxWidth / 4.0 - 16;
      final List<Widget> buttons = [];
      final List<CalcSymbol> mathSymbols = [
        MathSymbolDiv(),
        MathSymbolMul(),
        MathSymbolMinus(),
        MathSymbolPlus(),
      ];

      int numValue = 9;
      final TextStyle textStyle = TextStyle(
          fontSize: buttonWidth * 0.5,
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => controller.add(CalcSymbolAC()),
          color: const Color(0xFFFEA00A),
          child: Text(CalcSymbolAC().toString(), style: textStyle),
        ),
      );

      for (int i = 0; i < 3; i++) {
        buttons.add(
          NumPadButton(
            width: buttonWidth,
            onPressed: () {},
            child: Text('', style: textStyle),
          ),
        );
      }


      for (int row = 0; row < 3; row++) {
        for (int col = 2; col >= 0; col--) {
          final CalcSymbol symbol = CalcSymbol((numValue - col).toString());

          buttons.add(
            NumPadButton(
              width: buttonWidth,
              onPressed: () => controller.add(symbol),
              child: Text(symbol.toString(), style: textStyle),
            ),
          );
        }

        numValue -= 3;

        buttons.add(
          NumPadButton(
            width: buttonWidth,
            onPressed: () => controller.add(mathSymbols[row]),
            color: const Color(0xFFFEA00A),
            child: Text(mathSymbols[row].toString(), style: textStyle),
          ),
        );
      }

      final CalcSymbol zero = CalcSymbol('0');
      final CalcSymbol doubleZero = CalcSymbol('00');

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => controller.add(zero),
          child: Text(zero.toString(), style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => controller.add(doubleZero),
          child: Text(doubleZero.toString(), style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => controller.add(CalcSymbolDot()),
          child: Text(CalcSymbolDot().toString(), style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => controller.add(mathSymbols.last),
          color: const Color(0xFFFEA00A),
          child: Text(mathSymbols.last.toString(), style: textStyle),
        ),
      );


      return Material(
        color: Colors.transparent,
        child: Wrap(
          runSpacing: 16,
          children: buttons,
        ),
      );
    });
  }
}

class NumPadButton extends StatelessWidget {
  const NumPadButton({
    Key? key,
    required this.width,
    required this.onPressed,
    required this.child,
    this.color = const Color(0xFF333333),
  }) : super(key: key);

  final double width;
  final Color color;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const CircleBorder(),
      height: width,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      color: color,
      elevation: 2,
      highlightElevation: 0,
      onPressed: onPressed,
      child: child,
    );
  }
}
