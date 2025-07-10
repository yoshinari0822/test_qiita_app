import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test_qiita_app/models/article.dart';
import 'package:test_qiita_app/widgets/article_container.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Article> articles = [];
  int currentPage = 1;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  String currentKeyword = "";
  bool hasMoreData = true; // 追加: データがまだあるかどうかを示すフラグ

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // スクロール位置がリストの終わりから600ピクセル以内になったらロードを開始
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 600) {
      _loadMoreArticles();
    }
  }

  Future<void> _loadMoreArticles() async {
    if (isLoading || currentKeyword.isEmpty || !hasMoreData) {
      return;
    }
    setState(() {
      isLoading = true;
    });
    final results = await searchQiita(currentKeyword, currentPage);
    setState(() {
      articles.addAll(results);
      currentPage++;
      isLoading = false;
      if (results.isEmpty) {
        // コレクションが空であるかどうかを確認
        hasMoreData = false;
      }
    });
  }

  Future<List<Article>> searchQiita(String keyword, int page) async {
    final Uri uri = Uri.https("qiita.com", "/api/v2/items", {
      "query": "title:$keyword",
      "per_page": "10",
      "page": page.toString(),
    });

    final String token = dotenv.env["QIITA_ACCESS_TOKEN"] ?? "";

    final http.Response res = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      final List<dynamic> body = jsonDecode(res.body);
      return body.map((dynamic json) => Article.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Qiita Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
            child: TextField(
              style: TextStyle(fontSize: 18, color: Colors.black),
              decoration: InputDecoration(hintText: "キーワードを入力"),
              onSubmitted: (String value) async {
                setState(() {
                  articles = [];
                  currentPage = 1;
                  currentKeyword = value;
                });
                final results = await searchQiita(currentKeyword, currentPage);
                setState(() {
                  articles = results;
                  currentPage++;
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: articles.length,
              itemBuilder: (context, index) {
                return ArticleContainer(article: articles[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
