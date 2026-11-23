import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/browse_bloc.dart';
import '../widgets/genre_chip_widget.dart';
import '../widgets/movie_card_widget.dart';
import 'movie_details_page.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  static const Color _accentYellow = Color(0xFFF6BD00);

  static const List<MapEntry<int, String>> _genres = [
    MapEntry(28, 'Action'),
    MapEntry(12, 'Adventure'),
    MapEntry(16, 'Animation'),
    MapEntry(99, 'Biography'),
    MapEntry(35, 'Comedy'),
    MapEntry(18, 'Drama'),
    MapEntry(27, 'Horror'),
    MapEntry(878, 'Sci-Fi'),
    MapEntry(53, 'Thriller'),
  ];

  @override
  void initState() {
    super.initState();
    context
        .read<BrowseBloc>()
        .add(LoadMoviesByGenreEvent(_genres.first.key));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 10),
              child: Text(
                'Browse',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            BlocBuilder<BrowseBloc, BrowseState>(
              builder: (context, state) {
                final activeId = state.selectedGenreId ?? _genres.first.key;
                return SizedBox(
                  height: 44,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _genres.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final genre = _genres[index];
                      final isSelected = activeId == genre.key;

                      return GestureDetector(
                        onTap: () {
                          context
                              .read<BrowseBloc>()
                              .add(LoadMoviesByGenreEvent(genre.key));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _accentYellow
                                : AppColors.background,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _accentYellow,
                              width: 1.5,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            genre.value,
                            style: TextStyle(
                              color: isSelected ? Colors.black : _accentYellow,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<BrowseBloc, BrowseState>(
                builder: (context, state) {
                  if (state.status == BrowseStatus.loading) {
                    return const LoadingIndicator();
                  }

                  if (state.status == BrowseStatus.failure) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              state.errorMessage ?? 'Failed to load movies',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: AppColors.error),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentYellow,
                                foregroundColor: Colors.black,
                              ),
                              onPressed: () {
                                final activeId =
                                    state.selectedGenreId ?? _genres.first.key;
                                context
                                    .read<BrowseBloc>()
                                    .add(LoadMoviesByGenreEvent(activeId));
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (state.movies.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            AppAssets.emptySearch,
                            width: 110,
                            height: 110,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'No movies in this genre',
                            style: TextStyle(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    itemCount: state.movies.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.66,
                    ),
                    itemBuilder: (context, index) {
                      final movie = state.movies[index];
                      return MovieCardWidget(
                        movie: movie,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  MovieDetailsPage(movieId: movie.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}