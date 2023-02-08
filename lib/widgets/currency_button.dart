import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';

class CurrencyButton extends StatelessWidget {
  const CurrencyButton({
    Key? key,
    required this.currency,
    required this.width,
  }) : super(key: key);

  final Currency currency;
  final double width;

  @override
  Widget build(BuildContext context) {
    final TextStyle style = TextStyle(fontSize: width * 0.5);
    final TextStyle labelStyle = TextStyle(fontSize: width * 0.15);

    return IconButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          Future.delayed(const Duration(milliseconds: 250)).then((value) {
            Navigator.pop(context, currency);
          });
        },
        splashRadius: width * 0.5,
        iconSize: width,
        icon: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              CurrencyUtils.currencyToEmoji(currency),
              style: style,
            ),
            Text(
              currency.code,
              style: labelStyle,
            )
          ],
        ));
  }
}