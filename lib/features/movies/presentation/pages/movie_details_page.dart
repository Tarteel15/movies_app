import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../domain/entities/movie_entity.dart';
import '../bloc/browse_bloc.dart';
import '../bloc/home_bloc.dart';
import '../bloc/movie_details_bloc.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  static const Color _accentYellow = Color(0xFFF6BD00);
  static const Color _watchRed = Color(0xFFE51924);
  static const Color _chipDark = Color(0xFF282A28);

  bool _isLiked = false;
  int? _lastRecordedHistoryMovieId;

  @override
  void initState() {
    super.initState();
    context.read<MovieDetailsBloc>().add(LoadMovieDetailsEvent(widget.movieId));
  }

  void _recordHistoryOnce(BuildContext context, MovieEntity movie) {
    if (_lastRecordedHistoryMovieId == movie.id) return;
    _lastRecordedHistoryMovieId = movie.id;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileBloc>().add(AddToHistoryEvent(movie));
      }
    });
  }

  String? _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${ApiConstants.imageBaseUrl}$path';
  }

  String _extractYear(String releaseDate) {
    if (releaseDate.isEmpty) return '';
    final match = RegExp(r'\d{4}').firstMatch(releaseDate);
    return match?.group(0) ?? releaseDate;
  }

  int _readIntField(dynamic obj, List<String> keys, int fallback) {
    for (final key in keys) {
      try {
        final val = _readDynamic(obj, key);
        if (val is int) return val;
        if (val is num) return val.toInt();
        if (val != null) {
          final parsed = int.tryParse(val.toString());
          if (parsed != null) return parsed;
        }
      } catch (_) {}
    }
    return fallback;
  }

  List<dynamic> _readListField(dynamic obj, List<String> keys) {
    for (final key in keys) {
      try {
        final val = _readDynamic(obj, key);
        if (val is List && val.isNotEmpty) return val;
      } catch (_) {}
    }
    return const [];
  }

  dynamic _readDynamic(dynamic obj, String key) {
    if (obj == null) return null;
    if (obj is Map) return obj[key];
    switch (key) {
      case 'runtime':
        return obj.runtime;
      case 'likes':
        return obj.likes;
      case 'screenshots':
        return obj.screenshots;
      case 'similar':
        return obj.similar;
      case 'cast':
        return obj.cast;
      case 'genres':
        return obj.genres;
      default:
        return null;
    }
  }

  List<String> _getScreenshots(MovieEntity movie, List<dynamic> rawShots) {
    final urls = <String>[];
    for (final shot in rawShots) {
      final raw = shot is Map
          ? (shot['file_path'] ?? shot['backdrop_path'] ?? shot['image'])
          : shot;
      final url = _buildImageUrl(raw?.toString());
      if (url != null && !urls.contains(url)) urls.add(url);
    }
    if (urls.isEmpty) {
      for (final p in [movie.backdropPath, movie.posterPath]) {
        final url = _buildImageUrl(p);
        if (url != null && !urls.contains(url)) urls.add(url);
      }
    }
    return urls;
  }

  List<dynamic> _getSimilarItems(
    BuildContext context,
    MovieEntity movie,
    List<dynamic> rawSimilar,
  ) {
    if (rawSimilar.isNotEmpty) return rawSimilar;
    final pool = <MovieEntity>[
      ...context.read<HomeBloc>().state.movies,
      ...context.read<BrowseBloc>().state.movies,
    ];
    final fallback = <MovieEntity>[];
    for (final m in pool) {
      if (m.id != movie.id && !fallback.any((x) => x.id == m.id)) {
        fallback.add(m);
        if (fallback.length >= 4) break;
      }
    }
    return fallback;
  }

  Widget _buildStatChip({
    required String iconAsset,
    required String label,
    Color? iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: _chipDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              iconAsset,
              width: 16,
              height: 16,
              color: iconColor,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<MovieDetailsBloc, MovieDetailsState>(
        builder: (context, state) {
          if (state.status == MovieDetailsStatus.loading) {
            return const LoadingIndicator();
          }

          if (state.status == MovieDetailsStatus.failure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.errorMessage ?? 'Failed to load movie details',
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
                        context
                            .read<MovieDetailsBloc>()
                            .add(LoadMovieDetailsEvent(widget.movieId));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final movie = state.movie;
          if (movie == null) {
            return const Center(
              child: Text(
                'Movie details not found',
                style: TextStyle(color: AppColors.textPrimary),
              ),
            );
          }

          _recordHistoryOnce(context, movie);

          final isBookmarked = context.select<ProfileBloc, bool>(
            (bloc) => bloc.state.watchlist.any((m) => m.id == movie.id),
          );

          final posterUrl =
              _buildImageUrl(movie.posterPath) ??
              _buildImageUrl(movie.backdropPath);
          final yearText = _extractYear(movie.releaseDate);
          final likesCount = _readIntField(movie, const ['likes'], 15);
          final runtimeMinutes = _readIntField(movie, const ['runtime'], 90);
          final screenshots = _getScreenshots(
            movie,
            _readListField(movie, const ['screenshots']),
          );
          final similarMovies = _getSimilarItems(
            context,
            movie,
            _readListField(movie, const ['similar']),
          );
          final castList = _readListField(movie, const ['cast']);
          final genresList = _readListField(movie, const ['genres']);

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 360,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                if (posterUrl != null)
                                  CachedNetworkImage(
                                    imageUrl: posterUrl,
                                    fit: BoxFit.cover,
                                    errorWidget: (_, _, _) => Container(
                                      color: AppColors.surface,
                                      child: const Icon(
                                        Icons.movie,
                                        color: Colors.white38,
                                        size: 48,
                                      ),
                                    ),
                                  )
                                else
                                  Container(color: AppColors.surface),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.35),
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
                        Positioned(
                          top: 12,
                          left: 12,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                AppAssets.icBack,
                                width: 18,
                                height: 18,
                                color: Colors.white,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              context
                                  .read<ProfileBloc>()
                                  .add(ToggleWatchlistEvent(movie));
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.55),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                AppAssets.icBookmark,
                                width: 18,
                                height: 18,
                                color: isBookmarked
                                    ? _accentYellow
                                    : Colors.white,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              context
                                  .read<ProfileBloc>()
                                  .add(AddToHistoryEvent(movie));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Playing ${movie.title}...'),
                                ),
                              );
                            },
                            child: Image.asset(
                              AppAssets.playButton,
                              width: 68,
                              height: 68,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    movie.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (yearText.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      yearText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _watchRed,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        context
                            .read<ProfileBloc>()
                            .add(AddToHistoryEvent(movie));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Watching ${movie.title}'),
                          ),
                        );
                      },
                      child: const Text(
                        'Watch',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _isLiked = !_isLiked),
                        child: _buildStatChip(
                          iconAsset: AppAssets.icHeart,
                          label: '${_isLiked ? likesCount + 1 : likesCount}',
                          iconColor: _isLiked ? _watchRed : _accentYellow,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _buildStatChip(
                        iconAsset: AppAssets.icClock,
                        label: '$runtimeMinutes',
                        iconColor: _accentYellow,
                      ),
                      const SizedBox(width: 10),
                      _buildStatChip(
                        iconAsset: AppAssets.star,
                        label: movie.voteAverage.toStringAsFixed(1),
                      ),
                    ],
                  ),
                  if (screenshots.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    const Text(
                      'Screen Shots',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...screenshots.map((shotUrl) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: shotUrl,
                            height: 170,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    }),
                  ],
                  if (similarMovies.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Similar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: similarMovies.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.68,
                      ),
                      itemBuilder: (context, index) {
                        final item = similarMovies[index];
                        final simId = item is MovieEntity
                            ? item.id
                            : (item is Map ? (item['id'] as num?)?.toInt() : null);
                        final simRating = item is MovieEntity
                            ? item.voteAverage
                            : (item is Map
                                ? ((item['vote_average'] ?? item['voteAverage'] ?? 0) as num).toDouble()
                                : 0.0);
                        final simUrl = _buildImageUrl(
                          item is MovieEntity
                              ? (item.posterPath ?? item.backdropPath)
                              : (item is Map
                                  ? (item['poster_path'] ?? item['posterPath'] ?? item['backdrop_path'])?.toString()
                                  : (item?.posterPath ?? item?.posterUrl)?.toString()),
                        );
                        return GestureDetector(
                          onTap: () {
                            if (simId != null && simId > 0) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MovieDetailsPage(movieId: simId),
                                ),
                              );
                            }
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                simUrl != null
                                    ? CachedNetworkImage(
                                        imageUrl: simUrl,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(color: AppColors.surface),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.72),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          simRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Icon(
                                          Icons.star_rounded,
                                          color: _accentYellow,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text(
                    'Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : 'No summary available.',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  if (castList.isNotEmpty) ...[
                    const SizedBox(height: 22),
                    const Text(
                      'Cast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...castList.map((member) {
                      final memberName = (member?.name ?? '').toString();
                      final characterName =
                          (member?.character ?? member?.role ?? '').toString();
                      final avatarUrl = _buildImageUrl(
                        member?.profilePath ?? member?.avatarUrl,
                      );
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _chipDark,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: avatarUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: avatarUrl,
                                      width: 52,
                                      height: 52,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 52,
                                      height: 52,
                                      color: AppColors.surface,
                                      child: const Icon(
                                        Icons.person,
                                        color: Colors.white54,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Name : $memberName',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (characterName.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      'Character : $characterName',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                  if (genresList.isNotEmpty) ...[
                    const SizedBox(height: 14),
                    const Text(
                      'Genres',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: genresList.map((genre) {
                        final label = (genre is String
                                ? genre
                                : (genre?.name ?? genre.toString()))
                            .toString();
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: _chipDark,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}