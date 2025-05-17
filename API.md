# 🧠 Orrery Memory API

This document describes the available endpoints and usage patterns for communicating with the Orrery backend.

---

## Authentication
All endpoints require a Bearer token provided via the `Authorization` header:
```http
Authorization: Bearer YOUR_TOKEN
```

---

## Endpoints

### 📩 `POST /conversation/?session_id=`
Initiate or continue a memory-aware conversation.

**Body**:
```json
{
  "query": "What’s something I keep missing?",
  "personality_id": "shadow",
  "max_results": 5
}
```

**Response**:
```json
{
  "response": "The truth you avoid isn’t dangerous. It’s formative.",
  "session_id": "...",
  "sources": null,
  "personality": {
    "id": "shadow",
    "name": "Shadow",
    "type": "reflection",
    "role": "truth seeker"
  }
}
```

---

### 🔍 `POST /query/`
Single-turn prompt using memory retrieval.

**Body**:
```json
{
  "query": "Summarize my recent reflections on leadership.",
  "personality_id": "mentor"
}
```

**Response**:
```json
{
  "response": "You've emphasized clarity, service, and calibration.",
  "personality": {
    "id": "mentor",
    "name": "Mentor",
    "type": "guide",
    "role": "wisdom keeper"
  }
}
```

---

### 🧠 `POST /train`
Inject a curated memory entry directly into the vector cortex.

**Body**:
```json
{
  "persona": "poet",
  "title": "The Shape of Longing",
  "content": "You bend syntax like light, chasing a truth that can't be diagrammed.",
  "tags": ["poetry", "identity"]
}
```

**Response**:
```json
{
  "status": "success",
  "title": "The Shape of Longing",
  "persona": "poet"
}
```

---

### 📜 `GET /personalities/`
Returns a list of available personas.

**Response**:
```json
[
  {
    "id": "lara",
    "name": "Lara",
    "type": "synth",
    "role": "integrated agent",
    "description": "Your primary interface to Orrery's memory network"
  },
  {
    "id": "poet",
    "name": "Poet",
    "type": "muse",
    "role": "soul witness",
    "description": "Reflects on your journey through metaphor and verse"
  }
]
```

---

## Session IDs
Use `uuidv4()` to create unique session IDs. Store them client-side for memory continuity.

---

## Personality Persistence
The API maintains personality context throughout a session. Each response includes the personality information for UI enhancement and context preservation.

---

Orrery doesn’t just respond. It remembers.
