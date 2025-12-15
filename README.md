# GemChat 💎

A powerful AI chatbot built with Flutter, Firebase, and Google's Gemini API, offering a clean and intelligent real-time chat experience.

## Overview

GemChat combines the intelligence of Gemini 2.5 Flash with Firebase's reliability and BLoC architecture for scalable state management. The result is a fast, modular, and easily extensible chat application with persistent conversation history.

## Features

- ✅ **Email + Password Authentication** - Secure user login and registration
- ✅ **Multiple Chat Sessions** - Manage different conversations via drawer navigation
- ✅ **Auto Scroll to Latest Message** - Seamless conversation flow
- ✅ **Retry on Timeout/Error** - Graceful error handling
- ✅ **Offline Detection** - Checks connectivity before sending prompts
- ✅ **Persistent Chat History** - All conversations stored in Firestore
- ✅ **Beautiful Dark UI** - Simple and elegant interface

## Architecture

```
Firebase Auth
    ↓
Firestore
    ↓
ChatBloc (Handles events + states)
    ↓
ChatRepo (Dio + Gemini API calls)
    ↓
UI (BlocConsumer + StreamBuilder)
```

The app uses BLoC pattern to separate business logic from UI, ensuring clean code and easy maintenance.

## Firestore Structure

```
users/
  userId/
    chats/
      chatId/
        conversations: [
          { prompt: "Hello!", response: "Hi there 👋" },
          { prompt: "What can you do?", response: "I can assist with..." }
        ]
        lastUpdated: <timestamp>
```

Each user can maintain multiple chat histories, with conversations stored as arrays of prompt-response pairs.

## Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Firebase Auth** - User authentication
- **Firestore** - Real-time database for chat storage
- **Google Gemini API (2.5 Flash)** - AI model for responses
- **BLoC** - State management pattern
- **Dio** - HTTP client for API calls

## Key Challenges Solved

- Handling API timeouts gracefully with retry mechanisms
- Ensuring auto-scroll functionality after UI rebuilds
- Maintaining synchronization between Firebase and BLoC states
- Designing a scalable Firestore schema for chat storage

## Lessons Learned

- Using BLoC for separating UI logic provides significant benefits for code maintainability
- Firestore's `arrayUnion` is ideal for storing structured chat histories
- Gemini's response format requires careful decoding and error handling with Dio

## Future Enhancements

- 🎙 **Voice Input + Speech Output** - Add voice interaction capabilities
- 🧩 **Markdown & Rich Text Support** - Enhanced message formatting
- 🪄 **Prompt Templates** - Pre-built templates for common tasks (summarize, explain code)
- 🧠 **Multimodal Input** - Extended Gemini 2.5 Flash integration for images and other media

## Getting Started

1. Clone the repository
2. Set up Firebase project and add configuration files
3. Add your Gemini API key to the project
4. Run `flutter pub get` to install dependencies
5. Launch the app with `flutter run`

## Acknowledgements

### Educational Resources
- **Akshit Madan** - Build with Akshit (YouTube)
- **WCKD** - Flutterly (YouTube)

### Development Tools
- **ChatGPT** - AI assistance for styling and structural challenges

---

Built with ❤️ using Flutter and Gemini AI