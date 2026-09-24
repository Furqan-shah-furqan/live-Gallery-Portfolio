# Aura-Bento Design System Specification (`design.md`)

> **Role & Purpose:** This document serves as the canonical single source of truth for engineering and design teams implementing the **Aura-Bento UI System**. It codifies visual design principles, design tokens, layout logic, component behaviors, accessibility requirements, and engineering standards derived from modern tactile, atmospheric Bento UI patterns. When prompting LLMs or coding assistants, pass this entire file into system instructions or project context to maintain absolute UI fidelity across all components.

---

## 1. Design Principles & Aesthetic Philosophy

### 1.1 Core Principles
* **Atmospheric Depth over Flatness:** Interfaces use soft chromatic mesh gradients ("Aura"), diffused outer ambient glows, and multi-layered elevation rather than harsh drop shadows or rigid skeuomorphic bevels.
* **Hyper-Curved Tactility:** Components favor high-radius squircles and continuous pill shapes, evoking tactile, physical tokens that feel ergonomic and touch-native.
* **Concentric Geometry:** Nested elements strictly adhere to concentric corner radius mathematical relationships:
  $$R_{\text{inner}} = R_{\text{outer}} - \text{padding}$$
  This eliminates optical tension and mismatched corner clipping.
* **Floating Structural Modularity (Bento):** Information is partitioned into isolated, self-contained capsules or cards that float seamlessly across neutral backdrops.
* **High-Contrast Anchors:** Colorful or pastel ambient backdrops are consistently grounded by deep neutral anchors (pure pitch black `#000000` / `#111111` or stark white `#FFFFFF`) for primary actions and key typography.

---

## 2. Design Tokens

### 2.1 Color Palette

```json
{
  "color": {
    "canvas": {
      "light": "#E9EBEF",
      "light-secondary": "#F3F4F6",
      "dark": "#0A0B0E"
    },
    "surface": {
      "white": "#FFFFFF",
      "white-translucent": "rgba(255, 255, 255, 0.85)",
      "card-muted": "#F5F6F8",
      "pill-neutral": "rgba(0, 0, 0, 0.05)",
      "pill-neutral-solid": "#E2E4E8",
      "dark-hud": "#0A0A0A"
    },
    "text": {
      "primary": "#121417",
      "secondary": "#636A75",
      "tertiary": "#8F96A3",
      "inverted": "#FFFFFF",
      "accent-orange": "#E86927",
      "accent-blue": "#2F80ED"
    },
    "accent": {
      "blue-action": "#2A85FF",
      "blue-glow": "rgba(42, 133, 255, 0.35)",
      "orange-indicator": "#FF7A00",
      "dark-action": "#111111"
    },
    "aura-gradient": {
      "mesh-sunset": "radial-gradient(at 0% 0%, #FF9A7B 0px, transparent 55%), radial-gradient(at 100% 100%, #5865F2 0px, transparent 65%), #FFA877",
      "mesh-ambient": "radial-gradient(circle at 10% 20%, rgba(255, 200, 150, 0.45) 0%, transparent 50%), radial-gradient(circle at 90% 80%, rgba(180, 190, 255, 0.5) 0%, transparent 60%)",
      "mesh-card": "linear-gradient(135deg, rgba(255, 178, 143, 0.7) 0%, rgba(186, 178, 255, 0.8) 100%)"
    }
  }
}
```

### 2.2 Typography Scale

The system pairs a high-character modern Serif/Display face for conversational queries and headlines with an ultra-clean Neo-Grotesque Sans-Serif for interface chrome, labels, and metadata.

```css
:root {
  /* Font Families */
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'SF Pro Display', sans-serif;
  --font-serif: 'Instrument Serif', 'Newsreader', Georgia, serif;

  /* Font Sizes & Line Heights */
  --text-display: 32px / 38px var(--font-serif);
  --text-headline: 24px / 30px var(--font-sans);
  --text-title: 18px / 24px var(--font-sans);
  --text-body: 15px / 22px var(--font-sans);
  --text-callout: 13px / 18px var(--font-sans);
  --text-caption: 11px / 14px var(--font-sans);
  --text-micro: 9px / 12px var(--font-sans);

  /* Font Weights */
  --font-weight-regular: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
}
```

### 2.3 Border Radii

```css
:root {
  --radius-xs: 8px;      /* Nested mini tags / inner chips */
  --radius-sm: 14px;     /* Floating inline indicators / small pills */
  --radius-md: 20px;     /* Mid-size inputs / secondary containers */
  --radius-lg: 28px;     /* Standard Bento card corners */
  --radius-xl: 36px;     /* Large Hero modules */
  --radius-full: 9999px; /* Action buttons, search inputs, pills */
}
```

### 2.4 Elevation & Shadows

```css
:root {
  /* Ambient card lift against neutral gray canvases */
  --shadow-ambient-sm: 0 4px 16px -2px rgba(17, 24, 39, 0.04);
  --shadow-ambient-md: 0 10px 30px -4px rgba(17, 24, 39, 0.07);
  --shadow-ambient-lg: 0 20px 48px -6px rgba(17, 24, 39, 0.10);

  /* Button and micro-capsule elevation */
  --shadow-capsule-lift: 0 8px 20px -3px rgba(0, 0, 0, 0.18);
  --shadow-glow-blue: 0 6px 18px 0 rgba(42, 133, 255, 0.35);

  /* Subtle border treatment instead of harsh lines */
  --inner-stroke-subtle: inset 0 1px 1px 0 rgba(255, 255, 255, 0.6);
  --inner-stroke-dark: inset 0 1px 1px 0 rgba(255, 255, 255, 0.12);
}
```

---

## 3. Layout, Grid & Positioning Standards

### 3.1 Bento Grid Specifications
* **Base Module Size:** Standard 2-column and 3-column asymmetric layout.
* **Card Gap:** Fixed `16px` on mobile screens ($<600\text{px}$), `20px` or `24px` on desktop ($>1024\text{px}$).
* **Canvas Margin:** Safe area padding of `20px` minimum around all viewports.
* **Component Aspect Ratios:** Small square widgets maintain `1:1`, landscape cards maintain `1.618:1` or `2:1`.

### 3.2 Z-Index Layering Order

| Layer | Token | Z-Index | Typical Content |
|---|---|---|---|
| Background Canvas | `z-canvas` | `0` | Canvas base color `#E9EBEF` |
| Gradient Aura | `z-aura` | `1` | Blurry background color patches |
| Card Container | `z-card` | `10` | Bento surfaces, white rounded cards |
| Content Flow | `z-content` | `20` | Typography, tags, metadata, media |
| Floating Anchors | `z-anchor` | `30` | Overlapping search triggers, floating avatars |
| Global Overlay / HUD | `z-hud` | `100` | Dynamic status HUDs, live activities |

### 3.3 Overlapping & Offset Anchoring Rules
* **Negative Margin Anchors:** Round badges (e.g., search icon circles, circular avatar icons) overlapping card edges must overlap by exactly $50\%$ of their diameter ($-\text{size} / 2$) or sit pegged to inside corners with `12px` padding.
* **Concentric Nesting Rule:** If container $A$ has `padding = 12px` and `border-radius = 28px`, child container $B$ must have `border-radius = 16px` ($28 - 12 = 16$).

---

## 4. Component Specifications & Variants

### 4.1 Input Capsule & Search Bar
* **Visual Form:** Full pill shape (`border-radius: 9999px`) on pure white `#FFFFFF` or elevated translucent white surface.
* **Height:** `52px` standard, `44px` compact.
* **Padding:** `0 20px 0 20px` (or `0 12px 0 18px` when icon button is embedded inside).
* **States:**
  * *Default:* Inset white surface, placeholder `#8F96A3`.
  * *Focused:* Double stroke highlight (outer outline `#2A85FF` at `2px`, offset `2px`).
  * *Disabled:* Surface `rgba(0, 0, 0, 0.03)`, text `#B0B5BD`.

### 4.2 Circular Action Token (Icon Buttons)
* **Dimensions:** `44px × 44px` (touch minimum) or `52px × 52px` (hero size).
* **Shape:** Perfectly circular (`border-radius: 50%`).
* **Variants:**
  * *Pitch Black:* Surface `#111111`, Icon `#FFFFFF`.
  * *Pure White:* Surface `#FFFFFF`, Icon `#121417`, Box-shadow `var(--shadow-ambient-md)`.
  * *Glass Neutral:* Surface `rgba(255, 255, 255, 0.65)`, backdrop blur `12px`.

### 4.3 Pill Badges & Prompt Chips
* **Dimensions:** Height `32px`, vertical padding `6px`, horizontal padding `14px`.
* **Typography:** `12px` or `13px`, medium weight (`500`).
* **Variants:**
  * *Neutral Gray:* Background `#ECEEF2`, text `#3D434C`.
  * *Warm Amber:* Background `#FEEED8`, text `#D96500`.
  * *Lavender Tint:* Background `#EDE8FE`, text `#6E56CF`.

### 4.4 Pill Action Button (Primary CTA)
* **Dimensions:** Height `48px`, full pill radius `9999px`.
* **Variants:**
  * *Black Anchor:* Solid `#000000` to `#161616` slight linear sheen, pure white text `14px` bold, icon aligned leading.
  * *Aurora Gradient Pill:* Background `linear-gradient(135deg, #FF8C66 0%, #6875F5 100%)`, white text `14px` bold.

### 4.5 Dynamic HUD / Live Tracker Card
* **Canvas:** `#0A0A0A` pure dark matte surface, radius `28px`.
* **Step Progression Track:**
  * Circle node diameter: `24px`.
  * Connecting bar: Height `4px`, radius `2px`.
  * Completed state: Solid `#2A85FF` fill with white checkmark (`1.5px` stroke).
  * Active state: Solid `#2A85FF` fill with outer pulse.
  * Pending state: Ring only (`2px` border `#2A85FF` or `rgba(255, 255, 255, 0.2)`), hollow core.

---

## 5. Spacing Scale & Touch Targets

The system uses an 8pt base grid with a 4pt sub-grid for fine adjustments:

| Token | Value | Applied To |
|---|---|---|
| `space-1` | `4px` | Micro gaps between icon and inline label |
| `space-2` | `8px` | Gap between prompt chips, internal tag margins |
| `space-3` | `12px` | Compact component padding, stacked text line margins |
| `space-4` | `16px` | Standard card internal grid gutters, input horizontal padding |
| `space-5` | `20px` | Card internal content padding (compact) |
| `space-6` | `24px` | Standard Bento card internal padding |
| `space-8` | `32px` | Section margins, hero element gaps |
| `space-10` | `40px` | Macro block separation |

* **Minimum Interactive Touch Target:** Every clickable surface (buttons, chips, icons) must resolve to at least $44\text{px} \times 44\text{px}$ of interactive hit area.

---

## 6. Alignment Standards & Optical Compensation

* **Cap-Height Icon Alignment:** When placing icons beside text strings, center the icon bounding box to the text **cap-height** rather than the full em-box bounding frame to prevent the icon from appearing visually sunken.
* **Negative Offset for Large Radii:** In cards with border radius $\ge 24\text{px}$, visual text margins must be pushed in by an extra $4\text{px}$ ($20\text{px} \to 24\text{px}$) to avoid visual crowding at corner tangents.
* **Optical Pill Centering:** For pills featuring leading circular avatars or glyphs, reduce the leading horizontal padding by $25\%$ relative to the trailing padding (e.g., `padding-left: 8px`, `padding-right: 14px`) to preserve perceived center-weighting.

---

## 7. Accessibility (a11y) & Focus Indicators

* **Contrast Ratios (WCAG 2.1 AA):**
  * Body copy and primary text on light cards must achieve a minimum contrast ratio of `4.5:1` against white backgrounds (current token `#121417` achieves `15.8:1`).
  * Secondary metadata (`#636A75`) maintains `5.1:1`.
  * Colored pills (Amber/Lavender) must use dark text tokens to guarantee `4.5:1` legibility over tint washes.
* **Focus States:**
  * Custom focus rings: `2px solid #2A85FF`, offset by `2px` from the component edge via `outline-offset: 2px`.
  * For dark HUD modules: `2px solid #FFFFFF` with `outline-offset: 2px`.

---

## 8. Quality Assurance & Pixel-Accuracy Checklist

- [ ] **Corner Consistency:** Are all concentric radii computed using $R_{\text{inner}} = R_{\text{outer}} - \text{padding}$?
- [ ] **Touch Areas:** Do all standalone circular buttons have at least $44\text{px} \times 44\text{px}$ hitboxes?
- [ ] **Shadow Subtlety:** Are dropshadows rendered with low opacity ($\le 10\%$) and high blur radii ($\ge 24\text{px}$) to maintain softness?
- [ ] **Font Pairing:** Is the conversational prompt formatted in the serif face with natural kerning, while functional UI elements remain in the clean sans-serif face?
- [ ] **Overflow & Clipping:** Do cards displaying background mesh gradients have `overflow: hidden` explicitly applied with hardware acceleration (`transform: translateZ(0)`) to eliminate jagged corner rendering?

---

## 9. Implementation Notes for Engineering

### 9.1 CSS Card Implementation Example

```css
.aura-bento-card {
  position: relative;
  background-color: var(--surface-white);
  border-radius: var(--radius-lg);
  padding: var(--space-6);
  box-shadow: var(--shadow-ambient-md);
  overflow: hidden;
  isolation: isolate; /* Create new stacking context for aura mesh */
}

.aura-bento-card::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--aura-gradient-ambient);
  opacity: 0.65;
  filter: blur(40px);
  z-index: -1;
  pointer-events: none;
}
```

### 9.2 Dark HUD Dynamic Progress Bar Example

```css
.hud-container {
  display: flex;
  align-items: center;
  background-color: var(--surface-dark-hud);
  border-radius: var(--radius-lg);
  padding: 18px 24px;
  color: var(--text-inverted);
}

.progress-node.completed {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  background-color: var(--accent-blue-action);
  display: flex;
  align-items: center;
  justify-content: center;
}

.progress-connector {
  flex: 1;
  height: 4px;
  background-color: var(--accent-blue-action);
  border-radius: 2px;
}
```

---

## 10. Flutter Implementation Map (this repository)

The Flutter translation of this system lives in:

* **`lib/core/aura_bento.dart`** — every §2 token as typed constants, plus the
  `innerRadius()` concentric-radius helper (§3.3) and `opticalInset()` (§6).
* **`lib/core/app_theme.dart`** — ThemeData wiring: pill inputs (§4.1), serif/sans
  pairing (§2.2), Dialog/Card radii (§2.3).
* **`lib/core/theme_controller.dart`** — six Aura palettes; only aura hues and
  accent anchors change per theme, all structural tokens stay fixed.
* **`lib/widgets/glass_surface.dart`** — `GlassSurface` bento card (§9.1),
  `PremiumButton` pill CTA (§4.4), `AuraBadge` (§4.3), `AuraCircularToken` (§4.2),
  `AuraHudTracker` (§4.5).
* **`lib/widgets/animated_mesh_background.dart`** — the z-canvas/z-aura layers
  (§3.2): `#E9EBEF` base with drifting warm/cool aura patches.

### Changelog
* **v1.0.0 (2026-09-23):** Initial consolidation of Aura-Bento visual system specifications based on multi-source component benchmarks. Codified concentric radius formulas, ambient color tokens, layout hierarchy, and touch target rules. Applied to this repository as the canonical UI system.
