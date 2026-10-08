// class AppConstants {
//   static const String pixabayApiKey = 'YOUR_PIXABAY_API_KEY';
//   static const String baseUrl = 'https://pixabay.com/api/';
//   static const int pageSize = 20;
//   static const String favoritesKey = 'favorite_images';
// }

class AppConstants {
  static const String pixabayApiKey =
      '18547591-da54c8241f51c161d61e3dcaa'; // your real key
  static const String baseUrl = 'https://pixabay.com/api/';
  static const int pageSize = 20;
  static const String favoritesKey = 'favorite_images';

  static const List<Map<String, String>> categories = [
    {'label': 'All', 'value': ''},
    {'label': 'Nature', 'value': 'nature'},
    {'label': 'Animals', 'value': 'animals'},
    {'label': 'Buildings', 'value': 'buildings'},
    {'label': 'Food', 'value': 'food'},
    {'label': 'Travel', 'value': 'travel'},
    {'label': 'People', 'value': 'people'},
    {'label': 'Sports', 'value': 'sports'},
    {'label': 'Technology', 'value': 'technology'},
    {'label': 'Music', 'value': 'music'},
    {'label': 'Backgrounds', 'value': 'backgrounds'},
  ];
}
