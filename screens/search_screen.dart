import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sandbox/widgets/article_container.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_sandbox/models/article.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreen();
}

class _SearchScreen extends State<SearchScreen> {
  List<Article> articles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Qiita Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
            child: TextField(
              style: const TextStyle(fontSize: 18, color: Colors.black),
              decoration: const InputDecoration(hintText: '検索ワードを入力'),
              onSubmitted: (String keyword) async {
                final results = await searchQiita(keyword);
                setState(() => articles = results);
              },
            ),
          ),
          Expanded(
              child: ListView(
                  children: articles
                      .map((article) => ArticleContainer(article: article))
                      .toList()))
        ],
      ),
    );
  }

  Future<List<Article>> searchQiita(String keyword) async {
    final uri = Uri.https('qiita.com', '/api/v2/items',
        {'query': 'title:$keyword', 'per_page': '10'});

    final String token = dotenv.env['QIITA_ACCESS_TOKEN'] ?? '';

    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode != 200) {
      return [];
    }

    final List<dynamic> body = jsonDecode(response.body);
    return body.map((json) => Article.fromJson(json)).toList();
  }
}
