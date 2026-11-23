import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../domain/entities/movie_entity.dart';
import '../bloc/home_bloc.dart';
import '../widgets/movie_card_widget.dart';
import 'browse_page.dart';
import 'movie_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color _accentYellow = Color(0xFFF6BD00);

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const LoadHomeMoviesEvent());
  }

  void _openMovieDetails(MovieEntity movie) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MovieDetailsPage(movieId: movie.id),
      ),
    );
  }

  String _formatImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return '';
    final clean = path.trim();
    if (clean.startsWith('http://') || clean.startsWith('https://')) {
      return clean;
    }
    return '${ApiConstants.imageBaseUrl}$clean';
  }

  String _resolvePosterUrl(MovieEntity movie) {
    final poster = _formatImageUrl(movie.posterPath);
    if (poster.isNotEmpty) return poster;
    return _formatImageUrl(movie.backdropPath);
  }

  String _resolveBackdropUrl(MovieEntity movie) {
    final backdrop = _formatImageUrl(movie.backdropPath);
    if (backdrop.isNotEmpty) return backdrop;
    return _formatImageUrl(movie.posterPath);
  }

  String _resolveRating(MovieEntity movie) {
    if (movie.voteAverage > 0) {
      return movie.voteAverage.toStringAsFixed(1);
    }
    return '7.7';
  }

  List<MovieEntity> _pickFeaturedMovies(List<MovieEntity> allMovies) {
    final withImages = allMovies
        .where((m) => _resolvePosterUrl(m).isNotEmpty)
        .toList();
    final source = withImages.length >= 3 ? withImages : allMovies;
    return source.take(3).toList();
  }

  Widget _buildPosterTile(
    MovieEntity movie, {
    double? width,
    required double height,
  }) {
    final imageUrl = _resolvePosterUrl(movie);
    final ratingText = _resolveRating(movie);

    return GestureDetector(
      onTap: () => _openMovieDetails(movie),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl.isNotEmpty)
              Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Center(
                  child: Icon(Icons.movie, color: Colors.white38, size: 32),
                ),
              )
            else
              const Center(
                child: Icon(Icons.movie, color: Colors.white38, size: 32),
              ),
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      ratingText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Image.asset(
                      AppAssets.star,
                      width: 12,
                      height: 12,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableNowSection(List<MovieEntity> featured) {
    if (featured.isEmpty) return const SizedBox.shrink();

    final centerMovie = featured.length > 1 ? featured[1] : featured[0];
    final leftMovie = featured.isNotEmpty ? featured[0] : null;
    final rightMovie = featured.length > 2 ? featured[2] : null;
    final backdropUrl = _resolveBackdropUrl(centerMovie);

    return SizedBox(
      height: 255,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (backdropUrl.isNotEmpty)
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: 0.34,
                      child: Image.network(
                        backdropUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.background.withValues(alpha: 0.55),
                            Colors.transparent,
                            AppColors.background,
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (leftMovie != null && featured.length > 1)
                  Expanded(
                    flex: 2,
                    child: _buildPosterTile(
                      leftMovie,
                      height: 185,
                    ),
                  ),
                if (leftMovie != null && featured.length > 1)
                  const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: _buildPosterTile(
                    centerMovie,
                    height: 230,
                  ),
                ),
                if (rightMovie != null) const SizedBox(width: 8),
                if (rightMovie != null)
                  Expanded(
                    flex: 2,
                    child: _buildPosterTile(
                      rightMovie,
                      height: 185,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state.status == HomeStatus.loading) {
              return const LoadingIndicator();
            }

            if (state.status == HomeStatus.failure) {
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
                          context.read<HomeBloc>().add(
                                const LoadHomeMoviesEvent(),
                              );
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
                      'No movies available',
                      style: TextStyle(color: AppColors.textPrimary),
                    ),
                  ],
                ),
              );
            }

            final movies = state.movies;
            final featured = _pickFeaturedMovies(movies);

            return RefreshIndicator(
              color: _accentYellow,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                context.read<HomeBloc>().add(const LoadHomeMoviesEvent());
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Center(
                    child: Image.asset(
                      AppAssets.availableNow,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildAvailableNowSection(featured),
                  const SizedBox(height: 18),
                  Center(
                    child: Image.asset(
                      AppAssets.watchNow,
                      height: 44,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Action',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BrowsePage(),
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'See More',
                              style: TextStyle(
                                color: _accentYellow,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              color: _accentYellow,
                              size: 15,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 185,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: movies.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return SizedBox(
                          width: 125,
                          child: MovieCardWidget(
                            movie: movie,
                            onTap: () => _openMovieDetails(movie),
                          ),
                        );
                      },
                    ),
                  ),
                  if (movies.length > featured.length) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'All Movies',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: movies.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.66,
                      ),
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return MovieCardWidget(
                          movie: movie,
                          onTap: () => _openMovieDetails(movie),
                        );
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}