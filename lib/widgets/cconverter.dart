import 'dart:io';
import 'dart:ui';

import 'package:cconverter/common/calc_symbols.dart';
import 'package:cconverter/common/convert_pipe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'calc_stack.dart';
import 'numpad.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  bool handleKeyboard(KeyEvent event) {
    if (event is KeyUpEvent) {
      if ((event.logicalKey.keyId >= 48 && event.logicalKey.keyId < 57) ||
          event.logicalKey.keyId == 46) {
        ConvertPipe().emit(CalcSymbol(event.logicalKey.keyLabel));
      } else if (event.physicalKey == PhysicalKeyboardKey.backspace) {
        ConvertPipe().emit(CalcSymbolBackspace());
      } else if (event.physicalKey == PhysicalKeyboardKey.escape) {
        ConvertPipe().emit(CalcSymbolAC());
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
    const Color bgColor = Color(0xFF2B2B2B);

    return Theme(
      data: ThemeData.from(
        colorScheme: const ColorScheme.dark(),
      ),
      child: SafeArea(
        child: Container(
            color: bgColor,
            child: Column(
              children: [
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.all(16.0)
                      .subtract(const EdgeInsets.only(bottom: 8)),
                  child: DefaultTextStyle(
                    style: GoogleFonts.poppins(),
                    child: LayoutBuilder(builder: (context, size) {
                      return Column(
                        children: [
                          Expanded(
                              child: CalcStack(
                            input: ConvertPipe().input,
                          )),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: StreamBuilder<String>(
                                stream: ConvertPipe().output,
                                builder: (context, snapshot) {
                                  return NumValue(
                                    value: ConvertPipe().format(snapshot.data),
                                    fontSize: size.maxHeight / 6,
                                    color: const Color(0xFFF1A43C),
                                  );
                                }),
                          )
                        ],
                      );
                    }),
                  ),
                )),
                Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Color(0xFF3A3A3A),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16))),
                    child: const Center(child: NumPad())),
              ],
            )),
      ),
    );
  }
}

class CConverter extends StatelessWidget {
  const CConverter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return (Platform.isIOS)
        ? const CupertinoApp(
            debugShowCheckedModeBanner: false,
            home: MainPage(),
          )
        : const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: MainPage(),
          );
  }
}
