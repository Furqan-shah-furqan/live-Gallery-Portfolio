# Project Context: Live Systems Gallery

## Overview
**Live Systems Gallery** is a responsive Flutter web and cross-platform portfolio application, restyled on the **Aura-Bento design system** (`design.md`): a neutral `#E9EBEF` canvas with drifting warm/cool aura mesh, white hyper-curved bento cards, pill action buttons, circular action tokens, amber/lavender badges, dark HUD accents, and the Instrument Serif + Inter type pairing. It retains local admin management for projects.

---

## Key Features & Highlights

1. **Visual Design & Aesthetics**
   - **Aura-Bento tokens** (`lib/core/aura_bento.dart`): canonical colors, radii (8/14/20/28/36/full), 8pt spacing scale, ambient elevation, and the `innerRadius()` concentric-geometry helper (`R_inner = R_outer − padding`).
   - **Aura mesh canvas** (`AnimatedMeshBackground`): light `#E9EBEF` base with drifting warm/cool radial patches derived from the active palette (z-canvas → z-aura layering).
   - **Bento kit** (`GlassSurface`, `PremiumButton`, `AuraBadge`, `AuraCircularToken`, `AuraHudTracker`): white radius-28 cards, pill CTAs (black-anchor / aurora-gradient), 32px tinted badges, 44px circular action tokens, and the dark `#0A0A0A` HUD step tracker with `#2A85FF` nodes.
   - **Typography**: Instrument Serif for conversational display headlines, Inter for interface chrome. Both bundled in `assets/fonts/` and registered in `pubspec.yaml`.
   - **Accessibility**: WCAG AA text anchors, `2px #2A85FF` focus rings with `2px` offset, ≥44px touch targets, dark text tokens on tinted pill washes.
   - **Theme Studio**: 6 Aura palettes (Aura Sunset, Aurora Periwinkle, Porcelain Mist, Sage Atmosphere, Ember Aura, Dusk Lavender). Only aura hues and accent anchors change per theme — structural tokens stay fixed.

2. **Portfolio & Gallery System**
   - **Expandable Live Gallery**: first project landscape by default, 100px collapsed columns on desktop, hover/tap to expand, horizontal scrolling.
   - **Project Detail View**: metadata, description, live links, and an uncropped screenshot slider (`BoxFit.contain`).
   - **Explore Live Work (All Projects Page)**: real-time search and technology filtering with pill input capsules.
   - **Empty-state design**: `No Projects added Yet`.

3. **Admin Control & Content Management**
   - **Password Protected** (`lib/pages/admin_access.dart`), default password: `furqan123`
   - **Project Management**: add projects with title, live link, description, tech stack chips, and up to 8 screenshots (`file_picker`); delete, Clear All, restore starter projects.

4. **Persistence & Storage Architecture**
   - Hybrid persistence: `shared_preferences` (native) + IndexedDB (`idb_shim`, web).
   - Images stored as Base64 data URLs with backwards-compatible parsing (`images`, `screenshots`, `imageDataUrl`, legacy formats).

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
live_system_gallery/
├── design.md                         # Canonical Aura-Bento spec (source of truth)
├── assets/
│   ├── fonts/inter/                  # Inter 400–900 (+ italic)
│   ├── fonts/instrument/             # Instrument Serif regular + italic
│   └── images/cinematic-hero.png
├── lib/
│   ├── main.dart                     # App entry point, scopes, scroll behavior & MaterialApp
│   ├── core/
│   │   ├── aura_bento.dart           # Aura-Bento token system (colors, radii, spacing, shadows)
│   │   ├── app_theme.dart            # ThemeData builders, AppColors aliases, typography
│   │   └── theme_controller.dart     # 6 Aura palettes, SharedPreferences sync
│   ├── models/
│   │   └── project_model.dart        # ProjectModel & ProjectImageData (Base64 deserializers)
│   ├── services/
│   │   ├── project_store.dart        # ChangeNotifier holding project state
│   │   ├── project_persistence.dart  # Abstraction interface for storage
│   │   ├── project_persistence_web.dart # IndexedDB web storage implementation
│   │   └── project_persistence_shared.dart # Native fallback storage
│   ├── pages/
│   │   ├── home_page.dart            # Bento dashboard: hero, gallery, contact, footer
│   │   ├── projects_page.dart        # All projects view with search and tech filters
│   │   ├── project_detail_page.dart  # Full screenshot slider & specifications view
│   │   ├── theme_page.dart           # Theme Studio palette selector
│   │   ├── admin_access.dart         # Password authentication guard
│   │   └── admin_page.dart           # Admin dashboard, project creation modal & management
│   └── widgets/
│       ├── animated_mesh_background.dart # Aura canvas painter (z-canvas/z-aura)
│       ├── glass_surface.dart        # BentoSurface card, PillButton, AuraBadge, HUD kit
│       ├── liquid_gooey.dart         # Dock & filter pills (Aura-styled), page transition
│       ├── hero_cutout_section.dart  # Aura hero module with dark HUD tracker
│       ├── scroll_reveal.dart        # Viewport-aware reveal animations
│       └── project_card.dart         # Bento gallery card component
├── web/                              # Web runner & index.html configuration
├── run_web.bat                       # Quick launcher script for port 7357
└── pubspec.yaml                      # Dependencies, assets, and font registration
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
