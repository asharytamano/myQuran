import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/bookmark_manager.dart';
import '../utils/translation_loader.dart';

// 🔹 Custom Widgets
import '../widgets/ayah_card.dart';
import '../widgets/language_dropdown.dart';
import '../widgets/reciter_dropdown.dart';

class SurahDetailPage extends StatefulWidget {
  final int surahNumber;
  final String surahNameEnglish;
  final String surahNameArabic;
  final int? jumpToAyah;

  const SurahDetailPage({
    super.key,
    required this.surahNumber,
    required this.surahNameEnglish,
    required this.surahNameArabic,
    this.jumpToAyah,
  });

  @override
  State<SurahDetailPage> createState() => _SurahDetailPageState();
}

class _SurahDetailPageState extends State<SurahDetailPage>
    with TickerProviderStateMixin {
  List<Map<String, dynamic>> ayahs = [];
  bool loading = true;

  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController _scrollController = ScrollController();

  int? currentlyPlayingAyah;
  bool isPlaying = false;
  bool continuousPlay = true;
  int? expandedAyahIndex;

  bool repeatAyah = false;
  bool repeatSurah = false;

  String selectedLanguage = "maranao";
  String selectedReciter = "sudais";

  // 🔹 Pagination
  int currentPage = 0;
  final int pageSize = 50;

  final Map<int, GlobalKey> _ayahKeys = {};

  List<Map<String, dynamic>> get pagedAyahs {
    if (ayahs.isEmpty) return [];
    final start = currentPage * pageSize;
    final end =
    (start + pageSize) > ayahs.length ? ayahs.length : (start + pageSize);
    return ayahs.sublist(start, end);
  }

  int get totalPages => (ayahs.length / pageSize).ceil();

  @override
  void initState() {
    super.initState();
    fetchSurah().then((_) async {
      await _mergeTranslation(QuranLanguage.tagalog, "translation_tl");
      await _mergeTranslation(QuranLanguage.bisayan, "translation_bis");
      await _mergeTranslation(QuranLanguage.english, "translation_en");

      if (widget.jumpToAyah != null) {
        final index =
        ayahs.indexWhere((a) => a['ayah_number'] == widget.jumpToAyah);
        if (index != -1) {
          setState(() {
            currentPage = (index ~/ pageSize);
            expandedAyahIndex = index % pageSize;
          });
          _scrollToExpanded(expandedAyahIndex!);
        }
      }
    });
    _loadReciterPref();
    _audioPlayer.onPlayerComplete.listen((_) => _handlePlaybackComplete());
  }

  Future<void> fetchSurah() async {
    final res = await http.get(Uri.parse(
        "https://maranaw.com/api/surah_json.php?surah=${widget.surahNumber}"));
    final data = json.decode(res.body);

    setState(() {
      ayahs = List<Map<String, dynamic>>.from(data['data']['ayahs']);
      if (ayahs.isNotEmpty && ayahs.first['ayah_number'] == 0) {
        ayahs.removeAt(0);
      }
      loading = false;
    });
  }

  Future<void> _mergeTranslation(QuranLanguage lang, String fieldKey) async {
    final data = await TranslationLoader.load(lang, widget.surahNumber);
    if (data != null) {
      for (var i = 0; i < data.length && i < ayahs.length; i++) {
        if (data[i].containsKey("ayah_number")) {
          ayahs[i][fieldKey] = data[i][fieldKey];
        }
      }
      setState(() {});
    }
  }

  Future<void> _loadReciterPref() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString("selectedReciter");
    if (saved != null) setState(() => selectedReciter = saved);
  }

  Future<void> _saveReciterPref(String reciterId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedReciter", reciterId);
  }

  String _mapReciterBaseUrl(String reciterId) {
    switch (reciterId) {
      case "sudais":
        return "https://verses.quran.com/Sudais/mp3/";
      case "afasy":
        return "https://verses.quran.com/Alafasy/mp3/";
      case "ghamdi":
        return "https://everyayah.com/data/Ghamadi_40kbps/";
      case "rifai":
        return "https://everyayah.com/data/Hani_Rifai_192kbps/";
      case "abdulbasit":
        return "https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/";
      case "menshawi":
        return "https://everyayah.com/data/Menshawi_32kbps/";
      case "fares":
        return "https://everyayah.com/data/Fares_Abbad_64kbps/";
      case "matroud":
        return "https://everyayah.com/data/Abdullah_Matroud_128kbps/";
      default:
        return "https://verses.quran.com/Sudais/mp3/";
    }
  }

  Future<void> _playAyah(int ayahNumber, {int? index}) async {
    final surahStr = widget.surahNumber.toString().padLeft(3, '0');
    final ayahStr = ayahNumber.toString().padLeft(3, '0');
    final baseUrl = _mapReciterBaseUrl(selectedReciter);
    final url = "$baseUrl$surahStr$ayahStr.mp3";

    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(url));

    setState(() {
      currentlyPlayingAyah = index;
      isPlaying = true;
    });

    if (index != null) {
      _scrollToExpanded(index);
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
    setState(() => isPlaying = false);
  }

  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      isPlaying = false;
      currentlyPlayingAyah = null;
    });
  }

  void _handlePlaybackComplete() {
    if (currentlyPlayingAyah != null) {
      if (repeatAyah) {
        _playAyah(pagedAyahs[currentlyPlayingAyah!]['ayah_number'],
            index: currentlyPlayingAyah);
      } else if (repeatSurah) {
        final next = (currentlyPlayingAyah! + 1);
        if (next < pagedAyahs.length) {
          _playAyah(pagedAyahs[next]['ayah_number'], index: next);
        } else {
          _playAyah(pagedAyahs.first['ayah_number'], index: 0);
        }
      } else if (continuousPlay) {
        final next = (currentlyPlayingAyah! + 1);
        if (next < pagedAyahs.length) {
          _playAyah(pagedAyahs[next]['ayah_number'], index: next);
        } else {
          setState(() => isPlaying = false);
        }
      } else {
        setState(() => isPlaying = false);
      }
    }
  }

  void _scrollToExpanded(int index) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _ayahKeys[index];
      final ctx = key?.currentContext;
      if (ctx != null && _scrollController.hasClients) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
          alignment: 0.3,
        );
      }
    });
  }

  // 🔹 Custom Animated Overlay SnackBar with Bell Chime
  void _showTopSnackBar(BuildContext context, String message) async {
    final overlay = Overlay.of(context);

    // 🔔 Play bell chime sound
    final player = AudioPlayer();
    await player.play(AssetSource("sounds/bell-chime.mp3"));

    late OverlayEntry entry;
    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    );

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: kToolbarHeight + 16,
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, -0.3),
              end: Offset.zero,
            ).animate(animation),
            child: FadeTransition(
              opacity: animation,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.8),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);
    controller.forward();

    Future.delayed(const Duration(seconds: 3), () async {
      await controller.reverse();
      entry.remove();
      controller.dispose();
      player.dispose();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentPage >= totalPages) currentPage = totalPages - 1;
    if (currentPage < 0) currentPage = 0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.surahNameEnglish,
                style: GoogleFonts.merriweather(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text(widget.surahNameArabic,
                style: GoogleFonts.amiri(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          if (totalPages > 1)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  tooltip: "Previous Page",
                  onPressed: () {
                    if (currentPage > 0) {
                      setState(() => currentPage--);
                      if (expandedAyahIndex != null) {
                        _scrollToExpanded(expandedAyahIndex!);
                      }
                    } else {
                      _showTopSnackBar(context, "📖 Start of Surah");
                    }
                  },
                ),
                Text("${currentPage + 1}/$totalPages",
                    style: GoogleFonts.merriweather(
                        fontSize: 14, color: Colors.black)),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, color: Colors.black),
                  tooltip: "Next Page",
                  onPressed: () {
                    if ((currentPage + 1) < totalPages) {
                      setState(() => currentPage++);
                      if (expandedAyahIndex != null) {
                        _scrollToExpanded(expandedAyahIndex!);
                      }
                    } else {
                      _showTopSnackBar(context, "📖 End of Surah");
                    }
                  },
                ),
              ],
            ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: LanguageDropdown(
              selectedLanguage: selectedLanguage,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedLanguage = val);
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ReciterDropdown(
              selectedReciter: selectedReciter,
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedReciter = val);
                  _saveReciterPref(val);
                }
              },
              onPlayAll: () {
                if (pagedAyahs.isNotEmpty) {
                  _playAyah(pagedAyahs.first['ayah_number'], index: 0);
                }
              },
              onStop: _stopAudio,
            ),
          ),
          if (widget.surahNumber != 9)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.amiri(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black)),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: pagedAyahs.length,
              itemBuilder: (context, index) {
                final ayah = pagedAyahs[index];
                _ayahKeys[index] = GlobalKey();

                return Container(
                  key: _ayahKeys[index],
                  child: AyahCard(
                    ayah: ayah,
                    index: index,
                    surahNumber: widget.surahNumber,
                    selectedLanguage: selectedLanguage,
                    isExpanded: expandedAyahIndex == index,
                    isThisPlaying:
                    index == currentlyPlayingAyah && isPlaying,
                    onCopy: () {
                      final copyText =
                          "${ayah['text_ar']}\n\n${selectedLanguage == "maranao" ? (ayah['text_mn'] ?? "") : selectedLanguage == "tagalog" ? (ayah['translation_tl'] ?? "—") : selectedLanguage == "bisayan" ? (ayah['translation_bis'] ?? "—") : (ayah['translation_en'] ?? "—")}\n\n(${widget.surahNumber}:${ayah['ayah_number']})";
                      Clipboard.setData(ClipboardData(text: copyText));
                    },
                    onShare: () {
                      final shareText =
                          "${ayah['text_ar']}\n\n${selectedLanguage == "maranao" ? (ayah['text_mn'] ?? "") : selectedLanguage == "tagalog" ? (ayah['translation_tl'] ?? "—") : selectedLanguage == "bisayan" ? (ayah['translation_bis'] ?? "—") : (ayah['translation_en'] ?? "—")}\n\n(${widget.surahNumber}:${ayah['ayah_number']})";
                      Share.share(shareText);
                    },
                    onFavorite: () async {
                      final ayahData = {
                        'surah_number': widget.surahNumber,
                        'ayah_number': ayah['ayah_number'],
                        'text_ar': ayah['text_ar'] ?? "",
                        'text_mn': ayah['text_mn'] ?? "",
                        'translation_tl': ayah['translation_tl'] ?? "",
                        'translation_bis': ayah['translation_bis'] ?? "",
                        'translation_en': ayah['translation_en'] ?? "",
                      };
                      await BookmarkManager.addFavorite(ayahData);
                    },
                    onPlayPause: () {
                      if (index == currentlyPlayingAyah && isPlaying) {
                        _pauseAudio();
                      } else {
                        _playAyah(ayah['ayah_number'], index: index);
                      }
                    },
                    onToggleTranslation: () {
                      setState(() {
                        expandedAyahIndex =
                        expandedAyahIndex == index ? null : index;
                      });
                      _scrollToExpanded(index);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
