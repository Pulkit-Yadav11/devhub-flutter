import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubRepo {
  final String name;
  final String description;
  final String language;
  final int stars;
  final String url;
  final String updatedAt;
  final bool isForked;

  GitHubRepo({
    required this.name,
    required this.description,
    required this.language,
    required this.stars,
    required this.url,
    required this.updatedAt,
    required this.isForked,
  });

  factory GitHubRepo.fromJson(Map<String, dynamic> json) => GitHubRepo(
        name: json['name'] ?? '',
        description: json['description'] ?? 'No description provided.',
        language: json['language'] ?? 'Unknown',
        stars: json['stargazers_count'] ?? 0,
        url: json['html_url'] ?? '',
        updatedAt: json['updated_at'] ?? '',
        isForked: json['fork'] ?? false,
      );
}

class GitHubService {
  static Future<List<GitHubRepo>> fetchRepos(String username) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.github.com/users/$username/repos?sort=updated&per_page=30'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => GitHubRepo.fromJson(e)).toList();
      } else if (response.statusCode == 404) {
        throw Exception('GitHub user not found');
      } else if (response.statusCode == 403) {
        throw Exception('Rate limit exceeded. Try again in a minute.');
      } else {
        throw Exception('Failed to load repos (${response.statusCode})');
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> fetchUserProfile(
      String username) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/users/$username'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('User not found');
      }
    } catch (e) {
      rethrow;
    }
  }
}