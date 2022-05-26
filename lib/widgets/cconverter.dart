import 'dart:io';

import 'package:cconverter/common/convert_pipe.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'calc_stack.dart';
import 'numpad.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

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
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: const [
                          Expanded(
                              child: CalcStack()
                          )
                        ],
                      ),
                    )
                ),
                Container(
                    padding: const EdgeInsets.all(16),
                    width: double.infinity,
                    decoration: const BoxDecoration(
                        color: Color(0xFF3A3A3A),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16))),
                    child: Center(child: NumPad(
                      controller: ConvertPipe().numPadController,
                    ))),
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
