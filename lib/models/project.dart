import 'dart:convert';

enum ProjectCategory { aiMl, webDev, mobileApp, dataScience, devOps, other }

enum DevelopmentStatus { inProgress, completed, maintenance, archived }

extension ProjectCategoryX on ProjectCategory {
  String get displayName {
    switch (this) {
      case ProjectCategory.aiMl:
        return 'AI / ML';
      case ProjectCategory.webDev:
        return 'Web Dev';
      case ProjectCategory.mobileApp:
        return 'Mobile App';
      case ProjectCategory.dataScience:
        return 'Data Science';
      case ProjectCategory.devOps:
        return 'DevOps';
      case ProjectCategory.other:
        return 'Other';
    }
  }
}

extension DevelopmentStatusX on DevelopmentStatus {
  String get displayName {
    switch (this) {
      case DevelopmentStatus.inProgress:
        return 'In Progress';
      case DevelopmentStatus.completed:
        return 'Completed';
      case DevelopmentStatus.maintenance:
        return 'Maintenance';
      case DevelopmentStatus.archived:
        return 'Archived';
    }
  }
}

class Project {
  final String id;
  final String title;
  final String description;
  final String techStack;
  final String author;
  final String githubUrl;
  final ProjectCategory category;
  final DevelopmentStatus status;
  final DateTime timestamp;
  int stars;
  bool isStarred;

  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.techStack,
    required this.author,
    this.githubUrl = '',
    required this.category,
    this.status = DevelopmentStatus.inProgress,
    required this.timestamp,
    this.stars = 0,
    this.isStarred = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'techStack': techStack,
        'author': author,
        'githubUrl': githubUrl,
        'category': category.index,
        'status': status.index,
        'timestamp': timestamp.toIso8601String(),
        'stars': stars,
        'isStarred': isStarred,
      };

  factory Project.fromJson(Map<String, dynamic> json) => Project(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        techStack: json['techStack'],
        author: json['author'],
        githubUrl: json['githubUrl'] ?? '',
        category: ProjectCategory.values[json['category']],
        status: DevelopmentStatus.values[json['status']],
        timestamp: DateTime.parse(json['timestamp']),
        stars: json['stars'] ?? 0,
        isStarred: json['isStarred'] ?? false,
      );

  Project copyWith({
    String? title,
    String? description,
    String? techStack,
    String? author,
    String? githubUrl,
    ProjectCategory? category,
    DevelopmentStatus? status,
    int? stars,
    bool? isStarred,
  }) =>
      Project(
        id: id,
        title: title ?? this.title,
        description: description ?? this.description,
        techStack: techStack ?? this.techStack,
        author: author ?? this.author,
        githubUrl: githubUrl ?? this.githubUrl,
        category: category ?? this.category,
        status: status ?? this.status,
        timestamp: timestamp,
        stars: stars ?? this.stars,
        isStarred: isStarred ?? this.isStarred,
      );
}
