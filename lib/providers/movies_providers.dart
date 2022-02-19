import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movies_app/helpers/debouncer.dart';
import 'package:movies_app/models/credits_dto.dart';
import 'package:movies_app/models/movie.dart';

import 'package:movies_app/models/now_playing_dto.dart';
import 'package:movies_app/models/popular_movies_dto.dart';
import 'package:movies_app/models/search_movies_dto.dart';

class MoviesProvider extends ChangeNotifier {
  final String _baseUrl = 'api.themoviedb.org';
  final String _apikey = 'ffaffab25f16adb8baba6b35707a5098';
  final String _language = 'en-EN';

  MoviesProvider() {
    getOnDisplayMovies();
    getPopularMovies();
  }

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  Map<int, List<Cast>> moviesCast = {};

  int _popularPage = 0;

  final debouncer = Debouncer(duration: const Duration(milliseconds: 500));

  final StreamController<List<Movie>> _suggestionStreamController =
      StreamController.broadcast();

  Stream<List<Movie>> get suggestionStream =>
      _suggestionStreamController.stream;

  Future<String> _getJsonData(String endpoint, [int page = 1]) async {
    final url = Uri.https(_baseUrl, endpoint,
        {'api_key': _apikey, "language": _language, "page": "$page"});
    final response = await http.get(url);
    return response.body;
  }

  getOnDisplayMovies() async {
    final jsonData = await _getJsonData('3/movie/now_playing');
    final nowPlaying = NowPlayingDto.fromJson(jsonData);
    onDisplayMovies = nowPlaying.results;
    notifyListeners();
  }

  getPopularMovies() async {
    _popularPage++;
    final jsonData = await _getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularMovies.fromJson(jsonData);
    popularMovies = [...popularMovies, ...popularResponse.results];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;
    final jsonData =
        await _getJsonData('3/movie/$movieId/credits', _popularPage);
    final creditResponse = CreditsDto.fromJson(jsonData);
    moviesCast[movieId] = creditResponse.cast;

    return creditResponse.cast;
  }

  Future<List<Movie>> searchMovie(String query) async {
    final url = Uri.https(_baseUrl, "3/search/movie",
        {'api_key': _apikey, "language": _language, "query": query});
    final response = await http.get(url);
    final results = SearchMovieDto.fromJson(response.body);
    return results.results;
  }

  void getSuggestionByQuery(String query) {
    debouncer.value = "";
    debouncer.onValue = (value) async {
      final results = await searchMovie(value);
      _suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      debouncer.value = query;
    });

    Future.delayed(const Duration(milliseconds: 301)).then((_) => timer.cancel());

  }
}
