import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_graphql/character_bloc.dart';
import 'package:flutter_graphql/home_page.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

const String title = 'GraphQL Demo';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: BlocProvider(
        create: (context) => CharacterBloc(),
        child: const HomePage(title: title),
      ),
    );
  }
}
