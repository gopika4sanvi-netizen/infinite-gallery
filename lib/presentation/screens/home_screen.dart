import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_event.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_state.dart';
import 'package:infinite_image_gallery_app/bloc/gallery/gallery_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/gallery/gallery_event.dart';
import 'package:infinite_image_gallery_app/bloc/gallery/gallery_state.dart';
import 'package:infinite_image_gallery_app/presentation/screens/favourite_screen.dart';
import '../widgets/error_view.dart';
import '../widgets/image_card.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 400;
    if (_scrollController.position.pixels >= threshold) {
      context.read<GalleryBloc>().add(GalleryLoadMore());
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<GalleryBloc>().add(GallerySearchChanged(value.trim()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Gallery'),
        actions: [
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              return IconButton(
                icon: Badge(
                  label: Text('${state.favorites.length}'),
                  isLabelVisible: state.favorites.isNotEmpty,
                  child: const Icon(Icons.favorite_outline),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  ).then((_) {
                    if (context.mounted) {
                      context.read<FavoritesBloc>().add(FavoritesLoaded());
                    }
                  });
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Search images...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<GalleryBloc>().add(
                            const GallerySearchChanged(''),
                          );
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<GalleryBloc, GalleryState>(
              builder: (context, state) {
                if (state.status == GalleryStatus.loading &&
                    state.images.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.status == GalleryStatus.failure &&
                    state.images.isEmpty) {
                  return ErrorView(
                    message: state.error ?? 'Something went wrong',
                    onRetry: () =>
                        context.read<GalleryBloc>().add(GalleryStarted()),
                  );
                }

                if (state.images.isEmpty) {
                  return const Center(child: Text('No images found'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<GalleryBloc>().add(GalleryRefresh());
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: MasonryGridView.count(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    itemCount: state.images.length + 1,

                    // itemBuilder: (context, index) {
                    //   if (index >= state.images.length) {
                    //     return Padding(
                    //       padding: const EdgeInsets.symmetric(vertical: 24),
                    //       child: state.hasMore
                    //           ? const Center(child: CircularProgressIndicator())
                    //           : const Center(child: Text('No more images')),
                    //     );
                    //   }
                    //   final img = state.images[index];
                    //   final aspect = img.width > 0 && img.height > 0
                    //       ? img.width / img.height
                    //       : 1.0;
                    //   return GestureDetector(
                    //     onTap: () {
                    //       Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //           builder: (_) => DetailScreen(image: img),
                    //         ),
                    //       );
                    //     },
                    //     child: AspectRatio(
                    //       aspectRatio: aspect.clamp(0.6, 1.6),
                    //       child: ImageCard(image: img, onTap: () {}),
                    //     ),
                    //   );
                    // },
                    itemBuilder: (context, index) {
                      if (index >= state.images.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: state.hasMore
                              ? const Center(child: CircularProgressIndicator())
                              : const Center(child: Text('No more images')),
                        );
                      }

                      final img = state.images[index];
                      final aspect = img.width > 0 && img.height > 0
                          ? img.width / img.height
                          : 1.0;

                      return AspectRatio(
                        aspectRatio: aspect.clamp(0.6, 1.6),
                        child: ImageCard(
                          image: img,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailScreen(image: img),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
