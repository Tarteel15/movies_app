import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../movies/domain/entities/movie_entity.dart';

class WatchlistGridWidget extends StatelessWidget {
  final List<MovieEntity> movies;
  final ValueChanged<MovieEntity> onMovieTap;

  const WatchlistGridWidget({
    super.key,
    required this.movies,
    required this.onMovieTap,
  });

  static const String _imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text(
            'Your watchlist is empty.',
            style: TextStyle(
              color: AppColors.textPrimary.withValues(alpha: 0.7),
              fontSize: 15,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: movies.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.68,
      ),
      itemBuilder: (context, index) {
        final movie = movies[index];
        final posterUrl = movie.posterPath != null
            ? '$_imageBaseUrl${movie.posterPath}'
            : null;

        return GestureDetector(
          onTap: () => onMovieTap(movie),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              color: AppColors.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: posterUrl != null
                        ? Image.network(
                            posterUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const Center(
                              child: Icon(
                                Icons.movie,
                                color: AppColors.textPrimary,
                                size: 40,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.movie,
                              color: AppColors.textPrimary,
                              size: 40,
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
