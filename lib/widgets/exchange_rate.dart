import 'dart:math';

import 'package:currency_picker/currency_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../common/convert_pipe.dart';
import '../common/info_menu.dart';

class ExchangeRate extends StatelessWidget {
  const ExchangeRate({
    Key? key,
    required this.constraints,
  }) : super(key: key);

  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (ConvertPipe().rate == null) return;
        final List<CurrencyRate> rates = ConvertPipe().getRates();

        InfoMenu.show(
            context,
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                '1 ${ConvertPipe().from.code}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Color(0xFFFFC571),
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, i) {
                      final CurrencyRate rate = rates[i];
                      return ListTile(
                        title: Text(ConvertPipe().rateFormat.format(rate.value),
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            '${rate.currency.name} (${rate.currency.code})'),
                        leading: Text(
                          CurrencyUtils.currencyToEmoji(rate.currency),
                          style: const TextStyle(fontSize: 32),
                        ),
                        tileColor: i % 2 == 0
                            ? Colors.white.withOpacity(0.025)
                            : Colors.white.withOpacity(0.033),
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      );
                    },
                    separatorBuilder: (context, i) => const SizedBox(height: 4),
                    itemCount: rates.length,
                  ),
                ),
              )
            ]));
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0)
            .subtract(const EdgeInsets.only(bottom: 8)),
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
      ),
    );
  }
}
