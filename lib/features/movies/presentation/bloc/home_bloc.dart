import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/usecases/get_home_movies_usecase.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadHomeMoviesEvent extends HomeEvent {
  const LoadHomeMoviesEvent();
}

enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<MovieEntity> movies;
  final String? errorMessage;

  const HomeState({
    this.status = HomeStatus.initial,
    this.movies = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<MovieEntity>? movies,
    String? errorMessage,
  }) {
    return HomeState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, movies, errorMessage];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetHomeMoviesUseCase getHomeMoviesUseCase;

  HomeBloc({required this.getHomeMoviesUseCase}) : super(const HomeState()) {
    on<LoadHomeMoviesEvent>(_onLoadHomeMovies);
  }

  Future<void> _onLoadHomeMovies(
    LoadHomeMoviesEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(status: HomeStatus.loading, errorMessage: null));
    final result = await getHomeMoviesUseCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: HomeStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (movies) =>
          emit(state.copyWith(status: HomeStatus.success, movies: movies)),
    );
  }
}
