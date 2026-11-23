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
  static const Color _accentYellow = Color(0xFFF6BD00);
  static const Color _dividerDark = Color(0xFF282A28);

  int _selectedTabIndex = 0; // 0 = Watch List, 1 = History

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
      width: 96,
      height: 96,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: _accentYellow, width: 2),
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
              size: 42,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat({
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Text(
                count,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedTabIndex = index),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Icon(
              icon,
              color: _accentYellow,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 3,
              color: isSelected ? _accentYellow : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPopcornState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: _accentYellow.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_movies_rounded,
              color: _accentYellow,
              size: 52,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _selectedTabIndex == 0
                ? 'Your watch list is empty'
                : 'Your history is empty',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w500,
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
        child: BlocConsumer<ProfileBloc, ProfileState>(
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
            final wishListMovies = state.watchlist;
            final historyMovies = state.history;
            final activeMovies =
                _selectedTabIndex == 0 ? wishListMovies : historyMovies;

            return RefreshIndicator(
              color: _accentYellow,
              backgroundColor: AppColors.surface,
              onRefresh: () async {
                context.read<ProfileBloc>().add(const LoadProfileEvent());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        _buildAvatar(user?.avatarPath),
                        const SizedBox(width: 12),
                        _buildHeaderStat(
                          count: '${wishListMovies.length}',
                          label: 'Wish List',
                          onTap: () => setState(() => _selectedTabIndex = 0),
                        ),
                        _buildHeaderStat(
                          count: '${historyMovies.length}',
                          label: 'History',
                          onTap: () => setState(() => _selectedTabIndex = 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.name ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          flex: 6,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentYellow,
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
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
                              child: const Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE51924),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {
                                context
                                    .read<ProfileBloc>()
                                    .add(const LogoutEvent());
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Exit',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  Icon(Icons.logout, size: 18),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _buildTabItem(
                          index: 0,
                          label: 'Watch List',
                          icon: Icons.format_list_bulleted_rounded,
                        ),
                        _buildTabItem(
                          index: 1,
                          label: 'History',
                          icon: Icons.folder_rounded,
                        ),
                      ],
                    ),
                    Container(height: 1, color: _dividerDark),
                    const SizedBox(height: 12),
                    activeMovies.isEmpty
                        ? _buildEmptyPopcornState()
                        : WatchlistGridWidget(
                            movies: activeMovies,
                            onMovieTap: (movie) {
                              context
                                  .read<ProfileBloc>()
                                  .add(AddToHistoryEvent(movie));
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      MovieDetailsPage(movieId: movie.id),
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
              ),
            );
          },
        ),
      ),
    );
  }
}