import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

class LogoutEvent extends ProfileEvent {
  const LogoutEvent();
}

enum ProfileStatus { initial, loading, loaded, loggedOut, failure }

class ProfileState extends Equatable {
  final ProfileStatus status;
  final UserEntity? user;
  final List<MovieEntity> watchlist;
  final String? errorMessage;

  const ProfileState({
    this.status = ProfileStatus.initial,
    this.user,
    this.watchlist = const [],
    this.errorMessage,
  });

  ProfileState copyWith({
    ProfileStatus? status,
    UserEntity? user,
    List<MovieEntity>? watchlist,
    String? errorMessage,
  }) {
    return ProfileState(
      status: status ?? this.status,
      user: user ?? this.user,
      watchlist: watchlist ?? this.watchlist,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, user, watchlist, errorMessage];
}

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
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
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLoadProfile(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, errorMessage: null));

    final Either<Failure, UserEntity> profileRes = await getProfileUseCase();
    final Either<Failure, List<MovieEntity>> watchlistRes =
        await getWatchlistUseCase();

    final currentWatchlist = watchlistRes.fold(
      (_) => state.watchlist,
      (movies) => movies,
    );

    profileRes.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          watchlist: currentWatchlist,
          errorMessage: failure.message,
        ),
      ),
      (user) => emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          user: user,
          watchlist: currentWatchlist,
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
