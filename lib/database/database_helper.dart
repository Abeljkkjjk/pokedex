import 'dart:async';
import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/pokemon.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static SharedPreferences? _prefs;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    if (kIsWeb) {
      // Para web, inicializar SharedPreferences
      _prefs = await SharedPreferences.getInstance();
      // Retornar um database dummy para web
      return await openDatabase(
        inMemoryDatabasePath,
        version: 1,
        onCreate: _createDB,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'pokedex.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
      );
    }
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        types TEXT NOT NULL,
        height INTEGER NOT NULL,
        weight INTEGER NOT NULL,
        abilities TEXT NOT NULL,
        stats TEXT NOT NULL,
        isFavorite INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE user_settings (
        id INTEGER PRIMARY KEY,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL
      )
    ''');
  }

  Future<void> insertFavorite(Pokemon pokemon) async {
    if (kIsWeb) {
      final favorites = await _getFavoritesFromPrefs();
      favorites.add(pokemon);
      await _saveFavoritesToPrefs(favorites);
    } else {
      final db = await database;
      await db.insert(
        'favorites',
        pokemon.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<void> removeFavorite(int pokemonId) async {
    if (kIsWeb) {
      final favorites = await _getFavoritesFromPrefs();
      favorites.removeWhere((p) => p.id == pokemonId);
      await _saveFavoritesToPrefs(favorites);
    } else {
      final db = await database;
      await db.delete(
        'favorites',
        where: 'id = ?',
        whereArgs: [pokemonId],
      );
    }
  }

  Future<List<Pokemon>> getFavorites() async {
    if (kIsWeb) {
      return await _getFavoritesFromPrefs();
    } else {
      final db = await database;
      final maps = await db.query('favorites');
      return maps.map((map) => Pokemon.fromMap(map)).toList();
    }
  }

  Future<bool> isFavorite(int pokemonId) async {
    if (kIsWeb) {
      final favorites = await _getFavoritesFromPrefs();
      return favorites.any((p) => p.id == pokemonId);
    } else {
      final db = await database;
      final maps = await db.query(
        'favorites',
        where: 'id = ?',
        whereArgs: [pokemonId],
      );
      return maps.isNotEmpty;
    }
  }

  Future<void> updateFavorite(Pokemon pokemon) async {
    if (kIsWeb) {
      final favorites = await _getFavoritesFromPrefs();
      final index = favorites.indexWhere((p) => p.id == pokemon.id);
      if (index != -1) {
        favorites[index] = pokemon;
        await _saveFavoritesToPrefs(favorites);
      }
    } else {
      final db = await database;
      await db.update(
        'favorites',
        pokemon.toMap(),
        where: 'id = ?',
        whereArgs: [pokemon.id],
      );
    }
  }

  Future<void> setSetting(String key, String value) async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(key, value);
    } else {
      final db = await database;
      await db.insert(
        'user_settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  Future<String?> getSetting(String key) async {
    if (kIsWeb) {
      _prefs ??= await SharedPreferences.getInstance();
      return _prefs!.getString(key);
    } else {
      final db = await database;
      final maps = await db.query(
        'user_settings',
        where: 'key = ?',
        whereArgs: [key],
      );
      if (maps.isNotEmpty) {
        return maps.first['value'] as String;
      }
      return null;
    }
  }

  // Métodos auxiliares para web
  Future<List<Pokemon>> _getFavoritesFromPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    final favoritesJson = _prefs!.getStringList('favorites') ?? [];
    return favoritesJson
        .map((json) => Pokemon.fromMap(jsonDecode(json)))
        .toList();
  }

  Future<void> _saveFavoritesToPrefs(List<Pokemon> favorites) async {
    _prefs ??= await SharedPreferences.getInstance();
    final favoritesJson =
        favorites.map((pokemon) => jsonEncode(pokemon.toMap())).toList();
    await _prefs!.setStringList('favorites', favoritesJson);
  }
}
