import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery_app/bloc/gallery/gallery_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/gallery/gallery_event.dart';
import 'package:infinite_image_gallery_app/bloc/gallery/gallery_state.dart';
import 'package:infinite_image_gallery_app/data/models/image_model.dart';
import 'package:infinite_image_gallery_app/data/repository/image_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockImageRepository extends Mock implements ImageRepository {}

void main() {
  late MockImageRepository repository;

  const sampleImage = ImageModel(
    id: 1,
    previewUrl: 'https://example.com/preview.jpg',
    largeUrl: 'https://example.com/large.jpg',
    fullUrl: 'https://example.com/full.jpg',
    tags: 'nature, sky',
    user: 'tester',
    likes: 10,
    downloads: 5,
    width: 100,
    height: 150,
  );

  setUp(() {
    repository = MockImageRepository();
  });

  group('GalleryBloc', () {
    blocTest<GalleryBloc, GalleryState>(
      'emits [loading, success] when GalleryStarted succeeds',
      build: () {
        when(
          () => repository.fetchImages(
            page: any(named: 'page'),
            query: any(named: 'query'),
          ),
        ).thenAnswer((_) async => [sampleImage]);
        return GalleryBloc(repository);
      },
      act: (bloc) => bloc.add(GalleryStarted()),
      expect: () => [
        isA<GalleryState>().having(
          (s) => s.status,
          'status',
          GalleryStatus.loading,
        ),
        isA<GalleryState>()
            .having((s) => s.status, 'status', GalleryStatus.success)
            .having((s) => s.images.length, 'images length', 1)
            .having((s) => s.page, 'page', 1),
      ],
      verify: (_) {
        verify(() => repository.fetchImages(page: 1, query: '')).called(1);
      },
    );

    blocTest<GalleryBloc, GalleryState>(
      'emits [loading, failure] when fetch throws',
      build: () {
        when(
          () => repository.fetchImages(
            page: any(named: 'page'),
            query: any(named: 'query'),
          ),
        ).thenThrow(Exception('Network error'));
        return GalleryBloc(repository);
      },
      act: (bloc) => bloc.add(GalleryStarted()),
      expect: () => [
        isA<GalleryState>().having(
          (s) => s.status,
          'status',
          GalleryStatus.loading,
        ),
        isA<GalleryState>()
            .having((s) => s.status, 'status', GalleryStatus.failure)
            .having((s) => s.error, 'error', isNotNull),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'appends images on GalleryLoadMore',
      build: () {
        when(
          () => repository.fetchImages(
            page: any(named: 'page'),
            query: any(named: 'query'),
          ),
        ).thenAnswer((_) async => [sampleImage]);
        return GalleryBloc(repository);
      },
      seed: () => const GalleryState(
        images: [],
        status: GalleryStatus.success,
        page: 1,
        hasMore: true,
      ),
      act: (bloc) => bloc.add(GalleryLoadMore()),
      expect: () => [
        isA<GalleryState>().having(
          (s) => s.status,
          'status',
          GalleryStatus.loadingMore,
        ),
        isA<GalleryState>()
            .having((s) => s.status, 'status', GalleryStatus.success)
            .having((s) => s.page, 'page', 2)
            .having((s) => s.images.length, 'images length', 1),
      ],
    );

    blocTest<GalleryBloc, GalleryState>(
      'resets list and loads page 1 on GallerySearchChanged',
      build: () {
        when(
          () => repository.fetchImages(
            page: any(named: 'page'),
            query: any(named: 'query'),
          ),
        ).thenAnswer((_) async => [sampleImage]);
        return GalleryBloc(repository);
      },
      seed: () => const GalleryState(
        images: [],
        status: GalleryStatus.success,
        page: 3,
      ),
      act: (bloc) => bloc.add(const GallerySearchChanged('cats')),
      expect: () => [
        isA<GalleryState>()
            .having((s) => s.query, 'query', 'cats')
            .having((s) => s.images, 'images', isEmpty)
            .having((s) => s.page, 'page', 0),
        isA<GalleryState>().having(
          (s) => s.status,
          'status',
          GalleryStatus.loading,
        ),
        isA<GalleryState>()
            .having((s) => s.status, 'status', GalleryStatus.success)
            .having((s) => s.page, 'page', 1),
      ],
      verify: (_) {
        verify(() => repository.fetchImages(page: 1, query: 'cats')).called(1);
      },
    );
  });
}
