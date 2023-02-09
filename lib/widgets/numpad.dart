import 'dart:math';

import 'package:currency_picker/currency_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/calc_symbols.dart';
import 'package:flutter/material.dart';

import '../common/convert_pipe.dart';
import '../main.dart';
import 'currency_picker.dart';

class NumPad extends StatelessWidget {
  const NumPad({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      final double containerWidth = min(size.maxWidth, Config.width * 1.25);
      final double buttonWidth = containerWidth / 4.0 - 16;
      final List<Widget> buttons = [];
      final List<CalcSymbol> mathSymbols = [
        MathSymbolDiv(),
        MathSymbolMul(),
        MathSymbolMinus(),
        MathSymbolPlus(),
      ];

      int numValue = 9;
      final TextStyle textStyle = GoogleFonts.poppins(
          textStyle: TextStyle(
        fontSize: buttonWidth * 0.5,
      ));

      const Color orange = Color(0xFFEC5F38);

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => ConvertPipe().emit(CalcSymbolAC()),
          color: orange,
          child: Text(CalcSymbolAC().toString(), style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => ConvertPipe().emit(CalcSymbolBackspace()),
          color: orange,
          child: Icon(
            Icons.arrow_back_ios,
            size: buttonWidth * 0.45,
          ),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => ConvertPipe().switchConversion(),
          child: FaIcon(
            FontAwesomeIcons.arrowRightArrowLeft,
            size: buttonWidth * 0.5,
            color: Colors.white.withOpacity(0.66),
          ),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () async {
            Currency? currency = await CurrencyPicker.show(context);

            if (currency != null) {
              ConvertPipe().emit(CalcSymbolCurrency(currency));
            }
          },
          child: FaIcon(
            FontAwesomeIcons.dollarSign,
            size: buttonWidth * 0.5,
            color: Colors.white.withOpacity(0.66),
          ),
        ),
      );

      for (int row = 0; row < 3; row++) {
        for (int col = 2; col >= 0; col--) {
          final CalcSymbol symbol = CalcSymbol((numValue - col).toString());

          buttons.add(
            NumPadButton(
              width: buttonWidth,
              onPressed: () => ConvertPipe().emit(symbol),
              child: Text(symbol.toString(), style: textStyle),
            ),
          );
        }

        numValue -= 3;

        buttons.add(
          NumPadButton(
            width: buttonWidth,
            onPressed: () => ConvertPipe().emit(mathSymbols[row]),
            color: orange,
            child: Text(mathSymbols[row].toString(), style: textStyle),
          ),
        );
      }

      final CalcSymbol zero = CalcSymbol('0');
      final CalcSymbol doubleZero = CalcSymbol('00');

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => ConvertPipe().emit(zero),
          child: Text(zero.toString(), style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => ConvertPipe().emit(doubleZero),
          child: Text(doubleZero.toString(), style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => ConvertPipe().emit(CalcSymbolDot()),
          child: Text(CalcSymbolDot().toString(), style: textStyle),
        ),
      );

      buttons.add(
        NumPadButton(
          width: buttonWidth,
          onPressed: () => ConvertPipe().emit(mathSymbols.last),
          color: orange,
          child: Text(mathSymbols.last.toString(), style: textStyle),
        ),
      );

      return SizedBox(
        width: containerWidth,
        child: Center(
          child: Wrap(
              runSpacing: 16,
              children: buttons,
            ),
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
    this.color = const Color(0x15FFFFFF),
  }) : super(key: key);

  final double width;
  final Color color;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width + 16,
      child: MaterialButton(
        shape: const CircleBorder(),
        height: width,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        color: color,
        elevation: 0,
        highlightElevation: 0,
        onPressed: onPressed,
        child: child,
      ),
    );
  }
}
