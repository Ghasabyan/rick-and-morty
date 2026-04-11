import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty/features/characters/presentation/providers/characters_provider.dart';
import 'package:rick_and_morty/features/characters/presentation/providers/favorites_provider.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character_card.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FavoritesProvider>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (context, provider, _) {
        if (provider.status == FavoritesStatus.loading ||
            provider.status == FavoritesStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.status == FavoritesStatus.empty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star_border, size: 72, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No favorites yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the star on a character to add them here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 16),
          itemCount: provider.favorites.length,
          itemBuilder: (context, index) {
            final character = provider.favorites[index];
            return CharacterCard(
              character: character,
              isFavorite: true,
              onFavoriteToggle: () async {
                await provider.removeFromFavorites(character);
                if (context.mounted) {
                  context.read<CharactersProvider>().refreshFavoriteIds();
                }
              },
            );
          },
        );
      },
    );
  }
}
