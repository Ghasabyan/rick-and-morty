import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rick_and_morty/core/constants.dart';
import 'package:rick_and_morty/core/network/network_info.dart';
import 'package:rick_and_morty/features/characters/data/datasources/local/characters_local_datasource.dart';
import 'package:rick_and_morty/features/characters/data/datasources/remote/characters_remote_datasource.dart';
import 'package:rick_and_morty/features/characters/data/repositories/character_repository_impl.dart';
import 'package:rick_and_morty/features/characters/domain/repositories/character_repository.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/get_characters_usecase.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/get_favorites_usecase.dart';
import 'package:rick_and_morty/features/characters/domain/usecases/toggle_favorite_usecase.dart';
import 'package:rick_and_morty/features/characters/presentation/providers/characters_provider.dart';
import 'package:rick_and_morty/features/characters/presentation/providers/favorites_provider.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)),
  );

  sl.registerLazySingleton<Connectivity>(() => Connectivity());

  // Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl<Connectivity>()),
  );

  // Data Sources
  sl.registerLazySingleton<CharactersRemoteDatasource>(
    () => CharactersRemoteDatasourceImpl(sl<Dio>()),
  );
  sl.registerLazySingleton<CharactersLocalDatasource>(
    () => CharactersLocalDatasourceImpl(sl<SharedPreferences>()),
  );

  // Repository
  sl.registerLazySingleton<CharacterRepository>(
    () => CharacterRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCharactersUseCase(sl()));
  sl.registerLazySingleton(() => GetFavoritesUseCase(sl()));
  sl.registerLazySingleton(() => ToggleFavoriteUseCase(sl()));

  // Providers
  sl.registerFactory(
    () => CharactersProvider(
      getCharactersUseCase: sl(),
      toggleFavoriteUseCase: sl(),
      getFavoritesUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => FavoritesProvider(
      getFavoritesUseCase: sl(),
      toggleFavoriteUseCase: sl(),
    ),
  );
}
