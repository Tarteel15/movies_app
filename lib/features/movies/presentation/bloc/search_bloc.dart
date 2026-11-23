import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/movie_entity.dart';
import '../../domain/usecases/search_movies_usecase.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchMoviesEvent extends SearchEvent {
  final String query;

  const SearchMoviesEvent(this.query);

  @override
  List<Object?> get props => [query];
}

enum SearchStatus { initial, loading, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final List<MovieEntity> results;
  final String? errorMessage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.results = const [],
    this.errorMessage,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<MovieEntity>? results,
    String? errorMessage,
  }) {
    return SearchState(
      status: status ?? this.status,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, results, errorMessage];
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchMoviesUseCase searchMoviesUseCase;

  SearchBloc({required this.searchMoviesUseCase}) : super(const SearchState()) {
    on<SearchMoviesEvent>(_onSearchMovies);
  }

  Future<void> _onSearchMovies(
    SearchMoviesEvent event,
    Emitter<SearchState> emit,
  ) async {
    final trimmed = event.query.trim();
    if (trimmed.isEmpty) {
      emit(const SearchState());
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading, errorMessage: null));
    final result = await searchMoviesUseCase(trimmed);
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (movies) =>
          emit(state.copyWith(status: SearchStatus.success, results: movies)),
    );
  }
}
