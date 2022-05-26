import '../common/calc_symbols.dart';
import 'package:flutter/material.dart';

class NumPad extends StatelessWidget {
  const NumPad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (builder, size) {
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

      for (int row = 0; row < 3; row++) {
        for (int col = 0; col < 3; col++) {
          buttons.add(
            NumPadButton(
              width: buttonWidth,
              onPressed: () {},
              child: Text((numValue).toString(), style: textStyle),
            ),
          );

          numValue--;
        }

        buttons.add(
          NumPadButton(
            width: buttonWidth,
            onPressed: () {},
            color: const Color(0xFFFEA00A),
            child: Text(mathSymbols[row].toString(), style: textStyle),
          ),
        );
      }

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () {},
          child: Text('0', style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () {},
          child: Text('00', style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () {},
          child: Text(',', style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () {},
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
