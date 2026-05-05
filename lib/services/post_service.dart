import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bharatnova/models/post.dart';

class PostService {
  static const String _postUrl = 'https://dummyjson.com/posts';
  static const String _userUrl = 'https://randomuser.me/api/';

  Future<List<Post>> fetchPosts({int skip = 0, int limit = 10}) async {
    try {
      // Fetch posts and random users in parallel
      final results = await Future.wait([
        http.get(Uri.parse('$_postUrl?skip=$skip&limit=$limit')),
        http.get(Uri.parse('$_userUrl?results=$limit')),
      ]);

      final postRes = results[0];
      final userRes = results[1];

      if (postRes.statusCode == 200 && userRes.statusCode == 200) {
        final postData = json.decode(postRes.body);
        final userData = json.decode(userRes.body);
        
        final List postsJson = postData['posts'];
        final List usersJson = userData['results'];

        return postsJson.asMap().entries.map((entry) {
          final postJson = entry.value;
          final userJson = usersJson[entry.key % usersJson.length];
          return Post.fromDynamicJson(postJson, userJson, skip + entry.key);
        }).toList();
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
