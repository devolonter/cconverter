import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../common/convert_pipe.dart';
import 'calc_stack.dart';
import 'currency_picker_button.dart';

class ExchangeResult extends StatelessWidget {
  const ExchangeResult({
    Key? key, required this.constraints,
  }) : super(key: key);

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: CurrencyPickerButton(
            size: min(constraints.maxHeight / 15, 16),
            currency: ConvertPipe().to,
            prefix: Icon(
              Icons.arrow_forward_ios,
              size: min(constraints.maxHeight / 20, 12),
            ),
            onChanged: (currency) =>
            ConvertPipe().to = currency,
          ),
        ),
        StreamBuilder<String>(
            stream: ConvertPipe().output,
            builder: (context, snapshot) {
              final String value =
              ConvertPipe().format(snapshot.data);

              return GestureDetector(
                onTap: () => Clipboard.setData(
                    ClipboardData(text: value)),
                child: NumValue(
                  value: value,
                  fontSize: min(constraints.maxHeight / 6, 42),
                  color: const Color(0xFFF1A43C),
                ),
              );
            }),
      ],
    );
  }
}