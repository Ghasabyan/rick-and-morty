import 'package:flutter/material.dart';
import 'package:rick_and_morty/app.dart';
import 'package:rick_and_morty/core/di/injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.initDependencies();
  runApp(const RickAndMortyApp());
}
