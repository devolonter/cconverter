import 'dart:async';

import 'package:cconverter/common/settings.dart';
import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../common/convert_pipe.dart';
import 'currency_button.dart';

class CurrencyPicker extends StatefulWidget {
  const CurrencyPicker({Key? key}) : super(key: key);

  static Future<Currency?> show(BuildContext context) {
    return showModalBottomSheet<Currency?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: const Color(0xFF191919),
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
                  color: const Color(0x09FFFFFF),
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
                final double buttonWidth = size.maxWidth / 5;

                for (Currency currency in this.currencies) {
                  if (currency.flag == null) {
                    continue;
                  }

                  currencies.add(
                    CurrencyButton(
                      currency: currency,
                      width: buttonWidth,
                    ),
                  );
                }

                return SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: size.maxWidth,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (Settings().recentlyUsed.isNotEmpty)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(left: 16),
                              child: Text(
                                'Recently Used',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey),
                              ),
                            ),
                            Wrap(
                              children: Settings()
                                  .recentlyUsed
                                  .map((e) => CurrencyButton(
                                        currency: e,
                                        width: buttonWidth,
                                      ))
                                  .toList(),
                            ),
                            const Divider()
                          ],
                        ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: 16,
                            top: Settings().recentlyUsed.isNotEmpty ? 8 : 0),
                        child: const Text(
                          'All Currencies',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey),
                        ),
                      ),
                      Wrap(
                        children: currencies,
                      ),
                    ],
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
