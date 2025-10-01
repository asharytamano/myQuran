import 'package:flutter/material.dart';

class ReciterDropdown extends StatelessWidget {
  final String selectedReciter;
  final ValueChanged<String?> onChanged;
  final VoidCallback onPlayAll;
  final VoidCallback onStop;

  const ReciterDropdown({
    super.key,
    required this.selectedReciter,
    required this.onChanged,
    required this.onPlayAll,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButton<String>(
            value: selectedReciter,
            isExpanded: true,
            items: const [
              DropdownMenuItem(value: "sudais", child: Text("Abdurrahman As-Sudais")),
              DropdownMenuItem(value: "afasy", child: Text("Mishary Rashid Alafasy")),
              DropdownMenuItem(value: "ghamdi", child: Text("Saad Al-Ghamdi")),
              DropdownMenuItem(value: "rifai", child: Text("Hani Ar-Rifai")),
              DropdownMenuItem(value: "abdulbasit", child: Text("Abdulbasit Abdussamad")),
              DropdownMenuItem(value: "menshawi", child: Text("Menshawi")),
              DropdownMenuItem(value: "fares", child: Text("Fares Abbad")),
              DropdownMenuItem(value: "matroud", child: Text("Abdullah Matroud")),
            ],
            onChanged: onChanged,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow),
          tooltip: "Play All",
          onPressed: onPlayAll,
        ),
        IconButton(
          icon: const Icon(Icons.stop),
          tooltip: "Stop",
          onPressed: onStop,
        ),
      ],
    );
  }
}
