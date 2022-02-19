// To parse this JSON data, do
//
//     final searchMovieDto = searchMovieDtoFromMap(jsonString);

import 'package:meta/meta.dart';
import 'dart:convert';

import 'package:movies_app/models/movie.dart';

class SearchMovieDto {
  SearchMovieDto({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  int page;
  List<Movie> results;
  int totalPages;
  int totalResults;

  factory SearchMovieDto.fromJson(String str) =>
      SearchMovieDto.fromMap(json.decode(str));

  factory SearchMovieDto.fromMap(Map<String, dynamic> json) => SearchMovieDto(
        page: json["page"],
        results: List<Movie>.from(json["results"].map((x) => Movie.fromMap(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );
}
