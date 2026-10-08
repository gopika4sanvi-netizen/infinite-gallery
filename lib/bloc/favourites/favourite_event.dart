import 'package:equatable/equatable.dart';
import '../../data/models/image_model.dart';

abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();
  @override
  List<Object?> get props => [];
}

class FavoritesLoaded extends FavoritesEvent {}

class FavoritesToggled extends FavoritesEvent {
  final ImageModel image;
  const FavoritesToggled(this.image);
  @override
  List<Object?> get props => [image];
}
