import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/type_chip.dart';
import '../utils/pokemon_colors.dart';
import 'edit_pokemon_screen.dart';

class PokemonDetailScreen extends StatefulWidget {
  final int? pokemonId;
  final Pokemon? pokemon;

  const PokemonDetailScreen({
    super.key,
    this.pokemonId,
    this.pokemon,
  });

  @override
  State<PokemonDetailScreen> createState() => _PokemonDetailScreenState();
}

class _PokemonDetailScreenState extends State<PokemonDetailScreen> {
  Pokemon? _pokemon;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadPokemon();
  }

  Future<void> _loadPokemon() async {
    if (widget.pokemon != null) {
      setState(() {
        _pokemon = widget.pokemon;
        _isLoading = false;
      });
      return;
    }

    if (widget.pokemonId != null) {
      try {
        final provider = Provider.of<PokemonProvider>(context, listen: false);
        final pokemon = await provider.getPokemonDetails(widget.pokemonId!);
        setState(() {
          _pokemon = pokemon;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carregando...'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Erro'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPokemon,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_pokemon == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Pokémon não encontrado'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Pokémon não encontrado'),
        ),
      );
    }

    final pokemon = _pokemon!;
    final primaryColor = PokemonColors.getTypeColor(pokemon.types.first);

    return Scaffold(
      appBar: AppBar(
        title: Text(pokemon.name.toUpperCase()),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        actions: [
          if (pokemon.isFavorite)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPokemonScreen(pokemon: pokemon),
                  ),
                );
                if (result == true) {
                  _loadPokemon();
                }
              },
            ),
          IconButton(
            icon: Icon(
              pokemon.isFavorite ? Icons.favorite : Icons.favorite_border,
            ),
            onPressed: () async {
              final provider =
                  Provider.of<PokemonProvider>(context, listen: false);

              // Verificar o estado atual antes de alterar
              final wasFavorite = pokemon.isFavorite;

              await provider.toggleFavorite(pokemon);

              // Atualizar o estado local imediatamente
              setState(() {
                pokemon.isFavorite = !wasFavorite;
              });

              // Mostrar mensagem de feedback baseada no estado anterior
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(!wasFavorite
                      ? '${pokemon.name.toUpperCase()} adicionado aos favoritos!'
                      : '${pokemon.name.toUpperCase()} removido dos favoritos!'),
                  duration: const Duration(seconds: 2),
                  backgroundColor: !wasFavorite ? Colors.green : Colors.orange,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primaryColor, primaryColor.withValues(alpha: 0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Hero(
                    tag: 'pokemon-${pokemon.id}',
                    child: CachedNetworkImage(
                      imageUrl: pokemon.imageUrl,
                      height: 200,
                      placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.catching_pokemon,
                        size: 200,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '#${pokemon.id.toString().padLeft(3, '0')}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    pokemon.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    children: pokemon.types
                        .map((type) => TypeChip(type: type))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection(
                    'Informações Básicas',
                    [
                      _buildInfoRow('Altura', '${pokemon.height / 10} m'),
                      _buildInfoRow('Peso', '${pokemon.weight / 10} kg'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoSection(
                    'Habilidades',
                    pokemon.abilities
                        .map((ability) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '• ${ability.replaceAll('-', ' ').toUpperCase()}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 24),
                  _buildStatsSection(pokemon.stats),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(Map<String, int> stats) {
    final statNames = {
      'hp': 'HP',
      'attack': 'Ataque',
      'defense': 'Defesa',
      'special-attack': 'Atq. Esp.',
      'special-defense': 'Def. Esp.',
      'speed': 'Velocidade',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Estatísticas',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...stats.entries.map((entry) {
          final statName = statNames[entry.key] ?? entry.key;
          final statValue = entry.value;
          final percentage = (statValue / 255).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      statValue.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: percentage,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    PokemonColors.getTypeColor(_pokemon!.types.first),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
