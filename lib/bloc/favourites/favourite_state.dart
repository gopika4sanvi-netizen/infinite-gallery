import 'package:equatable/equatable.dart';
import '../../data/models/image_model.dart';

class FavoritesState extends Equatable {
  final List<ImageModel> favorites;
  const FavoritesState({this.favorites = const []});

  bool isFavorite(int id) => favorites.any((e) => e.id == id);

  FavoritesState copyWith({List<ImageModel>? favorites}) =>
      FavoritesState(favorites: favorites ?? this.favorites);

  @override
  List<Object?> get props => [favorites];
}
