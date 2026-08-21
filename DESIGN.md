---
name: Aurelian POS
colors:
  surface: '#f7f9fb'
  surface-dim: '#d8dadc'
  surface-bright: '#f7f9fb'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f2f4f6'
  surface-container: '#eceef0'
  surface-container-high: '#e6e8ea'
  surface-container-highest: '#e0e3e5'
  on-surface: '#191c1e'
  on-surface-variant: '#404944'
  inverse-surface: '#2d3133'
  inverse-on-surface: '#eff1f3'
  outline: '#707974'
  outline-variant: '#bfc9c3'
  surface-tint: '#2b6954'
  primary: '#003527'
  on-primary: '#ffffff'
  primary-container: '#064e3b'
  on-primary-container: '#80bea6'
  inverse-primary: '#95d3ba'
  secondary: '#735c00'
  on-secondary: '#ffffff'
  secondary-container: '#fed65b'
  on-secondary-container: '#745c00'
  tertiary: '#242f41'
  on-tertiary: '#ffffff'
  tertiary-container: '#3a4558'
  on-tertiary-container: '#a7b2c9'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#b0f0d6'
  primary-fixed-dim: '#95d3ba'
  on-primary-fixed: '#002117'
  on-primary-fixed-variant: '#0b513d'
  secondary-fixed: '#ffe088'
  secondary-fixed-dim: '#e9c349'
  on-secondary-fixed: '#241a00'
  on-secondary-fixed-variant: '#574500'
  tertiary-fixed: '#d8e3fb'
  tertiary-fixed-dim: '#bcc7de'
  on-tertiary-fixed: '#111c2d'
  on-tertiary-fixed-variant: '#3c475a'
  background: '#f7f9fb'
  on-background: '#191c1e'
  surface-variant: '#e0e3e5'
typography:
  display-lg:
    fontFamily: Inter
    fontSize: 44px
    fontWeight: '600'
    lineHeight: 52px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Inter
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Inter
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  title-md:
    fontFamily: Inter
    fontSize: 18px
    fontWeight: '500'
    lineHeight: 24px
  body-md:
    fontFamily: Inter
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  body-sm:
    fontFamily: Inter
    fontSize: 14px
    fontWeight: '400'
    lineHeight: 20px
  label-caps:
    fontFamily: Inter
    fontSize: 12px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.05em
  price-display:
    fontFamily: Inter
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 32px
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 4px
  container-padding: 24px
  gutter: 16px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is engineered for upscale retail and high-end hospitality environments. It balances **Minimalism** with **Modern Corporate** precision to evoke a sense of calm, competence, and luxury. The goal is to transform a high-utility tool into a premium experience that aligns with the boutiques it serves.

The aesthetic prioritizes clarity and efficiency through:
- **Generous Whitespace:** Preventing visual clutter during high-traffic checkout moments.
- **Refined Precision:** Subtle transitions and thin, purposeful strokes.
- **Sophisticated Professionalism:** Moving away from "app-like" playfulness toward a specialized instrument feel.

## Colors

The palette is anchored in professional stability with accents of heritage and growth.

- **Primary (Emerald):** `#064E3B`. Used for the most critical actions: "Complete Sale," "Pay," and "Process." It signifies growth and trust.
- **Secondary (Gold):** `#D4AF37`. Used sparingly for high-value membership status, premium features, or subtle highlight icons.
- **Surface (Slate/Charcoal):** `#1E293B`. Used for sidebars and headers to provide a strong visual anchor and high contrast for text.
- **Background (Soft White):** `#F8FAFC`. A clean, cool-toned neutral that reduces eye strain compared to pure white.
- **Feedback:** Success uses the Primary Emerald; Error uses a muted Crimson (#991B1B) to maintain the sophisticated tone without appearing overly aggressive.

## Typography

This design system utilizes **Inter** for its exceptional legibility and neutral, systematic character. It ensures that complex data—like SKU numbers and currency—remain clear under various lighting conditions.

- **Tabular Figures:** Always use `tabular-nums` for price displays and quantity columns to ensure vertical alignment in lists.
- **Hierarchy:** Use `label-caps` for section headers (e.g., "ORDER SUMMARY") to provide clear visual breaks without increasing font size.
- **Weight:** Stick to 400 (Regular), 500 (Medium), and 600 (Semi-bold). Avoid 700+ to maintain the "sleek" and "refined" aesthetic.

## Layout & Spacing

The layout follows a **Fluid Grid** approach optimized for touch targets. Given the POS nature, horizontal space is divided into functional zones:

- **Navigation/Sidebar:** A fixed 80px-240px vertical bar for global actions.
- **Product Workspace:** A flexible center area using a 4-column grid (mobile) or 8-column grid (tablet).
- **Transaction Pane:** A fixed-width right sidebar (320px-400px) for the active bill.

**Touch Targets:** Minimum interactive area is 44x44px. All buttons and list items must adhere to this to ensure efficiency during high-speed checkout.

## Elevation & Depth

Depth is conveyed through **Tonal Layers** and **Ambient Shadows** to create a structured, tactile environment.

- **Level 0 (Background):** `#F8FAFC`. The base canvas.
- **Level 1 (Cards/Surface):** Pure White (#FFFFFF) with a very soft, diffused shadow (`0px 4px 12px rgba(30, 41, 59, 0.05)`).
- **Level 2 (Modals/Overlays):** Pure White with a more pronounced elevation (`0px 12px 32px rgba(30, 41, 59, 0.12)`).
- **Interaction:** Buttons should not move on the Z-axis (no "squishy" effects). Instead, use a subtle opacity shift (0.9) or a color darken (5%) on tap to maintain a "mechanical" feel.

## Shapes

The shape language is **Rounded**, striking a balance between modern friendliness and professional rigidity.

- **Components:** Standard buttons, input fields, and product cards use a 0.5rem (8px) radius.
- **Large Containers:** Transaction panes and modals use 1rem (16px) for a softer, more premium look.
- **Icons:** Use 24px bounding boxes with a 2px stroke weight. Avoid filled icons unless they represent an active state.

## Components

- **Primary Buttons:** High-contrast Emerald (#064E3B) with white text. Full-width in the transaction pane for "Checkout."
- **Secondary Buttons:** Ghost style with a 1px Slate (#E2E8F0) border. Used for "Add Discount" or "Hold Order."
- **Product Cards:** Minimalist white containers. Image takes the top half, name and price on the bottom. No borders; use Level 1 shadows for separation.
- **Input Fields:** Floating labels with a 1px border that shifts from Light Slate to Primary Emerald on focus.
- **Line Items:** High-density lists with a subtle bottom divider (#F1F5F9). The price should be bold and right-aligned.
- **Chips:** Used for "Table Numbers" or "Order Tags." Subtle Slate backgrounds with darker text; no shadows.
- **Numerical Keypad:** Integrated into the transaction pane with large, clean sans-serif numbers. Key dividers are subtle 1px lines rather than individual buttons to maintain a "glass-slab" feel.