import 'source.dart';

class Message {
  final String text;
  final bool isUser;
  final List<Source>? sources;
  final DateTime timestamp;
  final String? personalityId;
  final String? personalityName;

  Message({
    required this.text,
    required this.isUser,
    this.sources,
    this.personalityId,
    this.personalityName,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      text: json['text'] as String,
      isUser: json['is_user'] as bool,
      sources: json['sources'] != null
          ? (json['sources'] as List)
              .map((s) => Source.fromJson(s as Map<String, dynamic>))
              .toList()
          : null,
      personalityId: json['personality_id'] as String?,
      personalityName: json['personality_name'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_user': isUser,
      'sources': sources?.map((s) => s.toJson()).toList(),
      'personality_id': personalityId,
      'personality_name': personalityName,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}