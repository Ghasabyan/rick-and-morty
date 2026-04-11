import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rick_and_morty/core/di/injection_container.dart';
import 'package:rick_and_morty/core/theme/app_theme.dart';
import 'package:rick_and_morty/features/characters/presentation/pages/characters_page.dart';
import 'package:rick_and_morty/features/characters/presentation/pages/favorites_page.dart';
import 'package:rick_and_morty/features/characters/presentation/providers/characters_provider.dart';
import 'package:rick_and_morty/features/characters/presentation/providers/favorites_provider.dart';

class RickAndMortyApp extends StatefulWidget {
  const RickAndMortyApp({super.key});

  @override
  State<RickAndMortyApp> createState() => _RickAndMortyAppState();
}

class _RickAndMortyAppState extends State<RickAndMortyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<CharactersProvider>()),
        ChangeNotifierProvider(create: (_) => sl<FavoritesProvider>()),
      ],
      child: MaterialApp(
        title: 'Rick & Morty',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,
        debugShowCheckedModeBanner: false,
        home: _MainScreen(
          onToggleTheme: _toggleTheme,
          themeMode: _themeMode,
        ),
      ),
    );
  }
}

class _MainScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const _MainScreen({
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  State<_MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<_MainScreen> {
  int _currentIndex = 0;

  static const _pages = [CharactersPage(), FavoritesPage()];
  static const _titles = ['Characters', 'Favorites'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
          if (index == 1) {
            context.read<FavoritesProvider>().loadFavorites();
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Characters',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_border),
            activeIcon: Icon(Icons.star),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
