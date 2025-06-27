import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';
import '../models/pokemon_list_item.dart';

class PokemonApi {
  static const String baseUrl = 'https://pokeapi.co/api/v2';

  static Future<List<PokemonListItem>> getPokemonList({
    int limit = 20,
    int offset = 0,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pokemon?limit=$limit&offset=$offset'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> results = data['results'];
      return results.map((json) => PokemonListItem.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar lista de Pokémon');
    }
  }

  static Future<Pokemon> getPokemonById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$id'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Pokemon.fromJson(data);
    } else {
      throw Exception('Falha ao carregar Pokémon');
    }
  }

  static Future<Pokemon> getPokemonByName(String name) async {
    final response = await http.get(Uri.parse('$baseUrl/pokemon/$name'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Pokemon.fromJson(data);
    } else {
      throw Exception('Falha ao carregar Pokémon');
    }
  }

  static Future<List<Pokemon>> searchPokemon(String query) async {
    // Para busca simples, vamos buscar por nome
    try {
      final pokemon = await getPokemonByName(query.toLowerCase());
      return [pokemon];
    } catch (e) {
      return [];
    }
  }
}
