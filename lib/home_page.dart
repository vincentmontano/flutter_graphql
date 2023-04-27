import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_graphql/character_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({
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
            return onCharacterInitial(context);
          } else if (state is CharacterLoading) {
            return const CircularProgressIndicator();
          } else if (state is CharacterLoaded) {
            return onCharacterLoaded(state);
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

  Widget onCharacterLoaded(CharacterLoaded state) {
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
  }

  Widget onCharacterInitial(BuildContext context) {
    return Center(
      child: ElevatedButton(
        child: const Text("Fetch Data"),
        onPressed: () {
          context.read().add(FetchCharacterDataEvent());
        },
      ),
    );
  }
}
