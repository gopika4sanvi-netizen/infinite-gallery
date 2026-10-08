import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:infinite_image_gallery_app/bloc/download/download_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_event.dart';
import 'package:infinite_image_gallery_app/bloc/gallery/gallery_event.dart';
import 'package:infinite_image_gallery_app/data/dataSources/favorites_local_ds.dart';
import 'package:infinite_image_gallery_app/data/dataSources/pixabay_remote_ds.dart';
import 'package:infinite_image_gallery_app/presentation/screens/home_screen.dart';
import 'data/repository/image_repository.dart';
import 'bloc/gallery/gallery_bloc.dart';
import 'bloc/favourites/favourite_bloc.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final repository = ImageRepository(
    remote: PixabayRemoteDataSource(http.Client()),
    local: FavoritesLocalDataSource(),
  );

  runApp(GalleryApp(repository: repository));
}

class GalleryApp extends StatelessWidget {
  final ImageRepository repository;
  const GalleryApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => GalleryBloc(repository)..add(GalleryStarted()),
        ),
        BlocProvider(
          create: (_) => FavoritesBloc(repository)..add(FavoritesLoaded()),
        ),
        BlocProvider(create: (_) => DownloadBloc()),
      ],
      child: MaterialApp(
        title: 'Infinite Gallery',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
