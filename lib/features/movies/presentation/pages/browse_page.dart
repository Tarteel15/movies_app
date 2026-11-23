import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
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
  static const List<MapEntry<int, String>> _genres = [
    MapEntry(28, 'Action'),
    MapEntry(12, 'Adventure'),
    MapEntry(16, 'Animation'),
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Browse',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          BlocBuilder<BrowseBloc, BrowseState>(
            builder: (context, state) {
              final activeId = state.selectedGenreId ?? _genres.first.key;
              return SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _genres.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final genre = _genres[index];
                    return GenreChipWidget(
                      label: genre.value,
                      isSelected: activeId == genre.key,
                      onTap: () {
                        context
                            .read<BrowseBloc>()
                            .add(LoadMoviesByGenreEvent(genre.key));
                      },
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
                      child: Text(
                        state.errorMessage ?? 'Failed to load movies',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ),
                  );
                }

                if (state.movies.isEmpty) {
                  return const Center(
                    child: Text(
                      'No movies in this genre',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.movies.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                            builder: (_) => MovieDetailsPage(movieId: movie.id),
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
    );
  }
}