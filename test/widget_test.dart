import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/download/download_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/gallery/gallery_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/gallery/gallery_event.dart';
import 'package:infinite_image_gallery_app/data/models/image_model.dart';
import 'package:infinite_image_gallery_app/data/repository/image_repository.dart';
import 'package:infinite_image_gallery_app/presentation/screens/home_screen.dart';
import 'package:mocktail/mocktail.dart';

class MockImageRepository extends Mock implements ImageRepository {}

void main() {
  late MockImageRepository repository;

  const sampleImage = ImageModel(
    id: 1,
    previewUrl: 'https://example.com/p.jpg',
    largeUrl: 'https://example.com/l.jpg',
    fullUrl: 'https://example.com/f.jpg',
    tags: 'nature',
    user: 'tester',
    likes: 0,
    downloads: 0,
    width: 200,
    height: 200,
  );

  setUp(() {
    repository = MockImageRepository();
    when(() => repository.loadFavorites()).thenAnswer((_) async => []);
  });

  testWidgets('HomeScreen shows loading indicator initially', (tester) async {
    when(
      () => repository.fetchImages(
        page: any(named: 'page'),
        query: any(named: 'query'),
      ),
    ).thenAnswer((_) async => [sampleImage]);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => GalleryBloc(repository)..add(GalleryStarted()),
          ),
          BlocProvider(create: (_) => FavoritesBloc(repository)),
          BlocProvider(create: (_) => DownloadBloc()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );

    // Initial frame — loading state
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Let the fake future resolve
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Loading gone after success
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
