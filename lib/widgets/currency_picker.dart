import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CurrencyPicker extends StatefulWidget {
  const CurrencyPicker({Key? key}) : super(key: key);

  static final CurrencyService _currencyService = CurrencyService();

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
      return CurrencyPicker._currencyService.getAll();
    }

    List<Currency> result = [];
    result.addAll(CurrencyPicker._currencyService.getAll().where(
        (Currency currency) =>
            currency.code.startsWith(search!.toUpperCase())));

    result.addAll(CurrencyPicker._currencyService.getAll().where(
        (Currency currency) =>
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
                          onPressed: () => Navigator.pop(context, currency),
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

class FlexibleBottomSheet extends StatelessWidget {
  const FlexibleBottomSheet(
      {Key? key,
      required this.children,
      this.close = true,
      this.hasBottomPadding = true,
      this.crossAxisAlignment = CrossAxisAlignment.start})
      : super(key: key);

  final List<Widget> children;
  final bool close;
  final bool hasBottomPadding;
  final CrossAxisAlignment crossAxisAlignment;

  static Widget title(String title) {
    return _Title(title: title);
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];

    children.add(ConstrainedBox(
        constraints: const BoxConstraints(
            minWidth: double.infinity, maxHeight: double.infinity),
        child: Container(
          padding: const EdgeInsets.all(12)
              .add(EdgeInsets.only(bottom: hasBottomPadding ? 34 - 12 : -12))
              .add(EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom)),
          child: Column(
              crossAxisAlignment: crossAxisAlignment,
              mainAxisSize: MainAxisSize.min,
              children: this.children),
        )));

    if (close) {
      children.add(
        Positioned(
          right: 12,
          top: 12,
          child: Container(
            height: 24,
            width: 24,
            decoration: const BoxDecoration(
                shape: BoxShape.circle, color: Color(0xFF343434)),
            child: IconButton(
              padding: EdgeInsets.zero,
              splashRadius: 12,
              iconSize: 16,
              color: const Color(0xFF909090),
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
        ),
      );
    }

    return Material(
      color: const Color(0xFF1C1C1C),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Stack(
        children: children,
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.only(top: 3.0, bottom: 20),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
      ),
    );
  }
}
