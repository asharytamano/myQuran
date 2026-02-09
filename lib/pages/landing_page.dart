import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'surah_list_page.dart';
import 'about_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("myQur'an"),
        backgroundColor: Colors.orange,
      ),

      // 🔹 Drawer menu
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.orange),
              child: Text(
                "myQur'an",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.book),
              title: const Text("Surah List"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SurahListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text("Favorites"),
              onTap: () {
                Navigator.pushNamed(context, "/favorites");
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.deepPurple),
              title: const Text("Reciters & Audio"),
              onTap: () {
                Navigator.pushNamed(context, "/reciters");
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf),
              title: const Text("Download PDF"),
              onTap: () async {
                final url = Uri.parse(
                  "https://drive.google.com/file/d/18RSfRVKqVJ8DtFxtJoWB9rTqswsYtWFl/view",
                );
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline, color: Colors.blue),
              title: const Text("Help & How to Use"),
              onTap: () {
                Navigator.pushNamed(context, "/help");
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About App"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutPage()),
                );
              },
            ),
          ],
        ),
      ),

      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/bg.jpg"),
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 240),
              Text(
                "بِسْمِ اللَّهِ الرَّحْمَـٰنِ الرَّحِيمِ",
                textAlign: TextAlign.center,
                style: GoogleFonts.amiri(
                  fontSize: 26,
                  color: Colors.amber,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Welcome to myQur'an",
                textAlign: TextAlign.center,
                style: GoogleFonts.merriweather(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  "This app features Qur'an translations in Maranao, Tagalog, Bisayan and English. Listen to your favorite reciters, save verses to Favorites, and easily share them for study or on social media.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.merriweather(
                    fontSize: 14,
                    color: Colors.white,
                    height: 1.7,
                  ),
                ),
              ),
              const SizedBox(height: 40), // Reduced space before button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SurahListPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber[700],
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 24,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Go to Surah List",
                      style: GoogleFonts.merriweather(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(), // Pushes everything above it to the top
            ],
          ),
        ),
      ),
      // Removed the bottomNavigationBar completely
      bottomNavigationBar: Container(
        color: Colors.amber[700],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          "App developed by Ashary Tamano.",
          textAlign: TextAlign.center,
          style: GoogleFonts.merriweather(fontSize: 11, color: Colors.black),
        ),
      ),
    );
  }
}
