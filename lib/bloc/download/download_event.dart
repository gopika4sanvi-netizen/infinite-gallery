import 'package:equatable/equatable.dart';
import '../../data/models/image_model.dart';

abstract class DownloadEvent extends Equatable {
  const DownloadEvent();
  @override
  List<Object?> get props => [];
}

class DownloadRequested extends DownloadEvent {
  final ImageModel image;
  const DownloadRequested(this.image);
  @override
  List<Object?> get props => [image];
}

class DownloadReset extends DownloadEvent {}
