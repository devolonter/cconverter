import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/convert_pipe.dart';
import 'currency_picker.dart';

class CurrencyPickerButton extends StatefulWidget {
  const CurrencyPickerButton({
    Key? key,
    required this.currency,
    required this.size,
    required this.onChanged,
    this.prefix,
    this.suffix,
  }) : super(key: key);

  final Currency currency;
  final double size;
  final Widget? prefix;
  final Widget? suffix;
  final Function(Currency) onChanged;

  @override
  State<CurrencyPickerButton> createState() => _CurrencyPickerButtonState();
}

class _CurrencyPickerButtonState extends State<CurrencyPickerButton> {
  Currency? currency;
  StreamSubscription? listener;

  @override
  void initState() {
    super.initState();
    currency = widget.currency;

    if (listener != null) {
      return;
    }

    final int index = currency == ConvertPipe().from ? 0 : 1;
    listener = ConvertPipe().direction.listen((dir) {
      setState(() {
        currency = dir[index];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> view = [];

    if (widget.prefix != null) {
      view.add(widget.prefix!);
    }

    view.add(Text(
      currency!.code,
      style: GoogleFonts.poppins(fontSize: min(widget.size, 18)),
    ));

    if (widget.suffix != null) {
      view.add(widget.suffix!);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: (Platform.isWindows || Platform.isLinux || Platform.isMacOS)
              ? 8
              : 0),
      child: TextButton(
          style: TextButton.styleFrom(
              backgroundColor: const Color(0x18FFFFFF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.size)),
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              foregroundColor: Colors.white),
          onPressed: () {
            CurrencyPicker.show(context).then((value) {
              if (value == null) {
                return;
              }

              widget.onChanged(value);
              setState(() {
                currency = value;
              });
            });
          },
          child: Wrap(
            spacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: view,
          )),
    );
  }
}