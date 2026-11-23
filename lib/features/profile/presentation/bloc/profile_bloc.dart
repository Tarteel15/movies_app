import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../movies/domain/entities/movie_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/get_watchlist_usecase.dart';
import '../../domain/usecases/toggle_watchlist_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfileEvent extends ProfileEvent {
  const LoadProfileEvent();
}

class UpdateProfileEvent extends ProfileEvent {
  final String name;
  final String? avatarPath;

  const UpdateProfileEvent({required this.name, this.avatarPath});

  @override
  List<Object?> get props => [name, avatarPath];
}

class ToggleWatchlistEvent extends ProfileEvent {
  final MovieEntity movie;

  const ToggleWatchlistEvent(this.movie);

  @override
  List<Object?> get props => [movie];
}

class AddToHistoryEvent extends ProfileEvent {
  final MovieEntity movie;

  const AddToHistoryEvent(this.movie);

  @override
  List<Object?> get props => [movie];
}

class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}

enum ProfileStatus { initial, loading, loaded, loggedOut, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user;
  final List<MovieEntity> watchlist;
  final List<MovieEntity> history;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.watchlist = const [],
    this.history = const [],
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    List<MovieEntity>? watchlist,
    List<MovieEntity>? history,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      watchlist: watchlist ?? this.watchlist,
      history: history ?? this.history,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, watchlist, history, errorMessage];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  static const String _historyStoragePrefix = 'profile_history_movies_v1';

  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;
  final GetWatchlistUseCase getWatchlistUseCase;
  final ToggleWatchlistUseCase toggleWatchlistUseCase;
  final ProfileRepository profileRepository;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
    required this.getWatchlistUseCase,
    required this.toggleWatchlistUseCase,
    required this.profileRepository,
  }) : super(const ProfileState()) {
    on<LoadProfileEvent>(_onLoadProfile);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<ToggleWatchlistEvent>(_onToggleWatchlist);
    on<AddToHistoryEvent>(_onAddToHistory);
    on<LogoutEvent>(_onLogout);
  }

  String _currentUserScope([UserEntity? loadedUser]) {
    String? rawId;
    try {
      rawId = FirebaseAuth.instance.currentUser?.uid ??
          FirebaseAuth.instance.currentUser?.email;
    } catch (_) {}

    rawId ??= loadedUser?.email ?? state.user?.email;

    final cleaned = (rawId == null || rawId.trim().isEmpty)
        ? 'guest'
        : rawId.trim().replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return cleaned;
  }

  String _historyKeyForScope(String scope) => '${_historyStoragePrefix}_$scope';

  Future<List<MovieEntity>> _loadSavedHistory(String scope) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_historyKeyForScope(scope));
      if (rawJson == null || rawJson.isEmpty) return const [];
      final decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded.map((item) {
        final map = item as Map<String, dynamic>;
        final rawGenres = map['genreIds'] as List<dynamic>? ?? const [];
        return MovieEntity(
          id: (map['id'] as num?)?.toInt() ?? 0,
          title: (map['title'] as String?) ?? 'Untitled',
          overview: (map['overview'] as String?) ?? '',
          posterPath: map['posterPath'] as String?,
          backdropPath: map['backdropPath'] as String?,
          voteAverage: ((map['voteAverage'] as num?) ?? 0).toDouble(),
          releaseDate: (map['releaseDate'] as String?) ?? '',
          genreIds: rawGenres.map((e) => (e as num).toInt()).toList(),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> _saveHistory(String scope, List<MovieEntity> movies) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        movies
            .map(
              (m) => {
                'id': m.id,
                'title': m.title,
                'overview': m.overview,
                'posterPath': m.posterPath,
                'backdropPath': m.backdropPath,
                'voteAverage': m.voteAverage,
                'releaseDate': m.releaseDate,
                'genreIds': m.genreIds,
              },
            )
            .toList(),
      );
      await prefs.setString(_historyKeyForScope(scope), encoded);
    } catch (_) {}
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProfileStatus.loading,
        watchlist: const [],
        history: const [],
        errorMessage: null,
      ),
    );

    final Either<Failure, UserEntity> profileRes = await getProfileUseCase();
    final loadedUser = profileRes.fold((_) => null, (u) => u);
    final scope = _currentUserScope(loadedUser);

    final Either<Failure, List<MovieEntity>> watchlistRes =
        await getWatchlistUseCase();
    final savedHistory = await _loadSavedHistory(scope);

    final currentWatchlist = watchlistRes.fold(
      (_) => const <MovieEntity>[],
      (movies) => movies,
    );

    profileRes.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          watchlist: currentWatchlist,
          history: savedHistory,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: user,
          watchlist: currentWatchlist,
          history: savedHistory,
        ),
      ),
    );
  }

  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    final result = await updateProfileUseCase(
      name: event.name,
      avatarPath: event.avatarPath,
    );
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(state.copyWith(status: ProfileStatus.loaded, user: user)),
    );
  }

  Future<void> _onToggleWatchlist(
    ToggleWatchlistEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final result = await toggleWatchlistUseCase(event.movie);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (updatedList) => emit(
        state.copyWith(status: ProfileStatus.loaded, watchlist: updatedList),
      ),
    );
  }

  Future<void> _onAddToHistory(
    AddToHistoryEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final scope = _currentUserScope();
    final updated = [
      event.movie,
      ...state.history.where((m) => m.id != event.movie.id),
    ];
    await _saveHistory(scope, updated);
    emit(state.copyWith(status: ProfileStatus.loaded, history: updated));
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<ProfileState> emit) async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));
    final result = await profileRepository.logout();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (_) => emit(const ProfileState(status: ProfileStatus.loggedOut)),
    );
  }
}