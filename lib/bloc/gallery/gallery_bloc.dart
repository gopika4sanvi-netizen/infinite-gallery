import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_image_gallery_app/data/repository/image_repository.dart';
import 'gallery_event.dart';
import 'gallery_state.dart';

class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {
  final ImageRepository repository;

  GalleryBloc(this.repository) : super(const GalleryState()) {
    on<GalleryStarted>(_onStarted);
    on<GalleryLoadMore>(_onLoadMore);
    on<GalleryRefresh>(_onRefresh);
    on<GallerySearchChanged>(_onSearchChanged);
  }

  Future<void> _onStarted(
    GalleryStarted event,
    Emitter<GalleryState> emit,
  ) async {
    await _load(emit, page: 1, reset: true);
  }

  Future<void> _onLoadMore(
    GalleryLoadMore event,
    Emitter<GalleryState> emit,
  ) async {
    if (!state.hasMore ||
        state.status == GalleryStatus.loading ||
        state.status == GalleryStatus.loadingMore) {
      return;
    }
    await _load(emit, page: state.page + 1, reset: false);
  }

  Future<void> _onRefresh(
    GalleryRefresh event,
    Emitter<GalleryState> emit,
  ) async {
    await _load(emit, page: 1, reset: true);
  }

  Future<void> _onSearchChanged(
    GallerySearchChanged event,
    Emitter<GalleryState> emit,
  ) async {
    emit(
      state.copyWith(query: event.query, images: [], page: 0, hasMore: true),
    );
    await _load(emit, page: 1, reset: true);
  }

  Future<void> _load(
    Emitter<GalleryState> emit, {
    required int page,
    required bool reset,
  }) async {
    if (reset) {
      emit(state.copyWith(status: GalleryStatus.loading, error: null));
    } else {
      emit(state.copyWith(status: GalleryStatus.loadingMore));
    }

    try {
      final images = await repository.fetchImages(
        page: page,
        query: state.query,
      );
      emit(
        state.copyWith(
          images: reset ? images : [...state.images, ...images],
          status: GalleryStatus.success,
          page: page,
          hasMore: images.length >= 20,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: GalleryStatus.failure, error: e.toString()));
    }
  }
}
