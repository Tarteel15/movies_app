import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/usecases/get_movie_details_usecase.dart';

abstract class MovieDetailsEvent extends Equatable {
  const MovieDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMovieDetailsEvent extends MovieDetailsEvent {
  final int movieId;

  const LoadMovieDetailsEvent(this.movieId);

  @override
  List<Object?> get props => [movieId];
}

enum MovieDetailsStatus { initial, loading, success, failure }

class MovieDetailsState extends Equatable {
  final MovieDetailsStatus status;
  final MovieEntity? movie;
  final String? errorMessage;

  const MovieDetailsState({
    this.status = MovieDetailsStatus.initial,
    this.movie,
    this.errorMessage,
  });

  MovieDetailsState copyWith({
    MovieDetailsStatus? status,
    MovieEntity? movie,
    String? errorMessage,
  }) {
    return MovieDetailsState(
      status: status ?? this.status,
      movie: movie ?? this.movie,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, movie, errorMessage];
}

class MovieDetailsBloc extends Bloc<MovieDetailsEvent, MovieDetailsState> {
  final GetMovieDetailsUseCase getMovieDetailsUseCase;

  MovieDetailsBloc({required this.getMovieDetailsUseCase})
    : super(const MovieDetailsState()) {
    on<LoadMovieDetailsEvent>(_onLoadMovieDetails);
  }

  Future<void> _onLoadMovieDetails(
    LoadMovieDetailsEvent event,
    Emitter<MovieDetailsState> emit,
  ) async {
    emit(
      state.copyWith(status: MovieDetailsStatus.loading, errorMessage: null),
    );
    final result = await getMovieDetailsUseCase(event.movieId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: MovieDetailsStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (movie) => emit(
        state.copyWith(status: MovieDetailsStatus.success, movie: movie),
      ),
    );
  }
}
