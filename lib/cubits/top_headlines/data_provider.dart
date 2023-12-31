part of 'cubit.dart';

class NewsDataProvider {
  static final dio = Dio();
  static const apikey = "bdfd25ce2c9b4a9aa53baa63e89a5274";
  
  /// [apiKey] is required, you can get it from newsapi.org
  static final cache = Hive.box('newsBox');
  static final appCache = Hive.box('app');

  static Future<List<News>> fetchApi(String category,String countrycode,String language) async {
    //cache.clear();
   // appCache.clear();
    try {

      final response = await dio.get(
      "https://newsapi.org/v2/top-headlines/sources",// "https://newsapi.org/v2/top-headlines?country=eg&pages=5&category=sports&language=language",// 'https://newsapi.org/v2/top-headlines/sources?category=$category',
        options: Options(
          headers: {
            'Authorization':apikey
          },
        ),
      );

      Map raw = response.data;
      log(raw.toString());

      List newsList = raw['sources'];
     // List newsList = raw['articles'];

      List<News> news = List.generate(
        newsList.length,
        (index) => News.fromMap(
          newsList[index],
        ),
      );

      await cache.put(category, news);
      await appCache.put('categoryTime', DateTime.now());

      return news;
    } catch (e) {
      log(e.toString());
      throw Exception(e.toString());
    }
  }

  static Future<List<News>?> fetchHive(String category) async {
    try {
      List? cachedNews = cache.get(category);

      if (cachedNews == null) return null;

      List<News>? news = List.generate(
        cachedNews.length,
        (index) => cachedNews[index],
      );
      return news;
    } catch (e) {
      log(e.toString());

      throw Exception(e.toString());
    }
  }
}
