// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:skeletonizer/skeletonizer.dart';
// import '../../data/models/image_model.dart';

// class ImageCard extends StatelessWidget {
//   final ImageModel image;
//   final VoidCallback onTap;

//   const ImageCard({super.key, required this.image, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Hero(
//         tag: 'img_${image.id}',
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: CachedNetworkImage(
//             imageUrl: image.previewUrl,
//             fit: BoxFit.cover,
//             placeholder: (_, __) => const Skeletonizer(
//               enabled: true,
//               child: ColoredBox(color: Colors.black12),
//             ),
//             errorWidget: (_, __, ___) => const ColoredBox(
//               color: Colors.black12,
//               child: Icon(Icons.broken_image_outlined),
//             ),
//             fadeInDuration: const Duration(milliseconds: 200),
//             memCacheWidth: 400,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/image_model.dart';

class ImageCard extends StatelessWidget {
  final ImageModel image;
  final VoidCallback onTap;

  const ImageCard({super.key, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'img_${image.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: CachedNetworkImage(
            imageUrl: image.previewUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: (_, __) => const ColoredBox(
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            errorWidget: (_, __, ___) => const ColoredBox(
              color: Colors.black12,
              child: Icon(Icons.broken_image_outlined),
            ),
            fadeInDuration: const Duration(milliseconds: 200),
            memCacheWidth: 400,
          ),
        ),
      ),
    );
  }
}
