import 'package:flutter/material.dart';
import '../models/pokemon.dart';
import '../models/pokemon_list_item.dart';
import '../services/pokemon_api.dart';
import '../database/database_helper.dart';

class PokemonProvider with ChangeNotifier {
  final List<PokemonListItem> _pokemonList = [];
  List<Pokemon> _favorites = [];
  bool _isLoading = false;
  String _error = '';
  int _currentOffset = 0;
  final int _limit = 20;

  List<PokemonListItem> get pokemonList => _pokemonList;
  List<Pokemon> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadPokemonList({bool refresh = false}) async {
    if (refresh) {
      _currentOffset = 0;
      _pokemonList.clear();
    }

    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final newPokemon = await PokemonApi.getPokemonList(
        limit: _limit,
        offset: _currentOffset,
      );

      _pokemonList.addAll(newPokemon);
      _currentOffset += _limit;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Pokemon> getPokemonDetails(int id) async {
    final pokemon = await PokemonApi.getPokemonById(id);
    pokemon.isFavorite = await DatabaseHelper.instance.isFavorite(id);
    return pokemon;
  }

  Future<void> loadFavorites() async {
    _favorites = await DatabaseHelper.instance.getFavorites();
    notifyListeners();
  }

  Future<void> toggleFavorite(Pokemon pokemon) async {
    if (pokemon.isFavorite) {
      await DatabaseHelper.instance.removeFavorite(pokemon.id);
      pokemon.isFavorite = false;
      _favorites.removeWhere((p) => p.id == pokemon.id);
    } else {
      pokemon.isFavorite = true;
      await DatabaseHelper.instance.insertFavorite(pokemon);
      _favorites.add(pokemon);
    }
    notifyListeners();
  }

  Future<void> updateFavoritePokemon(Pokemon pokemon) async {
    await DatabaseHelper.instance.updateFavorite(pokemon);
    final index = _favorites.indexWhere((p) => p.id == pokemon.id);
    if (index != -1) {
      _favorites[index] = pokemon;
      notifyListeners();
    }
  }

  Future<void> removeFavorite(int pokemonId) async {
    await DatabaseHelper.instance.removeFavorite(pokemonId);
    _favorites.removeWhere((p) => p.id == pokemonId);
    notifyListeners();
  }

  Future<List<Pokemon>> searchPokemon(String query) async {
    return await PokemonApi.searchPokemon(query);
  }
}
