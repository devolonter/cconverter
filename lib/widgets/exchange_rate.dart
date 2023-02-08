import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/convert_pipe.dart';

class ExchangeRate extends StatelessWidget {
  const ExchangeRate({
    Key? key,
    required this.constraints,
  }) : super(key: key);

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.all(8.0).subtract(const EdgeInsets.only(bottom: 8)),
      child: ChangeNotifierProvider(
        create: (_) => ConvertPipe(),
        child: Consumer<ConvertPipe>(builder: (context, pipe, child) {
          return Text(
            pipe.rate != null
                ? '1 ${pipe.from.code} = ${pipe.rate} ${pipe.to.code}'
                : 'Exchange rates loading...',
            style: TextStyle(
                color: const Color(0xFFA5A5A5),
                fontSize: min(constraints.maxHeight / 18, 16)),
          );
        }),
      ),
    );
  }
}