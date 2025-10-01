import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TajweedAyahWidget extends StatelessWidget {
  final List<Map<String, dynamic>> spans;
  final double fontSize;

  TajweedAyahWidget({super.key, required this.spans, this.fontSize = 28});

  final Map<String, Color> tajweedColors = {
    "none": Colors.black,
    "ikhfa": Colors.green,
    "qalqalah": Colors.red,
    "idgham": Colors.blue,
    "ghunnah": Colors.orange,
  };

  @override
  Widget build(BuildContext context) {
    List<TextSpan> children = spans.map((seg) {
      final rule = seg['rule'] ?? "none";
      final txt = seg['text'] ?? "";
      return TextSpan(
        text: txt,
        style: GoogleFonts.amiri(
          fontSize: fontSize,
          color: tajweedColors[rule] ?? Colors.black,
          height: 1.6,
        ),
      );
    }).toList();

    return RichText(
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      text: TextSpan(children: children),
    );
  }
}
