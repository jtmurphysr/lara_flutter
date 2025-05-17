import 'source.dart';

class ConversationResponse {
  final String response;
  final String? sessionId;
  final List<Source>? sources;

  ConversationResponse({
    required this.response,
    this.sessionId,
    this.sources,
  });

  factory ConversationResponse.fromJson(Map<String, dynamic> json) {
    return ConversationResponse(
      response: json['response'] as String,
      sessionId: json['session_id'] as String?,
      sources: json['sources'] != null 
        ? (json['sources'] as List)
            .map((s) => Source.fromJson(s as Map<String, dynamic>))
            .toList()
        : null,
    );
  }
}

class QueryResponse {
  final String response;
  final String? sessionId;
  final List<Source> sources;

  QueryResponse({
    required this.response,
    this.sessionId,
    required this.sources,
  });

  factory QueryResponse.fromJson(Map<String, dynamic> json) {
    return QueryResponse(
      response: json['response'] as String,
      sessionId: json['session_id'] as String?,
      sources: (json['sources'] as List)
          .map((s) => Source.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}