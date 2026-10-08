import 'package:infinite_image_gallery_app/data/dataSources/favorites_local_ds.dart';
import 'package:infinite_image_gallery_app/data/dataSources/pixabay_remote_ds.dart';
import '../models/image_model.dart';

class ImageRepository {
  final PixabayRemoteDataSource remote;
  final FavoritesLocalDataSource local;

  ImageRepository({required this.remote, required this.local});

  // Future<List<ImageModel>> fetchImages({required int page, String query = ''}) {
  //   return remote.fetchImages(page: page, query: query);
  // }

  Future<List<ImageModel>> fetchImages({
    required int page,
    String query = '',
    String category = '',
  }) {
    return remote.fetchImages(page: page, query: query, category: category);
  }

  Future<List<ImageModel>> loadFavorites() => local.load();
  Future<void> saveFavorites(List<ImageModel> favorites) =>
      local.save(favorites);
}
