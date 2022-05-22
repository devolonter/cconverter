import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'numpad.dart';

class MainPage extends StatelessWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF2B2B2B);

    return Theme(
        data: ThemeData.from(
          colorScheme: const ColorScheme.dark(),
        ),
        child: SafeArea(
            child: Container(
          color: bgColor,
          child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [NumPad()],
              )),
        )));
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
