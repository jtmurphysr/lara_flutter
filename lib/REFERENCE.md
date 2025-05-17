🧠 Lara Cortex API – Full Reference

This is the secure, vector-backed, personality-aware API behind your assistant. Use it to query memory, conduct contextual conversations, and manage persona profiles.

⸻

🔐 Authentication

Every route (except /health) requires this header:

Authorization: Bearer <LARA_API_TOKEN>

You can pass this in all requests using a bearer token from your .env (LARA_API_TOKEN).

⸻

🚀 Endpoints

🔍 POST /query/

Search semantic memory with optional personality modulation.

Request

{
  "query": "What does John believe about leadership?",
  "max_results": 5,
  "personality_id": "mentor"  // optional
}

Response

{
  "response": "summary from memory",
  "session_id": null,
  "sources": [
    {
      "content": "...",
      "metadata": {
        "tag": "leadership",
        ...
      }
    }
  ],
  "personality": {
    "id": "mentor",
    "name": "Mentor AI",
    "type": "coach",
    "role": "guide"
  }
}

⸻

💬 POST /conversation/

Persistent, session-aware conversation endpoint.

Request

POST /conversation/?session_id=<optional UUID>

{
  "query": "How should I approach mentoring this new team?",
  "max_results": 5,
  "personality_id": "mentor"
}

Response

{
  "response": "contextual, personality-aware reply",
  "session_id": "generated-or-supplied-id",
  "sources": [ { "content": "...", "metadata": {...} } ],
  "personality": {
    "id": "mentor",
    "name": "Mentor AI",
    "type": "coach",
    "role": "guide",
    "description": "A thoughtful guide focused on leadership development"
  }
}

⸻

🎭 GET /personalities/

Returns a list of available personality definitions.

Response

[
  {
    "id": "mentor",
    "name": "Mentor AI",
    "type": "coach",
    "role": "guide",
    "description": "A thoughtful guide focused on leadership development"
  }
]

⸻

✏️ GET /personalities/{id}/prompt

Fetch the raw system prompt for a given personality.

Response

You are a thoughtful mentor helping the user grow as a leader.

⸻

⬆️ POST /personalities/upload

Upload a JSON file defining a new personality.

Form Upload Fields
	•	file: JSON file
	•	name: optional

Response

{
  "message": "Personality uploaded successfully",
  "personality_id": "mentor"
}

⸻

🫀 GET /health

Simple liveness and readiness check.

Response

{
  "status": "healthy",
  "chains_initialized": true
}

⸻

🧠 Personality File Format

Each .json should follow this structure:

{
  "name": "Mentor AI",
  "type": "coach",
  "role": "guide",
  "description": "A thoughtful guide focused on leadership development",
  "prompt": "You are a thoughtful mentor helping the user grow as a leader."
}

Place these in the personalities/ directory or upload them via the API.

⸻

🧩 Integration Flow (Client-Side)
1. Collect user input.
2. Send it to /query/ or /conversation/ with auth.
3. Parse the memory-informed response.
4. Display personality information in the UI for context.
5. Optionally pass memory + result to GPT for follow-up interpretation.

⸻

💡 UI Best Practices
1. Always display the active personality name for context
2. Show personality information in message bubbles
3. Use personality type/role to style messages appropriately
4. Maintain visual consistency in personality representation
5. Allow easy personality switching while preserving context

⸻

This is Lara's synthetic cortex. Treat it like a neural interface: precise, contextual, and full of potential.