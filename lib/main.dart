import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'common/convert_pipe.dart';
import 'widgets/cconverter.dart';

void main() async {
  ConvertPipe().loadRates();
  ConvertPipe().loadInverseRates();
  runApp(const CConverter());
}
