part of 'character_bloc.dart';

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
