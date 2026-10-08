import 'package:equatable/equatable.dart';

enum DownloadStatus { idle, downloading, success, failure }

class DownloadState extends Equatable {
  final DownloadStatus status;
  final double progress;
  final String? message;

  const DownloadState({
    this.status = DownloadStatus.idle,
    this.progress = 0,
    this.message,
  });

  @override
  List<Object?> get props => [status, progress, message];
}
