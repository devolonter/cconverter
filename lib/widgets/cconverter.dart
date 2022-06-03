import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../common/calc_symbols.dart';
import '../common/convert_pipe.dart';
import 'calc_stack.dart';
import 'currency_picker.dart';
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: DefaultTextStyle(
                    style: GoogleFonts.poppins(),
                    child: LayoutBuilder(builder: (context, size) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            CurrencyPickerButton(
                              size: size.maxHeight / 15,
                              currency: ConvertPipe().from,
                              suffix: Icon(
                                Icons.arrow_forward_ios,
                                size: size.maxHeight / 20,
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
                          Padding(
                            padding: const EdgeInsets.all(8.0)
                                .subtract(const EdgeInsets.only(bottom: 8)),
                            child: ChangeNotifierProvider(
                              create: (_) => ConvertPipe(),
                              child: Consumer<ConvertPipe>(
                                  builder: (context, pipe, child) {
                                return Text(
                                  pipe.rate != null
                                      ? '1 ${pipe.from.code} = ${pipe.rate} ${pipe.to.code}'
                                      : 'Exchange rates loading...',
                                  style: TextStyle(
                                      color: const Color(0xFFA5A5A5),
                                      fontSize: size.maxHeight / 18),
                                );
                              }),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 4,
                              children: [
                                CurrencyPickerButton(
                                  size: size.maxHeight / 15,
                                  currency: ConvertPipe().to,
                                  prefix: Icon(
                                    Icons.arrow_forward_ios,
                                    size: size.maxHeight / 20,
                                  ),
                                  onChanged: (currency) =>
                                      ConvertPipe().to = currency,
                                ),
                                StreamBuilder<String>(
                                    stream: ConvertPipe().output,
                                    builder: (context, snapshot) {
                                      return NumValue(
                                        value:
                                            ConvertPipe().format(snapshot.data),
                                        fontSize: size.maxHeight / 6,
                                        color: const Color(0xFFF1A43C),
                                      );
                                    }),
                              ],
                            ),
                          ),
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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainPage(),
    );
  }
}
