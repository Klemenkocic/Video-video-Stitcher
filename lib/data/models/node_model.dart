import 'package:uuid/uuid.dart';

enum NodeType { image, text }

class ProjectNode {
  final String id;
  final NodeType type;
  final String content; // URL for image, Text for prompt
  final int order;

  const ProjectNode({
    required this.id,
    required this.type,
    required this.content,
    required this.order,
  });

  factory ProjectNode.create({
    required NodeType type,
    required String content,
    required int order,
  }) {
    return ProjectNode(
      id: const Uuid().v4(),
      type: type,
      content: content,
      order: order,
    );
  }

  factory ProjectNode.fromJson(Map<String, dynamic> json) {
    return ProjectNode(
      id: json['id'] as String,
      type: NodeType.values.firstWhere((e) => e.name == json['type']),
      content: json['content'] as String,
      order: json['order'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'content': content,
      'order': order,
    };
  }
}
