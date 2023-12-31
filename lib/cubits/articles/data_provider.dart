part of 'cubit.dart';


class ArticlesDataProvider {
  static final dio = Dio();
  static const apikey = "bdfd25ce2c9b4a9aa53baa63e89a5274";

  /// [apiKey] is required, you can get it from newsapi.org
  static final cache = Hive.box('articlesbox');
  static final appCache = Hive.box('app');

  static Future<List<Article>> fetch(String keyword) async {
    try {
      final response = await dio.get(
        'https://newsapi.org/v2/everything?q=$keyword',
        options: Options(
          headers: {
            'Authorization': apikey
          },
        ),
      );

      Map raw = response.data;
      log(raw.toString());

      List articlesList = raw['articles'];

      List<Article> articles = List.generate(
        articlesList.length,
        (index) => Article.fromMap(
          articlesList[index],
        ),
      );

      await cache.put(keyword, articles);
      await appCache.put('articlesTime', DateTime.now());

      return articles;

    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<List<Article>?> fetchHive(String keyword) async {
    try {
      List? cachedArticle = cache.get(keyword);

      if (cachedArticle == null) return null;

      List<Article>? article = List.generate(
        cachedArticle.length,
        (index) => cachedArticle[index],
      );
      return article;
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
