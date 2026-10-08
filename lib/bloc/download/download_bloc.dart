// import 'dart:io';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:path_provider/path_provider.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'download_event.dart';
// import 'download_state.dart';

// class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
//   DownloadBloc() : super(const DownloadState()) {
//     on<DownloadRequested>(_onDownload);
//     on<DownloadReset>((_, emit) => emit(const DownloadState()));
//   }

//   Future<void> _onDownload(
//     DownloadRequested event,
//     Emitter<DownloadState> emit,
//   ) async {
//     emit(const DownloadState(status: DownloadStatus.downloading));

//     try {
//       // Ask for storage permission (Android <13 mainly)
//       if (Platform.isAndroid) {
//         final status = await Permission.storage.request();
//         if (!status.isGranted) {
//           // Android 13+ uses photos permission; try alternative
//           final photos = await Permission.photos.request();
//           if (!photos.isGranted && !status.isGranted) {
//             emit(
//               const DownloadState(
//                 status: DownloadStatus.failure,
//                 message: 'Storage permission denied',
//               ),
//             );
//             return;
//           }
//         }
//       }

//       final client = http.Client();
//       final req = http.Request('GET', Uri.parse(event.image.fullUrl));
//       final res = await client.send(req);

//       final total = res.contentLength ?? 0;
//       var received = 0;

//       final dir = await getApplicationDocumentsDirectory();
//       final downloadsDir = Directory('${dir.path}/gallery_downloads');
//       if (!downloadsDir.existsSync()) downloadsDir.createSync(recursive: true);

//       final file = File(
//         '${downloadsDir.path}/pixabay_${event.image.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
//       );
//       final sink = file.openWrite();

//       await for (final chunk in res.stream) {
//         sink.add(chunk);
//         received += chunk.length;
//         if (total > 0) {
//           emit(
//             DownloadState(
//               status: DownloadStatus.downloading,
//               progress: received / total,
//             ),
//           );
//         }
//       }
//       await sink.close();
//       client.close();

//       emit(
//         DownloadState(
//           status: DownloadStatus.success,
//           progress: 1,
//           message: 'Saved to ${file.path}',
//         ),
//       );
//     } catch (e) {
//       emit(
//         DownloadState(status: DownloadStatus.failure, message: e.toString()),
//       );
//     }
//   }
// }

import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'download_event.dart';
import 'download_state.dart';

// Web-only imports
import 'dart:html' as html;

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  DownloadBloc() : super(const DownloadState()) {
    on<DownloadRequested>(_onDownload);
    on<DownloadReset>((_, emit) => emit(const DownloadState()));
  }

  Future<void> _onDownload(
    DownloadRequested event,
    Emitter<DownloadState> emit,
  ) async {
    emit(const DownloadState(status: DownloadStatus.downloading));

    try {
      if (kIsWeb) {
        // Web: trigger browser download
        final bytes = await _fetchBytes(event.image.fullUrl);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..download = 'pixabay_${event.image.id}.jpg'
          ..click();
        html.Url.revokeObjectUrl(url);

        emit(
          const DownloadState(
            status: DownloadStatus.success,
            progress: 1,
            message: 'Download started in browser',
          ),
        );
        return;
      }

      // Native: existing file-based download
      if (Platform.isAndroid) {
        final status = await Permission.storage.request();
        if (!status.isGranted) {
          final photos = await Permission.photos.request();
          if (!photos.isGranted && !status.isGranted) {
            emit(
              const DownloadState(
                status: DownloadStatus.failure,
                message: 'Storage permission denied',
              ),
            );
            return;
          }
        }
      }

      final client = http.Client();
      final req = http.Request('GET', Uri.parse(event.image.fullUrl));
      final res = await client.send(req);
      final total = res.contentLength ?? 0;
      var received = 0;

      final dir = await getApplicationDocumentsDirectory();
      final downloadsDir = Directory('${dir.path}/gallery_downloads');
      if (!downloadsDir.existsSync()) downloadsDir.createSync(recursive: true);

      final file = File(
        '${downloadsDir.path}/pixabay_${event.image.id}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final sink = file.openWrite();

      await for (final chunk in res.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) {
          emit(
            DownloadState(
              status: DownloadStatus.downloading,
              progress: received / total,
            ),
          );
        }
      }
      await sink.close();
      client.close();

      emit(
        DownloadState(
          status: DownloadStatus.success,
          progress: 1,
          message: 'Saved to ${file.path}',
        ),
      );
    } catch (e) {
      emit(
        DownloadState(status: DownloadStatus.failure, message: e.toString()),
      );
    }
  }

  Future<List<int>> _fetchBytes(String url) async {
    final res = await http.get(Uri.parse(url));
    return res.bodyBytes;
  }
}
