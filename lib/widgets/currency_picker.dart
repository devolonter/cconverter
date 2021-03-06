import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/convert_pipe.dart';

class CurrencyPicker extends StatefulWidget {
  const CurrencyPicker({Key? key}) : super(key: key);

  static Future<Currency?> show(BuildContext context) {
    return showModalBottomSheet<Currency?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF2B2B2B),
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (context) {
          return const CurrencyPicker();
        });
  }

  @override
  State<CurrencyPicker> createState() => _CurrencyPickerState();
}

class _CurrencyPickerState extends State<CurrencyPicker> {
  String? search;
  final TextEditingController _searchController = TextEditingController();

  List<Currency> get currencies {
    if (search == null || search!.isEmpty) {
      final List<Currency> result = ConvertPipe().currencies.getAll();
      final Currency? userCurrency = ConvertPipe().userCurrency;

      if (userCurrency != null) {
        //move user currency to front
        result.remove(userCurrency);
        result.insert(0, userCurrency);
      }

      return result;
    }

    List<Currency> result = [];
    result.addAll(ConvertPipe().currencies.getAll().where((Currency currency) =>
        currency.code.startsWith(search!.toUpperCase())));

    result.addAll(ConvertPipe().currencies.getAll().where((Currency currency) =>
        currency.name.toLowerCase().contains(search!.toLowerCase())));

    return result.toSet().toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: GoogleFonts.poppins(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0x44444444),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        cursorColor: Colors.white,
                        decoration: const InputDecoration(
                            hintText: 'Search currency',
                            border: InputBorder.none),
                        style: GoogleFonts.poppins(
                            textStyle: const TextStyle(fontSize: 16)),
                        onChanged: (value) {
                          setState(() {
                            search = value;
                          });
                        },
                      ),
                    ),
                    Visibility(
                      visible: search != null && search!.isNotEmpty,
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            iconSize: 16,
                            splashRadius: 16,
                            onPressed: () {
                              setState(() {
                                search = null;
                                _searchController.clear();
                              });
                            },
                            icon: const Icon(
                              Icons.close,
                              size: 16,
                            )),
                      ),
                    )
                  ],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, size) {
                final List<Widget> currencies = [];

                final double buttonWidth = size.maxWidth / 5.0;
                final TextStyle style = TextStyle(fontSize: buttonWidth * 0.5);
                final TextStyle labelStyle =
                    TextStyle(fontSize: buttonWidth * 0.15);

                for (Currency currency in this.currencies) {
                  if (currency.flag != null) {
                    currencies.add(
                      IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            Future.delayed(const Duration(milliseconds: 250))
                                .then((value) {
                              Navigator.pop(context, currency);
                            });
                          },
                          splashRadius: buttonWidth * 0.5,
                          iconSize: buttonWidth,
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
                          )),
                    );
                  }
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: size.maxWidth,
                  child: SingleChildScrollView(
                    child: Wrap(
                      children: currencies,
                    ),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

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
              backgroundColor: const Color(0x11FFFFFF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(widget.size)),
              minimumSize: Size.zero,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              primary: const Color(0xFFAEAEAE)),
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
