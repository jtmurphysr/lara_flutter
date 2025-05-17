# 🧠 Lara Flutter

A personality-aware, memory-augmented chat interface for the Orrery API.

## ✨ Features

- **Dynamic Personalities**: Switch between different AI personas during conversations
- **Memory Persistence**: Conversations maintain context across sessions
- **Rich UI**: Personality-aware message styling and animations
- **Markdown Support**: Render formatted text with personality-specific styling
- **Offline Support**: Cache conversations and personality data locally

## 🚀 Getting Started

1. Clone the repository
2. Create a `.env` file with your Orrery API token:
   ```
   LARA_API_TOKEN=your_token_here
   ```
3. Install dependencies:
   ```
   flutter pub get
   ```
4. Run the app:
   ```
   flutter run
   ```

## 📚 Documentation

- [API Reference](API.md) - Orrery API endpoints and usage
- [Flutter Integration](flutter_integration.md) - Detailed integration guide
- [Technical Reference](lib/REFERENCE.md) - In-depth technical documentation

## 🎨 Personality System

The app features a dynamic personality system that:
- Displays active personality context in the UI
- Styles messages based on personality type
- Maintains conversation coherence during personality switches
- Provides visual feedback for personality changes

## 🏗 Project Structure

```
lib/
  ├── models/         # Data models including Personality
  ├── screens/        # UI screens and widgets
  ├── services/       # API and local storage services
  └── personalities/  # Personality definitions
```

## 🔧 Configuration

Edit `lib/config.dart` to customize:
- API endpoint
- Default personality
- UI themes per personality
- Cache settings

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Built with Flutter and the power of Orrery's personality-aware memory system.
