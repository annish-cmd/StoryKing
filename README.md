# StoryKing Flutter App with DeepSeek & ElevenLabs

![image](https://github.com/user-attachments/assets/049aacdd-0657-47b0-a5a4-7e66a078bb82)

![image](https://github.com/user-attachments/assets/b07a1546-b9cd-49bf-ae5e-babef83161de)

![image](https://github.com/user-attachments/assets/0dcbfa35-b1d6-4b60-bd44-8edd6cad6114)

![image](https://github.com/user-attachments/assets/c39d0b98-d8c2-4715-bf3d-18e0544e793a)

![image](https://github.com/user-attachments/assets/1af10c06-d553-4d51-aac1-7fcc86b05f34)

![image](https://github.com/user-attachments/assets/cb226b7b-71f0-4951-8c45-37dc02bc8748)

![image](https://github.com/user-attachments/assets/cadf8600-ef07-4c03-af60-ec5a2310c4a1)

## API Keys Required

This application requires API keys from two services:

### 1. DeepSeek API Key (via OpenRouter)

To get your DeepSeek API key:

1. Visit [OpenRouter](https://openrouter.ai/) and create an account
2. Navigate to your account settings and generate an API key
3. Replace `YOUR_DEEPSEEK_API_KEY` in `lib/screens/home_screen.dart` with your actual API key

### 2. ElevenLabs API Key

To get your ElevenLabs API key:

1. Visit [ElevenLabs](https://elevenlabs.io/) and create an account
2. Go to your profile settings → API Key
3. Generate a new API key
4. Replace `YOUR_ELEVENLABS_API_KEY` in `lib/screens/main_screen.dart` with your actual API key

### API Keys Implementation Locations

- DeepSeek API Key: `lib/screens/home_screen.dart`
- ElevenLabs API Key: `lib/screens/main_screen.dart`

### Adjusting Token Settings

You can increase the tokens used for story generation in:
`lib/services/story_service.dart` (around line 176)
Change: `'max_tokens': 300,` to your preferred value

## Project Setup Requirements

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (Latest stable version recommended)
- JDK 17 (Required for Android build)
- Android Studio or VS Code with Flutter/Dart plugins

### Gradle Configuration

This project uses:

- Gradle 7.5 or higher
- Android Gradle Plugin 7.3.0 or compatible version

### Getting Started

1. Clone the repository
2. Add your API keys as mentioned above
3. Run `flutter pub get` to install dependencies
4. Run `flutter run` to start the application on a connected device or emulator

If you encounter Gradle-related errors, ensure you're using JDK 17 by:

- Setting JAVA_HOME environment variable to point to JDK 17
- Checking Android Studio/IntelliJ settings to use JDK 17 for the project

## Internship Work Overview

During my internship, I focused on the following areas:

- Frontend UI/UX development
- API integration (Elevenlabs TTS, Deepseek Story Service)
- State management
- App architecture and component design

## Project Directory Guide

This guide will help you understand the parts of the project I worked on.

### Main App Structure

- `lib/main.dart`: The entry point of the application with theme management and app initialization.

### UI Screens (lib/screens/)

These files contain the screens I developed:

- `main_screen.dart`: The main app interface with navigation. Contains the Elevenlabs TTS API integration.
- `home_screen.dart`: The landing screen with story generation UI. Contains Deepseek API integration.
- `profile_screen.dart`: User profile UI with settings management.
- `settings_screen.dart`: App settings with theme and text size controls.
- `favorites_screen.dart`: UI for saved favorite stories.
- `splash_screen.dart`: Initial loading screen with animations.
- `about_screen.dart`: App information display.
- `contact_screen.dart`: Contact UI.
- `help_support_screen.dart`: Help documentation UI.

### API Services (lib/services/)

I implemented these service files for API integration:

- `tts_service.dart`: Text-to-speech functionality using Elevenlabs API.
- `story_service.dart`: Story generation using Deepseek API.
- `storage_service.dart`: Local data persistence.

### Data Models (lib/models/)

These define the data structures I designed:

- `story.dart`: Story data model for managing generated content.
- `user_model.dart`: User data structure.

### UI Components (lib/widgets/)

Reusable UI components I created:

- `custom_drawer.dart`: Side navigation drawer with animations.
- `default_icon.dart`: Icon components with consistent styling.

### Key Features Implemented

1. **Story Generation UI**

   - Prompt input interface
   - Story display with animations
   - Loading states and error handling

2. **Text-to-Speech Integration**

   - Voice selection
   - Playback controls
   - Audio quality settings

3. **Theme Management**

   - Dark/light mode toggle
   - Persistent theme settings
   - Accessibility options (text scaling)

4. **UI/UX Design**

   - Custom animations
   - Responsive layouts
   - Intuitive navigation

### Configuration

- `pubspec.yaml`: Project dependencies and assets configuration.
- `flutter_launcher_icons.yaml`: App icon specifications
