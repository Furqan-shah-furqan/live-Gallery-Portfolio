# Live Systems Gallery — Flutter (Aura-Bento)

A complete responsive Flutter portfolio with a password-protected local Admin Control, rebuilt on the **Aura-Bento design system** (see `design.md`).

## Included

- **Aura-Bento design system**: neutral `#E9EBEF` canvas with drifting warm/cool aura mesh, white hyper-curved bento cards, pill action buttons, circular action tokens, amber/lavender pill badges, and a dark HUD live tracker (§4.5)
- **Concentric geometry everywhere**: nested radii follow `R_inner = R_outer − padding` (`AuraBento.innerRadius`)
- **Typography pairing**: Instrument Serif for conversational headlines, Inter for interface chrome (both bundled locally)
- **Six Aura palettes** in the Theme Studio — only aura hues + accent anchors swap per theme; structural tokens stay fixed
- Responsive interface with soft ambient shadows (low opacity, high blur) and no harsh borders
- Home dashboard with hero module, stats, and an expandable project gallery
- **Explore Live Work** opens a separate All Projects page with pill search + filter capsules
- Search and technology filtering on the All Projects page
- Empty-state message: **No Projects added Yet**
- Expandable Live Systems gallery:
  - the first project is landscape by default
  - other projects remain 100px wide on desktop
  - hovering another project expands it into landscape mode
  - the gallery scrolls horizontally when many projects are added
- Full project detail page with every screenshot in a slider (`BoxFit.contain`)
- Live project link launcher
- Password-protected **Admin Control**
- Add projects with name, details, tech stack, live link, and up to 8 screenshots
- Latest-project slider, project management grid, delete, Clear All, and starter-project restoration
- Local persistence through `shared_preferences` (+ IndexedDB on web)
- Complete Android, iOS, web, Windows, macOS, and Linux project runners

## Design system

The canonical spec lives in [`design.md`](design.md). Flutter tokens: `lib/core/aura_bento.dart`.
Key tokens: canvas `#E9EBEF`, ink `#121417`, secondary `#636A75`, blue action `#2A85FF`,
card radius `28px`, hero radius `36px`, pill `9999px`, focus ring `2px #2A85FF` offset `2px`.

## Admin password

```text
furqan123
```

Change it in:

```text
lib/pages/admin_access.dart
```

## Run cleanly

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

## Verify

```bash
flutter analyze
flutter test
```

## Build for web

```bash
flutter build web --release
```

## Deploy to Vercel

Vercel has no native Flutter support, so by default it produces no static site at all — that is why the live deployment 404s. The full pipeline is now pinned in [`vercel.json`](vercel.json):

- **Install command**: `sh ./scripts/build_web.sh install` — downloads a pinned Flutter SDK (default `3.24.5`, override with the `FLUTTER_VERSION` env var)
- **Build command**: `sh ./scripts/build_web.sh build` — runs `flutter pub get` + `flutter build web --release`
- **Output directory**: `build/web` (static)

`vercel.json` overrides any framework preset or build settings chosen in the Vercel dashboard, so no settings changes are needed: commit and redeploy from the Vercel dashboard (or run `vercel --prod`). The app is a single-entry Flutter app (no client-side routing), so no SPA rewrites are configured.

Screenshots are converted to Base64 and saved locally. For a production portfolio with many large screenshots, move image storage to Supabase Storage or another hosted file service.
