import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter(); // for cache
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GraphQL Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlocProvider(
        create: (context) => CharacterBloc(),
        child: const MyHomePage(title: 'GraphQL Demo'),
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: BlocBuilder<CharacterBloc, CharacterState>(
        builder: (context, state) {
          if (state is CharacterInitial) {
            return Center(
              child: ElevatedButton(
                child: const Text("Fetch Data"),
                onPressed: () {
                  BlocProvider.of<CharacterBloc>(context)
                      .add(FetchCharacterDataEvent());
                },
              ),
            );
          } else if (state is CharacterLoading) {
            return const CircularProgressIndicator();
          } else if (state is CharacterLoaded) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                  itemCount: state.characters.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: ListTile(
                        leading: Image(
                          image: NetworkImage(
                            state.characters[index]['image'],
                          ),
                        ),
                        title: Text(
                          state.characters[index]['name'],
                        ),
                      ),
                    );
                  }),
            );
          } else if (state is CharacterError) {
            return Center(
              child: Text(state.errorMessage),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class CharacterBloc extends Bloc<CharacterEvent, CharacterState> {
  CharacterBloc() : super(CharacterInitial()) {
    on<FetchCharacterDataEvent>(_onFetchCharacterDataEvent);
  }

  Future<void> _onFetchCharacterDataEvent(
      FetchCharacterDataEvent event, Emitter<CharacterState> emit) async {
    emit(CharacterLoading());
    try {
      HttpLink link = HttpLink("https://rickandmortyapi.com/graphql");
      GraphQLClient qlClient = GraphQLClient(
        link: link,
        cache: GraphQLCache(
          store: HiveStore(),
        ),
      );
      QueryResult queryResult = await qlClient.query(
        QueryOptions(
          document: gql("""
            query {
              characters(page: 1) {
                results {
                  name
                  image
                }
              }
            }
            """),
        ),
      );

      if (queryResult.hasException) {
        throw Exception(queryResult.exception!.graphqlErrors.toString());
      }

      List<dynamic> characters = queryResult.data!['characters']['results'];

      emit(CharacterLoaded(characters: characters));
    } catch (e) {
      emit(CharacterError(errorMessage: e.toString()));
    }
  }
}

abstract class CharacterEvent {}

class FetchCharacterDataEvent extends CharacterEvent {}

abstract class CharacterState {}

class CharacterInitial extends CharacterState {}

class CharacterLoading extends CharacterState {}

class CharacterLoaded extends CharacterState {
  final List<dynamic> characters;

  CharacterLoaded({required this.characters});
}

class CharacterError extends CharacterState {
  final String errorMessage;

  CharacterError({required this.errorMessage});
}
