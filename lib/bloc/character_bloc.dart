import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

part 'character_event.dart';
part 'character_state.dart';

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
          document: gql(
            """
            query {
              characters(page: 1) {
                results {
                  name
                  image
                }
              }
            }
            """,
          ),
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
