import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/personality.dart';
import '../models/api_response.dart';

class OrreryApiService {
  final String baseUrl;
  final String apiToken;
  
  OrreryApiService({
    required this.baseUrl,
    required this.apiToken,
  });

  Map<String, String> get _headers => {
    'Authorization': 'Bearer $apiToken',
    'Content-Type': 'application/json',
  };

  Future<ConversationResponse> converse({
    required String query,
    String? sessionId,
    int maxResults = 5,
    String? personalityId,
  }) async {
    final effectivePersonalityId = personalityId ?? 'lara-ember';

    final payload = {
      'query': query,
      'max_results': maxResults,
      'personality_id': effectivePersonalityId,
    };
    if (sessionId != null) {
      payload['session_id'] = sessionId;
    }

    print('--- LARA DEBUG ---');
    print('Requesting /conversation/');
    print('Question: $query');
    print('Request Headers:');
    _headers.forEach((k, v) => print('  $k: $v'));
    print('Request Payload (raw map): $payload');
    print('Request Payload (JSON): ${jsonEncode(payload)}');
    print('Request session_id: $sessionId');

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/conversation/'),
        headers: _headers,
        body: jsonEncode(payload),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final resp = ConversationResponse.fromJson(jsonDecode(response.body));
        print('Response session_id: ${resp.sessionId}');
        print('--- END LARA DEBUG ---');
        return resp;
      } else {
        print('--- END LARA DEBUG ---');
        throw OrreryApiException.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print('--- END LARA DEBUG ---');
      throw OrreryApiException(
        code: 'NETWORK_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<List<Personality>> getPersonalities() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/personalities/'),
        headers: _headers,
      );

      final dynamic jsonData = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (jsonData is! List) {
          throw OrreryApiException(
            code: 'INVALID_RESPONSE',
            message: 'Expected array of personalities',
            details: {'response': jsonData},
          );
        }
        
        try {
          return jsonData.map((json) => Personality.fromJson(json as Map<String, dynamic>)).toList();
        } catch (e) {
          throw OrreryApiException(
            code: 'PARSE_ERROR',
            message: 'Failed to parse personalities: ${e.toString()}',
            details: {'response': jsonData},
          );
        }
      } else {
        final Map<String, dynamic> errorData = jsonData as Map<String, dynamic>;
        try {
          throw OrreryApiException.fromJson(errorData);
        } catch (e) {
          throw OrreryApiException(
            code: 'UNKNOWN_ERROR',
            message: 'Unknown error occurred: ${response.statusCode}',
            details: {'response': errorData},
          );
        }
      }
    } on FormatException catch (e) {
      throw OrreryApiException(
        code: 'INVALID_JSON',
        message: 'Invalid JSON response: ${e.toString()}',
      );
    } catch (e) {
      throw OrreryApiException(
        code: 'NETWORK_ERROR',
        message: e.toString(),
      );
    }
  }

  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      );

      print('Health check response: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw OrreryApiException(
          code: 'SERVER_ERROR',
          message: 'Server health check failed',
          details: {'status': response.statusCode},
        );
      }
    } catch (e) {
      throw OrreryApiException(
        code: 'NETWORK_ERROR',
        message: 'Failed to connect to server: ${e.toString()}',
      );
    }
  }

  Future<Map<String, dynamic>> trainMemory({
    required String persona,
    required String title,
    required String content,
    List<String> tags = const [],
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/train'),
        headers: _headers,
        body: jsonEncode({
          'persona': persona,
          'title': title,
          'content': content,
          'tags': tags,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw OrreryApiException.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      throw OrreryApiException(
        code: 'NETWORK_ERROR',
        message: e.toString(),
      );
    }
  }
}

class OrreryApiException implements Exception {
  final String code;
  final String message;
  final Map<String, dynamic>? details;

  OrreryApiException({
    required this.code,
    required this.message,
    this.details,
  });

  factory OrreryApiException.fromJson(Map<String, dynamic> json) {
    return OrreryApiException(
      code: json['code'] as String,
      message: json['message'] as String,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() => 'OrreryApiException: $code - $message';
}