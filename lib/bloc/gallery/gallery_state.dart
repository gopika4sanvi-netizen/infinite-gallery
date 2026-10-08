import 'package:equatable/equatable.dart';
import '../../data/models/image_model.dart';

enum GalleryStatus { initial, loading, loadingMore, success, failure }

class GalleryState extends Equatable {
  final List<ImageModel> images;
  final GalleryStatus status;
  final String query;
  final int page;
  final bool hasMore;
  final String? error;

  const GalleryState({
    this.images = const [],
    this.status = GalleryStatus.initial,
    this.query = '',
    this.page = 0,
    this.hasMore = true,
    this.error,
  });

  GalleryState copyWith({
    List<ImageModel>? images,
    GalleryStatus? status,
    String? query,
    int? page,
    bool? hasMore,
    String? error,
  }) {
    return GalleryState(
      images: images ?? this.images,
      status: status ?? this.status,
      query: query ?? this.query,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }

  @override
  List<Object?> get props => [images, status, query, page, hasMore, error];
}
