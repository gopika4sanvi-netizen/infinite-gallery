import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants.dart';
import '../../core/errors.dart';
import '../models/image_model.dart';

class PixabayRemoteDataSource {
  final http.Client client;
  PixabayRemoteDataSource(this.client);

  // Future<List<ImageModel>> fetchImages({
  //   required int page,
  //   String query = '',
  // }) async {
  //   final uri = Uri.parse(AppConstants.baseUrl).replace(
  //     queryParameters: {
  //       'key': AppConstants.pixabayApiKey,
  //       'page': '$page',
  //       'per_page': '${AppConstants.pageSize}',
  //       'image_type': 'photo',
  //       'safesearch': 'true',
  //       if (query.isNotEmpty) 'q': query,
  //     },
  //   );

  //   final res = await client.get(uri);
  //   if (res.statusCode != 200) {
  //     throw Failure('Failed to load images (${res.statusCode})');
  //   }
  //   final body = jsonDecode(res.body) as Map<String, dynamic>;
  //   final hits = body['hits'] as List<dynamic>;
  //   return hits
  //       .map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
  //       .toList();
  // }

  Future<List<ImageModel>> fetchImages({
    required int page,
    String query = '',
    String category = '',
  }) async {
    final uri = Uri.parse(AppConstants.baseUrl).replace(
      queryParameters: {
        'key': AppConstants.pixabayApiKey,
        'page': '$page',
        'per_page': '${AppConstants.pageSize}',
        'image_type': 'photo',
        'safesearch': 'true',
        if (query.isNotEmpty) 'q': query,
        if (category.isNotEmpty) 'category': category,
      },
    );

    final res = await client.get(uri);
    if (res.statusCode == 400) {
      throw Failure(
        'Bad Request (400). Check your API key or request parameters.',
      );
    }
    if (res.statusCode != 200) {
      throw Failure('Failed to load images (${res.statusCode})');
    }
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final hits = body['hits'] as List<dynamic>;
    return hits
        .map((e) => ImageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
