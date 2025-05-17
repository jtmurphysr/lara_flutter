# 📱 Orrery Flutter Integration Guide

This guide explains how to integrate a Flutter client with the Orrery API.

---

## ✅ Core Concepts
- **Session persistence** via `uuidv4()` + local storage
- **Persona-aware interaction** via `/conversation`
- **Direct memory embedding** via `/train`
- **Personality context** throughout the conversation

---

## 🧠 API Client Setup

### HTTP Wrapper
Use `http` package for REST calls.

```dart
final baseUrl = 'https://lara.ruiningmediocrity.com';
final headers = {
  'Content-Type': 'application/json',
  'Authorization': 'Bearer YOUR_TOKEN',
};
```

---

## 🧭 Endpoints

### `POST /conversation` (memory + persona)
```dart
final response = await http.post(
  Uri.parse('$baseUrl/conversation?session_id=$sessionId'),
  headers: headers,
  body: jsonEncode({
    'query': userInput,
    'personality_id': personaId
  }),
);
```

### `POST /train` (manual memory injection)
```dart
Future<void> trainMemory({
  required String persona,
  required String title,
  required String content,
  List<String> tags = const [],
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/train'),
    headers: headers,
    body: jsonEncode({
      'persona': persona,
      'title': title,
      'content': content,
      'tags': tags,
    }),
  );

  if (response.statusCode != 200) {
    throw Exception('Training failed');
  }
}
```

---

## 💾 Session Persistence

```dart
final prefs = await SharedPreferences.getInstance();
String sessionId = prefs.getString('orrerySession') ?? const Uuid().v4();
prefs.setString('orrerySession', sessionId);
```

---

## 🧬 Model Examples
```dart
class Personality {
  final String id;
  final String name;
  final String type;
  final String role;
  final String description;

  Personality({
    required this.id, 
    required this.name,
    required this.type,
    required this.role,
    this.description = '',
  });

  factory Personality.fromJson(Map<String, dynamic> json) {
    return Personality(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      role: json['role'],
      description: json['description'] ?? '',
    );
  }
}

class Message {
  final String role;
  final String content;
  final Personality? personality;
  
  Message({
    required this.role, 
    required this.content, 
    this.personality,
  });
}

class ConversationResponse {
  final String response;
  final String? sessionId;
  final List<String>? sources;
  final Personality? personality;

  ConversationResponse({
    required this.response, 
    this.sessionId, 
    this.sources,
    this.personality,
  });
}
```

---

## 🎨 UI Implementation Guide

### Message Bubbles
- Display personality name/role above non-user messages
- Use personality type to style messages (colors, fonts)
- Include personality context in message metadata

### Personality Selection
- Dropdown with personality icons/avatars
- Show personality description on selection
- Maintain active personality indicator

### ChatScreen Structure
```dart
class ChatScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat'),
        bottom: PreferredSize(
          // Active personality indicator
          child: PersonalityBar(
            personality: currentPersonality,
            onChanged: handlePersonalityChange,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: MessageList(
              messages: messages,
              // Pass personality for message styling
              personalityStyles: personalityStyles,
            ),
          ),
          InputArea(),
        ],
      ),
    );
  }
}
```

### Message Styling
- Use consistent color scheme per personality
- Include personality badges/icons
- Style differences between user/assistant messages
- Support markdown with personality-specific styling

### Transitions
- Smooth personality switching animations
- Loading states with personality context
- Typing indicators with personality flair

---

## 🎯 Best Practices
- Cache personality information locally
- Maintain personality context during session
- Use personality-aware error messages
- Apply consistent personality styling
- Handle personality switching gracefully
- Include personality info in exports/sharing

---

Orrery doesn't just speak. It listens, learns, and *remembers* - with personality!
