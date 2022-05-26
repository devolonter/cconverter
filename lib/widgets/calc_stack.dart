import 'package:flutter/material.dart';

class CalcStack extends StatelessWidget {
  const CalcStack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF333333),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1A43C))
      ),
    );
  }
}
