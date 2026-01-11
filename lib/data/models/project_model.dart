import 'node_model.dart';
import 'package:uuid/uuid.dart';

enum ProjectStatus { draft, ready, generating, completed, failed, insufficientCredits }

class Project {
  final String id;
  final String title;
  final ProjectStatus status;
  final List<ProjectNode> nodes;
  final String? videoUrl;
  final String? videoThumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Project({
    required this.id,
    required this.title,
    required this.status,
    required this.nodes,
    this.videoUrl,
    this.videoThumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Project.create() {
    final now = DateTime.now();
    return Project(
      id: const Uuid().v4(),
      title: 'Untitled Project',
      status: ProjectStatus.draft,
      nodes: [],
      createdAt: now,
      updatedAt: now,
    );
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      title: json['title'] as String,
      status: ProjectStatus.values.firstWhere((e) => e.name == json['status']),
      nodes: (json['nodes'] as List<dynamic>)
          .map((e) => ProjectNode.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoUrl: json['video_url'] as String?,
      videoThumbnailUrl: json['video_thumbnail_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'status': status.name,
      'nodes': nodes.map((e) => e.toJson()).toList(),
      'video_url': videoUrl,
      'video_thumbnail_url': videoThumbnailUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Project copyWith({
    String? title,
    ProjectStatus? status,
    List<ProjectNode>? nodes,
    String? videoUrl,
    String? videoThumbnailUrl,
  }) {
    return Project(
      id: id,
      title: title ?? this.title,
      status: status ?? this.status,
      nodes: nodes ?? this.nodes,
      videoUrl: videoUrl ?? this.videoUrl,
      videoThumbnailUrl: videoThumbnailUrl ?? this.videoThumbnailUrl,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
