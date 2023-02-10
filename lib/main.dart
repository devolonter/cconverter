import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';

import 'common/settings.dart';
import 'common/convert_pipe.dart';
import 'widgets/cconverter.dart';

class Config {
  static const double width = 375;
  static const double height = 667;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Settings().load();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    final Rect screenFrame = (await getCurrentScreen())!.visibleFrame;

    setWindowFrame(Rect.fromLTWH(
        (screenFrame.width - Config.width) * 0.5,
        (screenFrame.height - Config.height) * 0.5,
        Config.width,
        Config.height));
    setWindowMinSize(const Size(Config.width, Config.height));
    setWindowMaxSize(Size(Config.width, screenFrame.height * 0.5));
    setWindowTitle('CConverter');
  }

  ConvertPipe().loadRates();
  ConvertPipe().loadInverseRates();

  runApp(const CConverter());
}
