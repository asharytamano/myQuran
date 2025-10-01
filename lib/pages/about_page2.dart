import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import 'package:google_fonts/google_fonts.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;

    return Scaffold(
      backgroundColor: const Color(0xFF003231),
      appBar: AppBar(
        title: Text(
          "About This App",
          style: GoogleFonts.merriweather(color: Colors.black),
        ),
        backgroundColor: Colors.amber[700],
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Basmala
            Center(
              child: Text(
                "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                style: GoogleFonts.amiri(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  height: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 App Name & Version
            Text(
              AppConstants.appName,
              style: GoogleFonts.merriweather(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Version: ${AppConstants.appVersion}",
              style: GoogleFonts.merriweather(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Tagline
            Text(
              AppConstants.splashTagline,
              style: GoogleFonts.merriweather(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.amber,
              ),
            ),
            const Divider(height: 30, color: Colors.white24),

            // 🔹 Qur’an 16:89
            Center(
              child: Text(
                "وَنَزَّلْنَا عَلَيْكَ الْكِتَابَ تِبْيَانًا لِكُلِّ شَيْءٍ وَهُدًى وَرَحْمَةً وَبُشْرَىٰ لِلْمُسْلِمِينَ",
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "“And We have sent down to you the Book as clarification for all things, as guidance, mercy, and glad tidings for the Muslims.” (Qur’an 16:89)",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Hadith Khayrukum
            Center(
              child: Text(
                "خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ",
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  height: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                "“The best of you are those who learn the Qur’an and teach it.” (Sahih al-Bukhari 5027, Sahih Muslim 804)",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ),
            const Divider(height: 30, color: Colors.white24),

            // 🔹 Translation Credits
            Text(
              "Translation Credits:",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text("Maranao: ${AppConstants.maranaoTranslator}",
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white70)),
            Text("Tagalog: ${AppConstants.tagalogTranslator}",
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white70)),
            Text("Bisayan: ${AppConstants.bisayanTranslator}",
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white70)),
            Text("English: ${AppConstants.englishTranslator}",
                style: GoogleFonts.merriweather(fontSize: 15, color: Colors.white70)),
            const SizedBox(height: 20),

            // 🔹 About the Developer
            Text(
              "About the Developer:",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage("assets/images/developer.jpg"),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "This app was developed by Ashary Tamano, "
                        "a retired IT Specialist, CESO IV and former Planning Director. He served in the Philippine government "
                        "from 1978 to 2000 and worked in Jeddah from 2000 to 2016 as a computer programmer "
                        "and IT specialist. He has dedicated his skills to making the Qur’an more accessible "
                        "to the Maranao community and Filipino Muslims worldwide.",
                    style: GoogleFonts.merriweather(
                      fontSize: 15,
                      height: 1.4,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // 🔹 Dedication in Card
            Card(
              color: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.orangeAccent, width: 1),
              ),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Dedication",
                      style: GoogleFonts.merriweather(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "This app is a voluntary work dedicated to Allah ﷻ, "
                          "as sadaqah jariyah for the author's and the developer’s aging father, "
                          "late mother, and late younger sister. "
                          "May Allah accept this humble effort and grant abundant rewards.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.merriweather(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // 🔹 Hadith on Sadaqah Jariyah
            Center(
              child: Text(
                "إِذَا مَاتَ الإِنْسَانُ انْقَطَعَ عَنْهُ عَمَلُهُ إِلَّا مِنْ ثَلاَثٍ: صَدَقَةٍ جَارِيَةٍ، أَوْ عِلْمٍ يُنْتَفَعُ بِهِ، أَوْ وَلَدٍ صَالِحٍ يَدْعُو لَهُ",
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  height: 1.8,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "“When a person dies, his deeds come to an end except for three: ongoing charity, beneficial knowledge, or a righteous child who prays for him.” (Sahih Muslim 1631)",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // 🔹 Qur’an 2:261
            Center(
              child: Text(
                "مَثَلُ الَّذِينَ يُنْفِقُونَ أَمْوَالَهُمْ فِي سَبِيلِ اللَّهِ كَمَثَلِ حَبَّةٍ أَنْبَتَتْ سَبْعَ سَنَابِلَ فِي كُلِّ سُنْبُلَةٍ مِائَةُ حَبَّةٍ ۗ وَاللَّهُ يُضَاعِفُ لِمَنْ يَشَاءُ ۗ وَاللَّهُ وَاسِعٌ عَلِيمٌ",
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 18,
                  height: 1.8,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "“The example of those who spend their wealth in the way of Allah is like a seed of grain which grows seven spikes; in each spike is a hundred grains. And Allah multiplies [His reward] for whom He wills. And Allah is all-Encompassing and Knowing.” (Qur’an 2:261)",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  color: Colors.white70,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 🔹 Project Links
            Text(
              "Project Links:",
              style: GoogleFonts.merriweather(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                "Website: ${AppConstants.websiteUrl}",
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                "GitHub: ${AppConstants.repoUrl}",
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            InkWell(
              onTap: () {},
              child: Text(
                "Contact: ${AppConstants.supportEmail}",
                style: GoogleFonts.merriweather(
                  fontSize: 16,
                  color: Colors.blueAccent,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 🔹 Footer
            const Divider(thickness: 0.5, color: Colors.white24, height: 30),
            Center(
              child: Text(
                "All rights reserved © $currentYear, dedicated fi sabeelillah",
                style: GoogleFonts.merriweather(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.white54,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
