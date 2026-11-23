import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/watchlist_grid_widget.dart';
import 'update_profile_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(const LoadProfileEvent());
  }

  Widget _buildAvatar(String? avatarPath) {
    final path = (avatarPath != null && avatarPath.isNotEmpty)
        ? avatarPath
        : AppAssets.avatars.first;

    return Container(
      width: 76,
      height: 76,
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
      ),
      child: ClipOval(
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: AppColors.surface,
            alignment: Alignment.center,
            child: const Icon(
              Icons.person,
              color: AppColors.textPrimary,
              size: 36,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () {
              context.read<ProfileBloc>().add(const LogoutEvent());
            },
          ),
        ],
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.loggedOut) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          } else if (state.status == ProfileStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state.status == ProfileStatus.loading && state.user == null) {
            return const Center(child: LoadingIndicator());
          }

          final user = state.user;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _buildAvatar(user?.avatarPath),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'User',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => UpdateProfilePage(
                              initialName: user?.name ?? '',
                              initialAvatarPath: user?.avatarPath,
                            ),
                          ),
                        ).then((_) {
                          if (context.mounted) {
                            context.read<ProfileBloc>().add(
                              const LoadProfileEvent(),
                            );
                          }
                        });
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        foregroundColor: AppColors.primary,
                      ),
                      child: const Text('Edit'),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Watchlist',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                WatchlistGridWidget(
                  movies: state.watchlist,
                  onMovieTap: (movie) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MovieDetailsPage(movieId: movie.id),
                      ),
                    ).then((_) {
                      if (context.mounted) {
                        context.read<ProfileBloc>().add(
                          const LoadProfileEvent(),
                        );
                      }
                    });
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
