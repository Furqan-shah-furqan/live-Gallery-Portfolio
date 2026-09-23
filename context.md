# Project Context: Live Systems Gallery

## Overview
**Live Systems Gallery** is a responsive Flutter web and cross-platform portfolio application. It is engineered with a glossy glassmorphism aesthetic, soft pastel mesh and liquid-gooey background animations, scroll parallax, multi-theme palette switching, and local admin management for projects.

---

## Key Features & Highlights

1. **Visual Design & Aesthetics**
   - **Modern Glassmorphism**: Translucent surfaces (`GlassSurface`), frosted glass borders, subtle shadows, and soft ambient reflections.
   - **Liquid Gooey & Animated Mesh**: Custom fluid animations using shaders and matrix canvases (`LiquidGooeyBackground`, `AnimatedMeshBackground`).
   - **Theme Studio**: Multi-theme system with 6 distinct color palettes:
     - `Original Coral` (Sunset warm palette)
     - `Warm Plum`
     - `Teal Sand`
     - `Forest Mist`
     - `Burgundy Coffee`
     - `Rose Cocoa`
   - **Parallax Hero**: Transparent cinematic hero graphic (`assets/images/cinematic-hero.png`) reacting to scroll position.
   - **Global Custom Scroll Behavior**: Scrollbars hidden via `NoScrollbarBehavior` while allowing pointer drag across trackpads, mice, and touch devices.

2. **Portfolio & Gallery System**
   - **Expandable Live Gallery**:
     - The first project is rendered landscape by default.
     - Collapsed cards display at compact widths on desktop and smoothly expand to landscape on hover or tap.
     - Horizontal smooth scrolling support when projects grow.
   - **Project Detail View**:
     - Dedicated page displaying project metadata, full description, live links, technology tags, and an uncropped, high-resolution screenshot slider (`BoxFit.contain`).
   - **Explore Live Work (All Projects Page)**:
     - Full list view with real-time text search and technology stack tag filtering.
     - Empty-state design (`No Projects added Yet`).

3. **Admin Control & Content Management**
   - **Password Protected**: Guarded by a PIN/password screen (`lib/pages/admin_access.dart`).
     - Default access password: `furqan123`
   - **Project Management**:
     - Add new projects with title, live link, detailed description, technology stack chips, and up to 8 screenshot uploads (`file_picker`).
     - Real-time screenshot preview with deletion/reordering before publishing.
     - Edit, delete individual projects, or clear all entries.
     - Option to restore starter showcase projects.

4. **Persistence & Storage Architecture**
   - Hybrid persistence layer supporting Web and Native environments.
   - Local storage powered by `shared_preferences` and Web IndexedDB (`idb_shim`).
   - Images are stored as Base64 data URLs with backwards compatibility parsing (`imageDataUrl`, `screenshots`, legacy formats).

---

## Technology Stack & Dependencies

- **Language & Framework**: Dart `^3.4.0` / Flutter SDK (Material 3 enabled)
- **Key Packages (`pubspec.yaml`)**:
  - `shared_preferences: ^2.3.5` — Local key-value storage for settings and theme preference.
  - `idb_shim: ^2.6.0+5` — IndexedDB wrapper for web storage.
  - `file_picker: ^8.3.7` — Client-side screenshot image selection.
  - `url_launcher: ^6.3.1` — External navigation to live project demos.
  - `cupertino_icons: ^1.0.8` — Supplemental icon assets.

---

## Directory Structure & Code Organization

```
live_system_gallery_updated_themes_parallax/
├── assets/
│   └── images/
│       └── cinematic-hero.png        # Transparent hero parallax artwork
├── lib/
│   ├── main.dart                     # App entry point, scopes, scroll behavior & MaterialApp
│   ├── core/
│   │   ├── app_theme.dart            # ThemeData builders, AppColors, typography tokens
│   │   └── theme_controller.dart     # Palette state manager, SharedPreferences sync
│   ├── models/
│   │   └── project_model.dart        # ProjectModel & ProjectImageData (Base64 deserializers)
│   ├── services/
│   │   ├── project_store.dart        # ChangeNotifier holding project state
│   │   ├── project_persistence.dart  # Abstraction interface for storage
│   │   ├── project_persistence_web.dart # IndexedDB web storage implementation
│   │   └── project_persistence_shared.dart # Native fallback storage
│   ├── pages/
│   │   ├── home_page.dart            # Landing dashboard, hero parallax, stats & gallery
│   │   ├── projects_page.dart        # All projects view with search and tech filters
│   │   ├── project_detail_page.dart  # Full screenshot slider & specifications view
│   │   ├── theme_page.dart           # Theme Studio palette selector
│   │   ├── admin_access.dart         # Password authentication guard
│   │   └── admin_page.dart           # Admin dashboard, project creation modal & management
│   └── widgets/
│       ├── animated_mesh_background.dart # Soft animated mesh background painter
│       ├── glass_surface.dart        # Frosted glassmorphism container
│       ├── liquid_gooey.dart         # Fluid organic morphing visuals
│       └── project_card.dart         # Expandable gallery card component
├── web/                              # Web runner & index.html configuration
├── run_web.bat                       # Quick launcher script for port 7357
└── pubspec.yaml                      # Dependencies and asset declarations
```

---

## How to Run & Verify

- **Run Web (Development)**:
  ```bash
  flutter run -d chrome --web-port 7357
  ```
  App is served at: `http://localhost:7357`

- **Static Analysis & Test**:
  ```bash
  flutter analyze
  flutter test
  ```

- **Production Web Build**:
  ```bash
  flutter build web --release
  ```
