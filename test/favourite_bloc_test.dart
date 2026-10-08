import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_event.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_state.dart';
import 'package:infinite_image_gallery_app/data/models/image_model.dart';
import 'package:infinite_image_gallery_app/data/repository/image_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockImageRepository extends Mock implements ImageRepository {}

void main() {
  late MockImageRepository repository;

  const sampleImage = ImageModel(
    id: 1,
    previewUrl: 'p',
    largeUrl: 'l',
    fullUrl: 'f',
    tags: 'a,b',
    user: 'u',
    likes: 0,
    downloads: 0,
    width: 100,
    height: 100,
  );

  setUp(() {
    repository = MockImageRepository();
  });

  group('FavoritesBloc', () {
    blocTest<FavoritesBloc, FavoritesState>(
      'loads favorites from repository',
      build: () {
        when(
          () => repository.loadFavorites(),
        ).thenAnswer((_) async => [sampleImage]);
        return FavoritesBloc(repository);
      },
      act: (bloc) => bloc.add(FavoritesLoaded()),
      expect: () => [
        isA<FavoritesState>().having(
          (s) => s.favorites.length,
          'favorites length',
          1,
        ),
      ],
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'adds image on FavoritesToggled when not present',
      build: () {
        when(() => repository.saveFavorites(any())).thenAnswer((_) async {});
        return FavoritesBloc(repository);
      },
      act: (bloc) => bloc.add(const FavoritesToggled(sampleImage)),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.favorites.length, 'favorites length', 1)
            .having((s) => s.isFavorite(1), 'isFavorite', true),
      ],
      verify: (_) {
        verify(() => repository.saveFavorites(any())).called(1);
      },
    );

    blocTest<FavoritesBloc, FavoritesState>(
      'removes image on FavoritesToggled when already present',
      build: () {
        when(() => repository.saveFavorites(any())).thenAnswer((_) async {});
        return FavoritesBloc(repository);
      },
      seed: () => const FavoritesState(favorites: [sampleImage]),
      act: (bloc) => bloc.add(const FavoritesToggled(sampleImage)),
      expect: () => [
        isA<FavoritesState>()
            .having((s) => s.favorites, 'favorites', isEmpty)
            .having((s) => s.isFavorite(1), 'isFavorite', false),
      ],
    );
  });
}
