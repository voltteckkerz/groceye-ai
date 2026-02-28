`import 'package:flutter/material.dart';
import '../services/language_service.dart';

class InfoScreen extends StatefulWidget {
  final LanguageService languageService;

  const InfoScreen({
    super.key,
    required this.languageService,
  });

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final slides = _getSlides();

    return Scaffold(
      backgroundColor: const Color(0xFFFFD1C9),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 60), // Space for back button
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: slides.length,
                    itemBuilder: (context, index) {
                      return _buildSlide(slides[index]);
                    },
                  ),
                ),
                
                // Page indicator
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFFF73C1B)
                              : Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Floating back button
            Positioned(
              top: 16,
              left: 16,
              child: Material(
                color: const Color(0xFFFFB84D),
                borderRadius: BorderRadius.circular(12),
                elevation: 4,
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(InfoSlide slide) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: slide.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                slide.icon,
                size: 60,
                color: slide.color,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Title
            Text(
              slide.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Description
            Text(
              slide.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black.withOpacity(0.6),
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            // Features list
            ...slide.features.map((feature) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: slide.color,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF333333),
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  List<InfoSlide> _getSlides() {
    if (widget.languageService.isEnglish) {
      return [
        InfoSlide(
          title: 'How to Scan',
          description: 'Follow these simple steps to scan products',
          icon: Icons.camera_alt,
          color: const Color(0xFFF73C1B),
          features: [
            'Tap Scanner button on home screen',
            'Point camera at products',
            'Wait for automatic detection',
            'Listen to voice announcements',
          ],
        ),
        InfoSlide(
          title: 'Text Recognition',
          description: 'Automatically read labels and packaging',
          icon: Icons.text_fields,
          color: const Color(0xFFFFB84D),
          features: [
            'Detects text on product labels',
            'Reads ingredients and information',
            'Works with any language',
            'High accuracy recognition',
          ],
        ),
        InfoSlide(
          title: 'Features',
          description: 'Everything you need in one app',
          icon: Icons.star,
          color: const Color(0xFF9ED8FF),
          features: [
            'Object detection',
            'Text recognition (OCR)',
            'Voice announcements',
            '3-second scanning interval',
            'Bilingual support (EN/MS)',
          ],
        ),
      ];
    } else {
      return [
        InfoSlide(
          title: 'Cara Mengimbas',
          description: 'Ikuti langkah mudah ini untuk mengimbas produk',
          icon: Icons.camera_alt,
          color: const Color(0xFFF73C1B),
          features: [
            'Tekan butang Pengimbas',
            'Arahkan kamera ke produk',
            'Tunggu pengesanan automatik',
            'Dengar pengumuman suara',
          ],
        ),
        InfoSlide(
          title: 'Pengecaman Teks',
          description: 'Baca label dan pembungkusan secara automatik',
          icon: Icons.text_fields,
          color: const Color(0xFFFFB84D),
features: [
            'Mengesan teks pada label produk',
            'Membaca ramuan dan maklumat',
            'Berfungsi dengan semua bahasa',
            'Pengecaman ketepatan tinggi',
          ],
        ),
        InfoSlide(
          title: 'Ciri-ciri',
          description: 'Semua yang anda perlukan dalam satu aplikasi',
          icon: Icons.star,
          color: const Color(0xFF9ED8FF),
          features: [
            'Pengesanan objek',
            'Pengecaman teks (OCR)',
            'Pengumuman suara',
            'Pengimbasan 3 saat',
            'Sokongan dwibahasa (EN/MS)',
          ],
        ),
      ];
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class InfoSlide {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  InfoSlide({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.features,
  });
}
