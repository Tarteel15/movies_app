import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../auth/presentation/pages/login_page.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<_OnBoardingItem> _items = const [
    _OnBoardingItem(
      title: 'Find Your Next\nFavorite Movie Here',
      subtitle:
          'Get access to a huge library of movies to suit all tastes. You will surely like it.',
      image: AppAssets.availableNow,
      isFirst: true,
      isLast: false,
    ),
    _OnBoardingItem(
      title: 'Discover Movies',
      subtitle:
          'Explore a vast collection of movies in all qualities and genres. Find your next favorite film with ease.',
      image: AppAssets.watchNow,
      isFirst: false,
      isLast: false,
    ),
    _OnBoardingItem(
      title: 'Explore All Genres',
      subtitle:
          'Discover movies from every genre, in all available qualities. Find something new and exciting to watch every day.',
      image: AppAssets.appLogo,
      isFirst: false,
      isLast: false,
    ),
    _OnBoardingItem(
      title: 'Create Watchlists',
      subtitle:
          'Save movies to your watchlist to keep track of what you want to watch next. Enjoy films in various qualities and genres.',
      image: AppAssets.playButton,
      isFirst: false,
      isLast: false,
    ),
    _OnBoardingItem(
      title: 'Rate, Review, and Learn',
      subtitle:
          'Share your thoughts on the movies you\'ve watched. Dive deep into film details and help others discover great movies with your reviews.',
      image: AppAssets.star,
      isFirst: false,
      isLast: false,
    ),
    _OnBoardingItem(
      title: 'Start Watching Now',
      subtitle: '',
      image: AppAssets.appLogo,
      isFirst: false,
      isLast: true,
    ),
  ];

  void _goNext() {
    if (_currentIndex < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }

  void _goBack() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        itemCount: _items.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                item.image,
                fit: item.isFirst || item.isLast
                    ? BoxFit.contain
                    : BoxFit.cover,
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.85),
                      AppColors.background,
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.95),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (item.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Text(
                              item.subtitle,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF6BD00),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _goNext,
                              child: Text(
                                item.isFirst
                                    ? 'Explore Now'
                                    : item.isLast
                                        ? 'Finish'
                                        : 'Next',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          if (!item.isFirst) ...[
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(
                                    color: Color(0xFFF6BD00),
                                  ),
                                  foregroundColor: const Color(0xFFF6BD00),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                onPressed: _goBack,
                                child: const Text(
                                  'Back',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OnBoardingItem {
  final String title;
  final String subtitle;
  final String image;
  final bool isFirst;
  final bool isLast;

  const _OnBoardingItem({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.isFirst,
    required this.isLast,
  });
}