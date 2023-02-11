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
        final List<CurrencyRate> rates = ConvertPipe().getExpressionRates();

        final toCurrency = ConvertPipe().to;
        final TextSpan toSymbol = TextSpan(
          text: toCurrency.symbol,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w300,
            color: Colors.white.withOpacity(0.75),
          ),
        );

        InfoMenu.show(
            context,
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Exchange Rates of ${toCurrency.name}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.75)
                  ),
                ),
                const SizedBox(height: 16),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.75,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        final CurrencyRate rate = rates[i];
                        final String value =
                            ConvertPipe().rateFormat.format(rate.value);
                        final int separator = min(
                            value.indexOf(ConvertPipe().decimalSeparator),
                            value.length - 3);

                        return ListTile(
                          title: RichText(
                            text: TextSpan(
                              text: '',
                              children: [
                                if (toCurrency.symbolOnLeft) toSymbol,
                                TextSpan(
                                    text: value.substring(0, separator + 3),
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFFFC571),
                                        fontSize: 18)),
                                TextSpan(
                                  text: value.substring(separator + 3),
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w300,
                                      color: Colors.white.withOpacity(0.33),
                                      fontSize: 14),
                                ),
                                if (!toCurrency.symbolOnLeft) toSymbol,
                              ],
                            ),
                          ),
                          subtitle: Text(
                            '${rate.currency.name} (${rate.currency.code})',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w300,
                            ),
                          ),
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
                      separatorBuilder: (context, i) =>
                          const SizedBox(height: 4),
                      itemCount: rates.length,
                    ),
                  ),
                ),
              ],
            ));
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
