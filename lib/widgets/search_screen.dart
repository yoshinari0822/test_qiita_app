import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:test_qiita_app/models/article.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  Future<List<Article>> searchQiita(String keyword) async {
    //URL、クエリパラメータの設定
    final Uri uri = Uri.https("qiita.com", "/api/v2/items", {
      "query": "title:$keyword",
      "per_page": "10",
    });

    //APIキーの取得
    final String token = dotenv.env["QIITA_ACCESS_TOKEN"] ?? "";

    //リクエストの作成
    final http.Response res = await http.get(
      uri,
      headers: {"Authorization": "Bearer $token"},
    );

    //ステータスに応じた処理
    if (res.statusCode == 200) {
      final List<dynamic> body = jsonDecode(res.body);
      return body.map((dynamic json) => Article.fromJson(json)).toList();
    } else {
      return [];
    }
  }

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Qiita Search')),
      body: Container(),
    );
  }
}
