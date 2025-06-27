import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/pokemon.dart';
import '../providers/pokemon_provider.dart';
import '../widgets/type_chip.dart';
import '../utils/pokemon_colors.dart';

class EditPokemonScreen extends StatefulWidget {
  final Pokemon pokemon;

  const EditPokemonScreen({super.key, required this.pokemon});

  @override
  State<EditPokemonScreen> createState() => _EditPokemonScreenState();
}

class _EditPokemonScreenState extends State<EditPokemonScreen> {
  late TextEditingController _nameController;
  late TextEditingController _heightController;
  late TextEditingController _weightController;
  late List<String> _types;
  late List<String> _abilities;
  late Map<String, int> _stats;

  final List<String> _availableTypes = [
    'normal',
    'fire',
    'water',
    'electric',
    'grass',
    'ice',
    'fighting',
    'poison',
    'ground',
    'flying',
    'psychic',
    'bug',
    'rock',
    'ghost',
    'dragon',
    'dark',
    'steel',
    'fairy'
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pokemon.name);
    _heightController =
        TextEditingController(text: widget.pokemon.height.toString());
    _weightController =
        TextEditingController(text: widget.pokemon.weight.toString());
    _types = List.from(widget.pokemon.types);
    _abilities = List.from(widget.pokemon.abilities);
    _stats = Map.from(widget.pokemon.stats);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar ${widget.pokemon.name.toUpperCase()}'),
        backgroundColor: PokemonColors.getTypeColor(widget.pokemon.types.first),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _savePokemon,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: widget.pokemon.imageUrl,
                height: 150,
                placeholder: (context, url) =>
                    const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(
                  Icons.catching_pokemon,
                  size: 150,
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _nameController,
              label: 'Nome',
              icon: Icons.pets,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _heightController,
                    label: 'Altura',
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _weightController,
                    label: 'Peso',
                    icon: Icons.fitness_center,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildTypesSection(),
            const SizedBox(height: 24),
            _buildAbilitiesSection(),
            const SizedBox(height: 24),
            _buildStatsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _types.map((type) => TypeChip(type: type)).toList(),
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: _showTypeSelector,
          icon: const Icon(Icons.add),
          label: const Text('Modificar Tipos'),
        ),
      ],
    );
  }

  Widget _buildAbilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Habilidades',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ElevatedButton.icon(
              onPressed: _addAbility,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._abilities.asMap().entries.map((entry) {
          final index = entry.key;
          final ability = entry.value;
          return Card(
            child: ListTile(
              title: Text(ability.replaceAll('-', ' ').toUpperCase()),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeAbility(index),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsSection() {
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._stats.entries.map((entry) {
          final statKey = entry.key;
          final statName = statNames[statKey] ?? statKey;
          final statValue = entry.value;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    statName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Slider(
                    value: statValue.toDouble(),
                    min: 1,
                    max: 255,
                    divisions: 254,
                    label: statValue.toString(),
                    onChanged: (value) {
                      setState(() {
                        _stats[statKey] = value.round();
                      });
                    },
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    statValue.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showTypeSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Selecionar Tipos'),
        content: SizedBox(
          width: double.maxFinite,
          child: StatefulBuilder(
            builder: (context, setState) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: _availableTypes.length,
                itemBuilder: (context, index) {
                  final type = _availableTypes[index];
                  final isSelected = _types.contains(type);

                  return CheckboxListTile(
                    title: Text(type.toUpperCase()),
                    value: isSelected,
                    onChanged: _types.length >= 2 && !isSelected
                        ? null
                        : (value) {
                            setState(() {
                              if (value == true) {
                                if (_types.length < 2) {
                                  _types.add(type);
                                }
                              } else {
                                _types.remove(type);
                              }
                            });
                          },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {});
              Navigator.pop(context);
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _addAbility() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Adicionar Habilidade'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Nome da habilidade',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _abilities.add(controller.text.trim().toLowerCase());
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _removeAbility(int index) {
    setState(() {
      _abilities.removeAt(index);
    });
  }

  void _savePokemon() async {
    if (_nameController.text.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nome não pode estar vazio')),
      );
      return;
    }

    if (_types.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pokémon deve ter pelo menos um tipo')),
      );
      return;
    }

    try {
      final updatedPokemon = Pokemon(
        id: widget.pokemon.id,
        name: _nameController.text.trim().toLowerCase(),
        imageUrl: widget.pokemon.imageUrl,
        types: _types,
        height: int.tryParse(_heightController.text) ?? widget.pokemon.height,
        weight: int.tryParse(_weightController.text) ?? widget.pokemon.weight,
        abilities: _abilities,
        stats: _stats,
        isFavorite: true,
      );

      await Provider.of<PokemonProvider>(context, listen: false)
          .updateFavoritePokemon(updatedPokemon);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pokémon atualizado com sucesso!')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar alterações')),
      );
    }
  }
}
