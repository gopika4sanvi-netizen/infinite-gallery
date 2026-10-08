import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants.dart';
import '../models/image_model.dart';

class FavoritesLocalDataSource {
  Future<List<ImageModel>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(AppConstants.favoritesKey) ?? [];
    return raw
        .map((s) => ImageModel.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<ImageModel> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = favorites.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(AppConstants.favoritesKey, raw);
  }
}
