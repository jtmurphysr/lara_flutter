class Source {
  final String? content;
  final SourceMetadata? metadata;

  Source({
    this.content,
    this.metadata,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      content: json['content'] as String?,
      metadata: json['metadata'] != null 
          ? SourceMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (content != null) 'content': content,
      if (metadata != null) 'metadata': metadata!.toJson(),
    };
  }
}

class SourceMetadata {
  final DateTime? timestamp;
  final String? source;
  final double? confidence;

  SourceMetadata({
    this.timestamp,
    this.source,
    this.confidence,
  });

  factory SourceMetadata.fromJson(Map<String, dynamic> json) {
    return SourceMetadata(
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp'] as String) : null,
      source: json['source'] as String?,
      confidence: json['confidence'] != null ? (json['confidence'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      if (source != null) 'source': source,
      if (confidence != null) 'confidence': confidence,
    };
  }
}