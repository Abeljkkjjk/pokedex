# 🎮 Pokedex Flutter

Trabalho de APP Mobile com tema de Pokédex desenvolvida em Flutter que consome a [PokeAPI](https://pokeapi.co/) para exibir informações detalhadas sobre Pokémon.

## ✨ Funcionalidades

- **Lista de Pokémon**: Visualização em grid com paginação infinita
- **Detalhes do Pokémon**: Informações completas incluindo stats, habilidades e tipos
- **Sistema de Favoritos**: Adicione e gerencie seus Pokémon favoritos
- **Edição de Pokémon**: Modifique informações dos seus favoritos
- **Busca**: Encontre Pokémon pelo nome
- **Interface Responsiva**: Funciona em web e mobile
- **Persistência Local**: Dados salvos localmente

## 🛠️ Tecnologias Utilizadas

- **Flutter** - Framework de desenvolvimento
- **Provider** - Gerenciamento de estado
- **HTTP** - Requisições à API
- **SQLite/SharedPreferences** - Armazenamento local
- **Cached Network Image** - Cache de imagens

## 🎯 Estrutura do Projeto


lib/
├── main.dart                 # Ponto de entrada da aplicação
├── models/                   # Modelos de dados
│   ├── pokemon.dart         # Modelo do Pokémon
│   └── pokemon_list_item.dart # Modelo da lista
├── screens/                  # Telas da aplicação
│   ├── home_screen.dart     # Tela principal com navegação
│   ├── pokemon_list_screen.dart # Lista de Pokémon
│   ├── pokemon_detail_screen.dart # Detalhes do Pokémon
│   ├── favorites_screen.dart # Favoritos
│   └── edit_pokemon_screen.dart # Edição de Pokémon
├── widgets/                  # Widgets reutilizáveis
│   ├── pokemon_card.dart    # Card do Pokémon
│   └── type_chip.dart       # Chip de tipo
├── providers/               # Gerenciamento de estado
│   └── pokemon_provider.dart # Provider principal
├── services/                # Serviços externos
│   └── pokemon_api.dart     # API do Pokémon
├── database/                # Banco de dados
│   └── database_helper.dart # Helper do banco
└── utils/                   # Utilitários
    └── pokemon_colors.dart  # Cores dos tipos


## 📊 API Utilizada

Este projeto utiliza a [PokeAPI](https://pokeapi.co/), uma API RESTful gratuita que fornece dados completos sobre Pokémon.
