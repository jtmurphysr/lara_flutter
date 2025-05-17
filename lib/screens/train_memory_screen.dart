import 'package:flutter/material.dart';
import '../services/orrery_api_service.dart';
import '../models/personality.dart';

class TrainMemoryScreen extends StatefulWidget {
  final OrreryApiService apiService;
  final String? initialPersonalityId;

  const TrainMemoryScreen({
    Key? key,
    required this.apiService,
    this.initialPersonalityId,
  }) : super(key: key);

  @override
  _TrainMemoryScreenState createState() => _TrainMemoryScreenState();
}

class _TrainMemoryScreenState extends State<TrainMemoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  
  List<Personality> _personalities = [];
  Personality? _selectedPersonality;
  bool _isSubmitting = false;
  bool _isLoadingPersonalities = true;

  @override
  void initState() {
    super.initState();
    _loadPersonalities();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _loadPersonalities() async {
    try {
      final personalities = await widget.apiService.getPersonalities();
      setState(() {
        _personalities = personalities;
        _isLoadingPersonalities = false;
        
        // Set initial personality if provided
        if (widget.initialPersonalityId != null) {
          _selectedPersonality = personalities.firstWhere(
            (p) => p.id == widget.initialPersonalityId,
            orElse: () => personalities.first,
          );
        }
      });
    } catch (e) {
      _showError('Failed to load personalities: $e');
      setState(() => _isLoadingPersonalities = false);
    }
  }

  Future<void> _submitMemory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedPersonality == null) {
      _showError('Please select a personality');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final tags = _tagsController.text
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList();

      await widget.apiService.trainMemory(
        persona: _selectedPersonality!.id,
        title: _titleController.text,
        content: _contentController.text,
        tags: tags,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Memory successfully trained'),
            backgroundColor: Colors.green,
          ),
        );
        // Clear form after successful submission
        _titleController.clear();
        _contentController.clear();
        _tagsController.clear();
      }
    } catch (e) {
      _showError('Failed to train memory: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Train Memory'),
      ),
      body: _isLoadingPersonalities
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<Personality>(
                      value: _selectedPersonality,
                      decoration: const InputDecoration(
                        labelText: 'Select Personality',
                        border: OutlineInputBorder(),
                      ),
                      items: _personalities.map((personality) {
                        return DropdownMenuItem(
                          value: personality,
                          child: Text(personality.name),
                        );
                      }).toList(),
                      onChanged: (personality) {
                        setState(() => _selectedPersonality = personality);
                      },
                      validator: (value) {
                        if (value == null) return 'Please select a personality';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Memory Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter a title';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _contentController,
                      decoration: const InputDecoration(
                        labelText: 'Memory Content',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 5,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please enter content';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _tagsController,
                      decoration: const InputDecoration(
                        labelText: 'Tags (comma-separated)',
                        border: OutlineInputBorder(),
                        hintText: 'tag1, tag2, tag3',
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitMemory,
                      child: _isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Train Memory'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
