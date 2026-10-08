import 'package:equatable/equatable.dart';

abstract class GalleryEvent extends Equatable {
  const GalleryEvent();
  @override
  List<Object?> get props => [];
}

class GalleryStarted extends GalleryEvent {}

class GalleryLoadMore extends GalleryEvent {}

class GalleryRefresh extends GalleryEvent {}

class GallerySearchChanged extends GalleryEvent {
  final String query;
  const GallerySearchChanged(this.query);
  @override
  List<Object?> get props => [query];
}
