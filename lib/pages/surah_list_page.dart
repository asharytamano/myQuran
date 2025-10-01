import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'surah_detail_page.dart';
import 'favorites_page.dart';

class SurahListPage extends StatefulWidget {
  const SurahListPage({super.key});

  @override
  State<SurahListPage> createState() => _SurahListPageState();
}

class _SurahListPageState extends State<SurahListPage> {
  late Future<List<dynamic>> surahs;

  @override
  void initState() {
    super.initState();
    surahs = ApiService.fetchSurahList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF003231),
      appBar: AppBar(
        title: Text(
          "Surah List",
          style: GoogleFonts.merriweather(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.amber[700],
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite, color: Colors.red),
            tooltip: "View Favorites",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritesPage()),
              );
            },
          ),
        ],
      ),

      body: FutureBuilder<List<dynamic>>(
        future: surahs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: GoogleFonts.merriweather(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "No surahs found",
                style: GoogleFonts.merriweather(color: Colors.white),
              ),
            );
          }

          final surahList = snapshot.data!;

          return ListView.builder(
            itemCount: surahList.length,
            itemBuilder: (context, index) {
              final surah = surahList[index];
              return Card(
                color: Colors.black.withOpacity(0.7),
                margin: const EdgeInsets.symmetric(
                    vertical: 6, horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(
                    color: Colors.orangeAccent,
                    width: 0.6,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  title: Text(
                    surah['surah_name_en'] ?? "",
                    style: GoogleFonts.merriweather(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                  subtitle: Text(
                    surah['surah_name_ar'] ?? "",
                    textAlign: TextAlign.right,
                    style: GoogleFonts.amiri(
                      fontSize: 20,
                      color: Colors.white,
                      height: 1.6,
                    ),
                  ),
                  trailing: Text(
                    "Ayahs: ${surah['ayah_count']}",
                    style: GoogleFonts.merriweather(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SurahDetailPage(
                          surahNumber: surah['surah_number'],
                          surahNameEnglish: surah['surah_name_en'],
                          surahNameArabic: surah['surah_name_ar'],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
