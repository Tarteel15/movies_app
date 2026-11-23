import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/movie_details_bloc.dart';

class MovieDetailsPage extends StatefulWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  @override
  void initState() {
    super.initState();
    context.read<MovieDetailsBloc>().add(LoadMovieDetailsEvent(widget.movieId));
  }

  String? _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    return '${ApiConstants.imageBaseUrl}$path';
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
                child: Text(
                  state.errorMessage ?? 'Failed to load movie details',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
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

          final headerImage =
              _buildImageUrl(movie.backdropPath) ??
              _buildImageUrl(movie.posterPath);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 260,
                pinned: true,
                backgroundColor: AppColors.background,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: AppColors.textPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (headerImage != null)
                        CachedNetworkImage(
                          imageUrl: headerImage,
                          fit: BoxFit.cover,
                        )
                      else
                        Container(color: AppColors.surface),
                      Container(
                        color: AppColors.background.withValues(alpha: 0.35),
                      ),
                      Center(
                        child: Image.asset(
                          AppAssets.playButton,
                          width: 64,
                          height: 64,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  AppAssets.star,
                                  width: 15,
                                  height: 15,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  movie.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (movie.releaseDate.isNotEmpty) ...[
                            const SizedBox(width: 12),
                            Text(
                              movie.releaseDate,
                              style: TextStyle(
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.75,
                                ),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Overview',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        movie.overview.isNotEmpty
                            ? movie.overview
                            : 'No overview available.',
                        style: TextStyle(
                          color: AppColors.textPrimary.withValues(alpha: 0.9),
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
