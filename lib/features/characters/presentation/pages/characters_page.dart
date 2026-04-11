import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty/features/characters/presentation/providers/characters_provider.dart';
import 'package:rick_and_morty/features/characters/presentation/widgets/character_card.dart';

class CharactersPage extends StatefulWidget {
  const CharactersPage({super.key});

  @override
  State<CharactersPage> createState() => _CharactersPageState();
}

class _CharactersPageState extends State<CharactersPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CharactersProvider>().loadCharacters(refresh: true);
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 300) {
      final provider = context.read<CharactersProvider>();
      if (provider.hasMore && provider.status == CharactersStatus.loaded) {
        provider.loadCharacters();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CharactersProvider>(
      builder: (context, provider, _) {
        if (provider.status == CharactersStatus.initial ||
            provider.status == CharactersStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.status == CharactersStatus.error &&
            provider.characters.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    provider.errorMessage,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () =>
                        provider.loadCharacters(refresh: true),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search characters…',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: provider.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            provider.setSearchQuery('');
                          },
                        )
                      : null,
                  border: const OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  isDense: true,
                ),
                onChanged: provider.setSearchQuery,
              ),
            ),
            _SortBar(
              current: provider.sortOption,
              onChanged: provider.setSortOption,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => provider.loadCharacters(refresh: true),
                child: provider.characters.isEmpty &&
                        provider.searchQuery.isNotEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 64, color: Colors.grey),
                            SizedBox(height: 12),
                            Text('No characters found',
                                style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: provider.characters.length + 1,
                  itemBuilder: (context, index) {
                    if (index == provider.characters.length) {
                      if (provider.status == CharactersStatus.loadingMore) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child:
                              Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (!provider.hasMore) {
                        return const Padding(
                          padding: EdgeInsets.all(20),
                          child: Center(
                              child: Text('All characters loaded')),
                        );
                      }
                      return const SizedBox.shrink();
                    }

                    final character = provider.characters[index];
                    return CharacterCard(
                      character: character,
                      isFavorite: provider.isFavorite(character.id),
                      onFavoriteToggle: () =>
                          provider.toggleFavorite(character),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SortBar extends StatelessWidget {
  final SortOption current;
  final ValueChanged<SortOption> onChanged;

  const _SortBar({required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          const Text('Sort: ', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 8),
          DropdownButton<SortOption>(
            value: current,
            isDense: true,
            items: const [
              DropdownMenuItem(
                  value: SortOption.none, child: Text('Default')),
              DropdownMenuItem(
                  value: SortOption.nameAsc, child: Text('Name A–Z')),
              DropdownMenuItem(
                  value: SortOption.nameDesc, child: Text('Name Z–A')),
              DropdownMenuItem(
                  value: SortOption.statusAlive, child: Text('Alive first')),
              DropdownMenuItem(
                  value: SortOption.statusDead, child: Text('Dead first')),
            ],
            onChanged: (v) => onChanged(v!),
          ),
        ],
      ),
    );
  }
}
