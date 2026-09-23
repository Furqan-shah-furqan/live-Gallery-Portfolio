# Live Systems Gallery — Flutter

A complete responsive Flutter portfolio with a password-protected local Admin Control.

## Included

- Animated soft pastel mesh/orb background based on the supplied references
- Transparent cinematic hero artwork with smooth scroll parallax
- Theme Studio in the home navigation with the original theme plus five saved palette options
- Responsive glossy interface with no visible borders
- Home dashboard with project statistics and featured work
- **Explore Live Work** opens a separate All Projects page
- Search and technology filtering on the All Projects page
- Empty-state message: **No Projects added Yet**
- Expandable Live Systems gallery:
  - the first project is landscape by default
  - other projects remain 100px wide on desktop
  - hovering another project expands it into landscape mode
  - the gallery scrolls horizontally when many projects are added
- Full project detail page with every screenshot in a slider
- Tighter project-view spacing with screenshots kept uncropped
- Screenshots use `BoxFit.contain` in expanded cards and detail views
- Live project link launcher
- Password-protected **Admin Control**
- Add projects with name, details, tech stack, live link, and up to 8 screenshots
- Scrollable Add Project dialog with globally hidden scrollbars
- Latest-project slider, project management grid, delete, Clear All, and starter-project restoration
- Local persistence through `shared_preferences`
- Backward-compatible parsing for `images`, `screenshots`, `imageDataUrl`, and legacy data URLs
- Complete Android, iOS, web, Windows, macOS, and Linux project runners

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

Screenshots are converted to Base64 and saved locally. For a production portfolio with many large screenshots, move image storage to Supabase Storage or another hosted file service.
"# live-Gallery-Portfolio" 
