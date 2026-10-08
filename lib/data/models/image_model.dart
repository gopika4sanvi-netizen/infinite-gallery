import 'package:equatable/equatable.dart';

class ImageModel extends Equatable {
  final int id;
  final String previewUrl;
  final String largeUrl;
  final String fullUrl;
  final String tags;
  final String user;
  final int likes;
  final int downloads;
  final int width;
  final int height;

  const ImageModel({
    required this.id,
    required this.previewUrl,
    required this.largeUrl,
    required this.fullUrl,
    required this.tags,
    required this.user,
    required this.likes,
    required this.downloads,
    required this.width,
    required this.height,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] as int,
      previewUrl: json['previewURL'] as String,
      largeUrl:
          json['largeImageURL'] as String? ?? json['webformatURL'] as String,
      fullUrl:
          json['fullHDURL'] as String? ??
          json['imageURL'] as String? ??
          json['largeImageURL'] as String,
      tags: json['tags'] as String? ?? '',
      user: json['user'] as String? ?? '',
      likes: json['likes'] as int? ?? 0,
      downloads: json['downloads'] as int? ?? 0,
      width: json['imageWidth'] as int? ?? 0,
      height: json['imageHeight'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'previewURL': previewUrl,
    'largeImageURL': largeUrl,
    'fullHDURL': fullUrl,
    'tags': tags,
    'user': user,
    'likes': likes,
    'downloads': downloads,
    'imageWidth': width,
    'imageHeight': height,
  };

  String get description =>
      tags.isEmpty ? 'Image by $user' : tags.replaceAll(', ', ' · ');

  @override
  List<Object?> get props => [id];
}
