import '../../domain/entities/movie_entity.dart';

class MovieModel extends MovieEntity {
  const MovieModel({
    required super.id,
    required super.title,
    required super.overview,
    super.posterPath,
    super.backdropPath,
    required super.voteAverage,
    required super.releaseDate,
    required super.genreIds,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    final rawGenres = json['genre_ids'] as List<dynamic>?;
    final genresFromDetail = json['genres'] as List<dynamic>?;

    final List<int> parsedGenres = rawGenres != null
        ? rawGenres.map((e) => (e as num).toInt()).toList()
        : genresFromDetail != null
        ? genresFromDetail
              .map((e) => ((e as Map<String, dynamic>)['id'] as num).toInt())
              .toList()
        : <int>[];

    return MovieModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title:
          (json['title'] as String?) ?? (json['name'] as String?) ?? 'Untitled',
      overview: (json['overview'] as String?) ?? '',
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: ((json['vote_average'] as num?) ?? 0).toDouble(),
      releaseDate:
          (json['release_date'] as String?) ??
          (json['first_air_date'] as String?) ??
          '',
      genreIds: parsedGenres,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'overview': overview,
      'poster_path': posterPath,
      'backdrop_path': backdropPath,
      'vote_average': voteAverage,
      'release_date': releaseDate,
      'genre_ids': genreIds,
    };
  }
}
