import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/convert_pipe.dart';
import 'calc_stack.dart';
import 'currency_picker_button.dart';

class ExchangeResult extends StatelessWidget {
  const ExchangeResult({
    Key? key,
    required this.constraints,
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
            onChanged: (currency) => ConvertPipe().to = currency,
          ),
        ),
        StreamBuilder<String>(
            stream: ConvertPipe().output,
            builder: (context, snapshot) {
              final String value = ConvertPipe().format(snapshot.data);
              String result = value;
              double fontSize = min(constraints.maxHeight / 6, 42);
              bool minSizeExceeded = false;
              bool stripDecimals = false;

              TextPainter textPainter = TextPainter(
                  text: TextSpan(
                      text: result,
                      style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w600,
                          fontFamily: GoogleFonts.poppins().fontFamily)),
                  textDirection: TextDirection.ltr,
                  maxLines: 1)
                ..layout(minWidth: 0, maxWidth: constraints.maxWidth - 100);

              while (textPainter.didExceedMaxLines) {
                fontSize -= 1;
                textPainter.text = TextSpan(
                    text: result,
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        fontFamily: GoogleFonts.poppins().fontFamily));
                textPainter.layout(
                    minWidth: 0, maxWidth: constraints.maxWidth - 100);

                if (fontSize < 34) {
                  if (result.contains(ConvertPipe().decimalSeparator)) {
                    result = value.substring(
                        0, value.indexOf(ConvertPipe().decimalSeparator));
                    stripDecimals = true;
                  } else {
                    final String trimmed =
                        value.replaceAll(ConvertPipe().groupSeparator, '');

                    if (trimmed.length >= 10) {
                      result = trimmed.substring(0, trimmed.length - 9);
                      result = '${ConvertPipe().format(result)}B';
                    } else if (trimmed.length >= 7) {
                      result = trimmed.substring(0, trimmed.length - 6);
                      result = '${ConvertPipe().format(result)}M';
                    } else if (trimmed.length >= 4) {
                      result = trimmed.substring(0, trimmed.length - 3);
                      result = '${ConvertPipe().format(result)}K';
                    }
                  }

                  if (minSizeExceeded) {
                    break;
                  }

                  fontSize = min(constraints.maxHeight / 6, 42);
                  minSizeExceeded = !stripDecimals;
                }
              }

              return GestureDetector(
                onTap: () => Clipboard.setData(ClipboardData(text: value)),
                child: SizedBox(
                  height: 60,
                  child: NumValue(
                    value: result,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFFC571),

                  ),
                ),
              );
            }),
      ],
    );
  }
}
