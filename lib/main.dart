import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common/convert_pipe.dart';
import 'widgets/cconverter.dart';

void main() async {
  await ConvertPipe().loadRates();
  runApp(const CConverter());
}
