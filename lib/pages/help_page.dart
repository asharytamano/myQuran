import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003231),
      appBar: AppBar(
        title: Text(
          "Help & How to Use",
          style: GoogleFonts.merriweather(color: Colors.black),
        ),
        backgroundColor: Colors.amber[700],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "📖 How to Use the App",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 General Navigation
            Text(
              "• Navigate to **Surah List** to browse all 114 chapters of the Qur’an.\n"
                  "• Tap on a Surah to open and read ayahs with Maranao as the default translation.\n"
                  "• Use the top **Pagination** controls to move between pages of long Surahs (like Al-Baqarah).\n"
                  "• If the Surah has fewer than 50 ayahs, the pagination control is hidden automatically.",
              style: GoogleFonts.merriweather(
                fontSize: 14,
                height: 1.6,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Translations
            Text(
              "🌐 Translations",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "• Tap an ayah to expand translations in **Maranao, Tagalog, Bisayan, or English**.\n"
                  "• Use the **Language dropdown** above the Surah to switch your preferred translation.\n"
                  "• Copy 📋 or Share 📤 ayahs with their translation directly to social media or messaging apps.",
              style: GoogleFonts.merriweather(
                fontSize: 14,
                height: 1.6,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Audio
            Text(
              "🎧 Audio Recitation",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "• Choose a reciter from the **Reciter dropdown**.\n"
                  "• Tap ▶️ to play ayahs sequentially with auto-scroll.\n"
                  "• Tap ⏸ to pause or ⏹ to stop playback.\n"
                  "• Use 🔁 to toggle repeat (single ayah, whole surah, or none).\n"
                  "• At the **End of Surah**, you will hear a chime 🔔 and see an alert snackbar.",
              style: GoogleFonts.merriweather(
                fontSize: 14,
                height: 1.6,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Favorites
            Text(
              "❤️ Favorites",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "• Tap ❤️ on any ayah to save it to your **Favorites** list.\n"
                  "• Access your saved ayahs from the Drawer → Favorites.\n"
                  "• You can Copy, Share, or Remove items directly from Favorites.",
              style: GoogleFonts.merriweather(
                fontSize: 14,
                height: 1.6,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Surah Overview
            Text(
              "ℹ️ Surah Overview",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "• Each Surah begins with an **Overview box** showing its name, type (Makki/Madani), ayah count, and a brief description.\n"
                  "• This info helps you understand the context before reading.\n"
                  "• When playback starts, the overview gracefully fades out for better scrolling experience.",
              style: GoogleFonts.merriweather(
                fontSize: 14,
                height: 1.6,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Other Pages
            Text(
              "📂 Other Pages",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "• **Reciters Page** → Preview audio samples and learn about different Qur’an reciters.\n"
                  "• **About Page** → Read about the project, translators, and developer background.\n"
                  "• **Help Page** → This guide you’re reading right now.",
              style: GoogleFonts.merriweather(
                fontSize: 14,
                height: 1.6,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 30),

            Center(
              child: Text(
                "Need more help? Contact support via the About Page.",
                style: GoogleFonts.merriweather(
                  fontSize: 13,
                  color: Colors.amber,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
