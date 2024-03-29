import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/calc_symbols.dart';
import '../common/convert_pipe.dart';
import 'calc_stack.dart';
import 'currency_picker_button.dart';
import 'exchange_rate.dart';
import 'exchange_result.dart';
import 'numpad.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool _isShiftPressed = false;

  bool handleKeyboard(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.shiftLeft ||
          event.physicalKey == PhysicalKeyboardKey.shiftRight) {
        _isShiftPressed = true;
      }
    }

    if (event is KeyUpEvent) {
      if (event.physicalKey == PhysicalKeyboardKey.shiftLeft ||
          event.physicalKey == PhysicalKeyboardKey.shiftRight) {
        _isShiftPressed = false;
      }

      if ((event.logicalKey.keyId >= 48 && event.logicalKey.keyId < 57) ||
          event.logicalKey.keyId == 46) {
        ConvertPipe().emit(CalcSymbol(event.logicalKey.keyLabel));
      }

      if (event.physicalKey == PhysicalKeyboardKey.backspace ||
          event.physicalKey == PhysicalKeyboardKey.delete ||
          event.physicalKey == PhysicalKeyboardKey.numpadBackspace) {
        ConvertPipe().emit(CalcSymbolBackspace());
      }

      if (event.physicalKey == PhysicalKeyboardKey.escape) {
        ConvertPipe().emit(CalcSymbolAC());
      }

      if (event.physicalKey == PhysicalKeyboardKey.arrowUp ||
          event.physicalKey == PhysicalKeyboardKey.arrowDown) {
        ConvertPipe().switchConversion();
      }

      if ((event.physicalKey == PhysicalKeyboardKey.equal && _isShiftPressed) ||
          event.physicalKey == PhysicalKeyboardKey.numpadAdd) {
        ConvertPipe().emit(MathSymbolPlus());
      }

      if (event.physicalKey == PhysicalKeyboardKey.minus ||
          event.physicalKey == PhysicalKeyboardKey.numpadSubtract) {
        ConvertPipe().emit(MathSymbolMinus());
      }

      if ((event.physicalKey == PhysicalKeyboardKey.digit8 &&
              _isShiftPressed) ||
          event.physicalKey == PhysicalKeyboardKey.numpadMultiply) {
        ConvertPipe().emit(MathSymbolMul());
      }

      if (event.physicalKey == PhysicalKeyboardKey.slash ||
          event.physicalKey == PhysicalKeyboardKey.numpadDivide) {
        ConvertPipe().emit(MathSymbolDiv());
      }

      if (event.physicalKey == PhysicalKeyboardKey.comma ||
          event.physicalKey == PhysicalKeyboardKey.period ||
          event.physicalKey == PhysicalKeyboardKey.numpadDecimal) {
        ConvertPipe().emit(CalcSymbolDot());
      }
    }

    return false;
  }

  @override
  void initState() {
    super.initState();
    HardwareKeyboard.instance.removeHandler(handleKeyboard);
    HardwareKeyboard.instance.addHandler(handleKeyboard);
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF000000);

    return Theme(
      data: ThemeData.from(
        colorScheme: const ColorScheme.dark(),
      ),
      child: Container(
        color: bgColor,
        child: Column(
          children: [
            Expanded(
                child: SafeArea(
              bottom: false,
              left: false,
              right: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(),
                  child: LayoutBuilder(builder: (context, size) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          CurrencyPickerButton(
                            size: min(size.maxHeight / 15, 16),
                            currency: ConvertPipe().from,
                            suffix: Icon(
                              Icons.arrow_forward_ios,
                              size: min(size.maxHeight / 20, 12),
                            ),
                            onChanged: (currency) =>
                                ConvertPipe().from = currency,
                          )
                        ]),
                        Expanded(
                          child: CalcStack(
                            input: ConvertPipe().input,
                          ),
                        ),
                        ExchangeRate(
                          constraints: size,
                        ),
                        ExchangeResult(
                          constraints: size,
                        ),
                      ],
                    );
                  }),
                ),
              ),
            )),
            Container(
                padding: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 8),
                width: double.infinity,
                decoration: const BoxDecoration(
                    color: Color(0x15FFFFFF),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16))),
                child: const SafeArea(
                    top: false,
                    left: false,
                    right: false,
                    child: Center(child: NumPad()))),
          ],
        ),
      ),
    );
  }
}

class CConverter extends StatelessWidget {
  const CConverter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
