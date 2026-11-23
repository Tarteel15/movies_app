import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/usecases/get_movies_by_genre_usecase.dart';

abstract class BrowseEvent extends Equatable {
  const BrowseEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoviesByGenreEvent extends BrowseEvent {
  final int genreId;

  const LoadMoviesByGenreEvent(this.genreId);

  @override
  List<Object?> get props => [genreId];
}

enum BrowseStatus { initial, loading, success, failure }

class BrowseState extends Equatable {
  final BrowseStatus status;
  final List<MovieEntity> movies;
  final int? selectedGenreId;
  final String? errorMessage;

  const BrowseState({
    this.status = BrowseStatus.initial,
    this.movies = const [],
    this.selectedGenreId,
    this.errorMessage,
  });

  BrowseState copyWith({
    BrowseStatus? status,
    List<MovieEntity>? movies,
    int? selectedGenreId,
    String? errorMessage,
  }) {
    return BrowseState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      selectedGenreId: selectedGenreId ?? this.selectedGenreId,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, movies, selectedGenreId, errorMessage];
}

class BrowseBloc extends Bloc<BrowseEvent, BrowseState> {
  final GetMoviesByGenreUseCase getMoviesByGenreUseCase;

  BrowseBloc({required this.getMoviesByGenreUseCase})
    : super(const BrowseState()) {
    on<LoadMoviesByGenreEvent>(_onLoadMoviesByGenre);
  }

  Future<void> _onLoadMoviesByGenre(
    LoadMoviesByGenreEvent event,
    Emitter<BrowseState> emit,
  ) async {
    emit(
      state.copyWith(
        status: BrowseStatus.loading,
        selectedGenreId: event.genreId,
        errorMessage: null,
      ),
    );
    final result = await getMoviesByGenreUseCase(event.genreId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: BrowseStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (movies) =>
          emit(state.copyWith(status: BrowseStatus.success, movies: movies)),
    );
  }
}
