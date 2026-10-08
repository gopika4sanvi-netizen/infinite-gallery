import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/download/download_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/download/download_event.dart';
import 'package:infinite_image_gallery_app/bloc/download/download_state.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_bloc.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_event.dart';
import 'package:infinite_image_gallery_app/bloc/favourites/favourite_state.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/image_model.dart';

class DetailScreen extends StatelessWidget {
  final ImageModel image;
  const DetailScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, state) {
              final isFav = state.isFavorite(image.id);
              return IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.redAccent : null,
                ),
                onPressed: () {
                  context.read<FavoritesBloc>().add(FavoritesToggled(image));
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share('Check out this image: ${image.fullUrl}');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: InteractiveViewer(
              child: Hero(
                tag: 'img_${image.id}',
                child: CachedNetworkImage(
                  imageUrl: image.largeUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  placeholder: (_, __) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (_, __, ___) =>
                      const Icon(Icons.broken_image_outlined, size: 64),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    image.description,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'By ${image.user}  ·  ❤ ${image.likes}  ·  ⬇ ${image.downloads}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  BlocConsumer<DownloadBloc, DownloadState>(
                    listener: (context, state) {
                      if (state.status == DownloadStatus.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.message ?? 'Downloaded'),
                          ),
                        );
                      } else if (state.status == DownloadStatus.failure) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.message ?? 'Failed')),
                        );
                      }
                    },
                    builder: (context, state) {
                      final downloading =
                          state.status == DownloadStatus.downloading;
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: downloading
                              ? null
                              : () => context.read<DownloadBloc>().add(
                                  DownloadRequested(image),
                                ),
                          icon: downloading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: state.progress == 0
                                        ? null
                                        : state.progress,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.download),
                          label: Text(
                            downloading
                                ? 'Downloading ${(state.progress * 100).toStringAsFixed(0)}%'
                                : 'Download',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
