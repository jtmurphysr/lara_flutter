class Personality {
  final String id;
  final String name;
  final String type;
  final String role;
  final String? description;

  Personality({
    required this.id,
    required this.name,
    required this.type,
    required this.role,
    this.description,
  });

  factory Personality.fromJson(Map<String, dynamic> json) {
    return Personality(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      role: json['role'] as String,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'role': role,
      if (description != null) 'description': description,
    };
  }
}