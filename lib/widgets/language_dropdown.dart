import 'package:flutter/material.dart';

class LanguageDropdown extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String?> onChanged;

  const LanguageDropdown({
    super.key,
    required this.selectedLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedLanguage,
      isExpanded: true,
      items: const [
        DropdownMenuItem(
          value: "maranao",
          child: Text("Maranao – Abu Ahmad Tamano"),
        ),
        DropdownMenuItem(
          value: "tagalog",
          child: Text("Tagalog – Rowwad Translation Center"),
        ),
        DropdownMenuItem(
          value: "bisayan",
          child: Text("Bisayan – Rowwad Translation Center"),
        ),
        DropdownMenuItem(
          value: "english",
          child: Text("English – Rowwad Translation Center"),
        ),
      ],
      onChanged: onChanged,
    );
  }
}
