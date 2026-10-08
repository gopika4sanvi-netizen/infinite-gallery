import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_event.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_state.dart';
import 'package:infinite_image_gallery_app/data/repository/image_repository.dart';

class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final ImageRepository repository;

  FavoritesBloc(this.repository) : super(const FavoritesState()) {
    on<FavoritesLoaded>(_onLoad);
    on<FavoritesToggled>(_onToggle);
  }

  Future<void> _onLoad(
    FavoritesLoaded event,
    Emitter<FavoritesState> emit,
  ) async {
    final list = await repository.loadFavorites();
    emit(FavoritesState(favorites: list));
  }

  Future<void> _onToggle(
    FavoritesToggled event,
    Emitter<FavoritesState> emit,
  ) async {
    final current = [...state.favorites];
    final exists = current.any((e) => e.id == event.image.id);
    if (exists) {
      current.removeWhere((e) => e.id == event.image.id);
    } else {
      current.add(event.image);
    }
    await repository.saveFavorites(current);
    emit(FavoritesState(favorites: current));
  }
}
