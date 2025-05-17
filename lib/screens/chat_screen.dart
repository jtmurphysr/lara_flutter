import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/message.dart';
import '../models/source.dart';
import '../models/personality.dart';
import '../services/orrery_api_service.dart';
import './train_memory_screen.dart';

class ChatScreen extends StatefulWidget {
  final OrreryApiService apiService;
  final String? initialPersonalityId;

  const ChatScreen({
    Key? key,
    required this.apiService,
    this.initialPersonalityId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<Message> _messages = [];
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  String? _sessionId;
  String? _selectedPersonalityId;
  Personality? _selectedPersonality;
  List<Personality> _personalities = [];
  bool _isLoading = false;
  bool _isLoadingPersonalities = true;

  @override
  void initState() {
    super.initState();
    _selectedPersonalityId = widget.initialPersonalityId;
    _loadPersonalities();
  }

  Future<void> _loadPersonalities() async {
    setState(() {
      _isLoadingPersonalities = true;
    });

    try {
      final personalities = await widget.apiService.getPersonalities();
      setState(() {
        _personalities = personalities;
        _isLoadingPersonalities = false;
        
        // Set default personality if not already set
        if (_selectedPersonalityId == null && personalities.isNotEmpty) {
          // Look for 'lara-ember' first
          final laraEmber = personalities.firstWhere(
            (p) => p.id.toLowerCase() == 'lara-ember',
            orElse: () => personalities.first,
          );
          _selectedPersonalityId = laraEmber.id;
          _selectedPersonality = laraEmber;
        } else if (_selectedPersonalityId != null) {
          // Find the selected personality in the list
          _selectedPersonality = personalities.firstWhere(
            (p) => p.id == _selectedPersonalityId,
            orElse: () => personalities.first,
          );
        }
      });
    } catch (e) {
      print('Error loading personalities: $e');
      setState(() {
        _isLoadingPersonalities = false;
      });
    }
  }

  void _showPersonalitySelector() {
    if (_personalities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No personalities available')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Personality'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _personalities.length,
            itemBuilder: (context, index) {
              final personality = _personalities[index];
              final isSelected = personality.id == _selectedPersonalityId;
              
              return ListTile(
                title: Text(personality.name),
                subtitle: Text(personality.description ?? 'No description available'),
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.person_outline,
                  color: isSelected ? Theme.of(context).primaryColor : null,
                ),
                selected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedPersonalityId = personality.id;
                    _selectedPersonality = personality;
                  });
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    if (_textController.text.isEmpty) return;

    final userMessage = Message(
      text: _textController.text,
      isUser: true,
    );

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      final response = await widget.apiService.converse(
        query: userMessage.text,
        sessionId: _sessionId,
        personalityId: _selectedPersonalityId,
      );

      setState(() {
        _sessionId = response.sessionId;
        _messages.add(Message(
          text: response.response,
          isUser: false,
          sources: response.sources,
          personalityId: _selectedPersonalityId,
          personalityName: _selectedPersonality?.name,
        ));
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _messages.add(Message(
          text: 'Error: ${e.toString()}',
          isUser: false,
        ));
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Orrery'),
            if (_selectedPersonality != null)
              Text(
                'Connected to: ${_selectedPersonality!.name}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.8),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrainMemoryScreen(
                    apiService: widget.apiService,
                    initialPersonalityId: _selectedPersonalityId,
                  ),
                ),
              );
            },
            tooltip: 'Train Memory',
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.person),
                if (_isLoadingPersonalities)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: 10,
                      height: 10,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: _isLoadingPersonalities ? null : _showPersonalitySelector,
            tooltip: 'Select Personality',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageBubble(
                  message: message,
                  onSourceTap: (source) {
                    // Show source detail view
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Source Details'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Source: ${source.metadata?.source ?? 'Unknown'}'),
                            Text('Confidence: ${source.metadata?.confidence ?? 'N/A'}'),
                            Text('Timestamp: ${source.metadata?.timestamp?.toString() ?? 'N/A'}'),
                            const Divider(),
                            const Text('Content:'),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Text(source.content ?? 'No content available'),
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('CLOSE'),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: Focus(
                    onKeyEvent: (node, event) {
                      if (event is KeyDownEvent) {
                        if (event.logicalKey == LogicalKeyboardKey.enter) {
                          final isShiftPressed = HardwareKeyboard.instance.isShiftPressed;
                          final isMetaPressed = HardwareKeyboard.instance.isMetaPressed;
                          
                          if (isShiftPressed || isMetaPressed) {
                            // Insert a newline at current cursor position
                            final currentText = _textController.text;
                            final selection = _textController.selection;
                            final newText = currentText.replaceRange(
                              selection.start, 
                              selection.end, 
                              '\n'
                            );
                            _textController.value = TextEditingValue(
                              text: newText,
                              selection: TextSelection.collapsed(
                                offset: selection.start + 1
                              ),
                            );
                            return KeyEventResult.handled;
                          } else if (!HardwareKeyboard.instance.isControlPressed) {
                            _sendMessage();
                            return KeyEventResult.handled;
                          }
                        }
                      }
                      return KeyEventResult.ignored;
                    },
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final Function(Source) onSourceTap;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.onSourceTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: message.isUser
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser && message.personalityName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  message.personalityName!,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            MarkdownBody(
              data: message.text,
              styleSheet: MarkdownStyleSheet(
                p: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
            if (message.sources != null && message.sources!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8.0),
                  Text(
                    'Sources:',
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.black54,
                      fontSize: 12.0,
                    ),
                  ),
                  ...message.sources!.map((source) => _SourceChip(
                        source: source,
                        onTap: () => onSourceTap(source),
                        isUserMessage: message.isUser,
                      )),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  final Source source;
  final VoidCallback onTap;
  final bool isUserMessage;

  const _SourceChip({
    Key? key,
    required this.source,
    required this.onTap,
    required this.isUserMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: isUserMessage ? Colors.white24 : Colors.black12,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.link,
              size: 12.0,
              color: isUserMessage ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 4.0),
            Text(
              source.metadata?.source ?? 'Unknown source',
              style: TextStyle(
                color: isUserMessage ? Colors.white70 : Colors.black54,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}