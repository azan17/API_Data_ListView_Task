import 'package:flutter/material.dart';
// import 'post.dart'; // Import the Post model
// import 'fetch_posts.dart'; // Import the fetchPosts function
import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Post>> fetchPosts() async {
  final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

  if (response.statusCode == 200) {
    List jsonResponse = json.decode(response.body);
    return jsonResponse.map((post) => Post.fromJson(post)).toList();
  } else {
    throw Exception('Failed to load posts');
  }
}

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API ListView Search',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PostListScreen(),
    );
  }
}

class PostListScreen extends StatefulWidget {
  const PostListScreen({super.key});

  @override
  _PostListScreenState createState() => _PostListScreenState();
}

class _PostListScreenState extends State<PostListScreen> {
  late Future<List<Post>> futurePosts;
  List<Post> _posts = [];
  List<Post> _filteredPosts = [];

  @override
  void initState() {
    super.initState();
    futurePosts = fetchPosts();
    futurePosts.then((posts) {
      setState(() {
        _posts = posts;
        _filteredPosts = posts;
      });
    });
  }

  void _filterPosts(String query) {
    final filtered = _posts.where((post) {
      final titleLower = post.title.toLowerCase();
      final bodyLower = post.body.toLowerCase();
      final searchLower = query.toLowerCase();

      return titleLower.contains(searchLower) || bodyLower.contains(searchLower);
    }).toList();

    setState(() {
      _filteredPosts = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API ListView Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
              ),
              onChanged: _filterPosts,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Post>>(
              future: futurePosts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  return ListView.builder(
                    itemCount: _filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = _filteredPosts[index];
                      return ListTile(
                        title: Text(post.title),
                        subtitle: Text(post.body),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}


class Post {
  final int id;
  final String title;
  final String body;

  Post({required this.id, required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      body: json['body'],
    );
  }
}


