# 🐉 Pokemon-Hau Mobile

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)](https://supabase.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge)](https://opensource.org/licenses/MIT)

**Pokemon-Hau** is a stunning, high-performance Flutter mobile application that brings the world of Pokemon to life with modern aesthetics, smooth animations, and real-time data integration.

---

## ✨ Key Features

- **🎮 Dynamic Dashboard**: A premium, Pokemon-themed dashboard featuring a live grid of Pokemon sprites fetched dynamically.
- **📚 Live Monster Library**: Integrated with the [PokeAPI](https://pokeapi.co/), displaying detailed information for every Pokemon including their types, IDs, and pixel-perfect animated sprites.
- **🗺️ Interactive Map**: A customized mapping interface powered by `flutter_map` and OpenStreetMap—providing full interactive functionality without requiring complex API keys.
- **🎨 Premium Visuals**: 
  - **Pixel-Perfect Sprites**: Uses sharp Generation V animated pixel art with custom high-fidelity rendering (`FilterQuality.none`).
  - **Breathing Animations**: Smooth, interactive scaling effects on buttons and cards for a premium feel.
  - **Custom Navigation**: A unique, overlapping bottom navigation bar with 3D-style popping icons and a central scaled Pokeball.
- **🎵 Atmospheric Audio**: Seamless, looped background music that persists across all screens for complete immersion.
- **🔐 Secure Authentication**: Ready for scalable backend integration using Supabase.

---

## 🛠️ Tech Stack

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Backend & DB**: [Supabase](https://supabase.com/) (Real-time DB & Auth) + [AWS RDS](https://aws.amazon.com/rds/) (PostgreSQL Storage)
- **Cloud Compute**: [AWS Lambda](https://aws.amazon.com/lambda/) (Serverless APIs) & [AWS EC2](https://aws.amazon.com/ec2/) (Persistent Background Workers)
- **Networking**: [http](https://pub.dev/packages/http) (PokeAPI Integration)
- **Audio**: [audioplayers](https://pub.dev/packages/audioplayers)
- **Routing**: [go_router](https://pub.dev/packages/go_router)
- **Animations**: [flutter_animate](https://pub.dev/packages/flutter_animate)
- **Maps**: [flutter_map](https://pub.dev/packages/flutter_map) + [latlong2](https://pub.dev/packages/latlong2)

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Latest Stable)
- Android Studio / VS Code with Flutter extensions
- A Supabase account (Optional for full auth features)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/darknecrocities/Pokemon-Hau.git
   cd Pokemon-Hau
   ```

2. **Setup Environment Variables**:
   Create a `.env` file in the root directory and add your credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

3. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

4. **Run the App**:
   ```bash
   flutter run
   ```

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── services/      # Audio, API, and Global Services
│   └── widgets/       # Shared UI (Navbar, Cards, Background)
├── features/
│   ├── auth/          # Sign In & Sign Up Screens
│   ├── dashboard/     # Main Grid & Player Stats
│   ├── map/           # OSM Interactive Map
│   └── pokemon/       # Monster Library & PokeAPI logic
└── main.dart          # App Entry & GoRouter config
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Developed with ❤️ by the **darknecrocities** team.
