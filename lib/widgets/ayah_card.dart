import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class AyahCard extends StatelessWidget {
  final Map<String, dynamic> ayah;
  final int index;
  final int surahNumber;
  final String selectedLanguage;
  final bool isExpanded;
  final bool isThisPlaying;

  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final VoidCallback onPlayPause;
  final VoidCallback onToggleTranslation;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.index,
    required this.surahNumber,
    required this.selectedLanguage,
    required this.isExpanded,
    required this.isThisPlaying,
    required this.onCopy,
    required this.onShare,
    required this.onFavorite,
    required this.onPlayPause,
    required this.onToggleTranslation,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.black87,
      elevation: isThisPlaying ? 10 : 2,
      shadowColor: isThisPlaying ? Colors.orangeAccent : Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: isThisPlaying
            ? const BorderSide(color: Colors.orangeAccent, width: 2)
            : BorderSide.none,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Ayah Number
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "$surahNumber:${ayah['ayah_number']}",
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Arabic text
            Text(
              ayah['text_ar'] ?? "",
              textAlign: TextAlign.right,
              style: GoogleFonts.amiri(
                fontSize: 24,
                color: Colors.white,
                height: 2.0,
              ),
            ),

            // Translation (toggle)
            if (isExpanded) ...[
              const SizedBox(height: 8),
              Text(
                selectedLanguage == "maranao"
                    ? (ayah['text_mn'] ?? "")
                    : selectedLanguage == "tagalog"
                    ? (ayah['translation_tl'] ?? "—")
                    : selectedLanguage == "bisayan"
                    ? (ayah['translation_bis'] ?? "—")
                    : (ayah['translation_en'] ?? "—"),
                textAlign: TextAlign.left,
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  color: Colors.orangeAccent,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 10),

            // Action Row
            Container(
              decoration: BoxDecoration(
                color: isThisPlaying ? Colors.orange.shade700 : Colors.black,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              height: 44,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    iconSize: 20,
                    tooltip: "Copy",
                    icon: const Icon(Icons.copy, color: Colors.blue),
                    onPressed: onCopy,
                  ),
                  IconButton(
                    iconSize: 20,
                    tooltip: "Share",
                    icon: const Icon(Icons.share, color: Colors.green),
                    onPressed: onShare,
                  ),
                  IconButton(
                    iconSize: 20,
                    tooltip: "Add to Favorites",
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: onFavorite,
                  ),
                  IconButton(
                    iconSize: 22,
                    tooltip: isThisPlaying ? "Pause" : "Play",
                    icon: Icon(
                      isThisPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    onPressed: onPlayPause,
                  ),
                  IconButton(
                    iconSize: 22,
                    tooltip: "Toggle Translation",
                    icon: Icon(
                      isExpanded ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: onToggleTranslation,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
