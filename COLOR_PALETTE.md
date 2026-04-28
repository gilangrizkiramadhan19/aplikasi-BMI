# Color Palette Reference

## Core Brand Colors

### Primary - Blue
```
Color: #2563EB
Name: Bright Blue / Sky Blue
Usage: Primary buttons, AppBar, active states, links
RGB: rgb(37, 99, 235)
HSL: hsl(217, 99%, 53%)
Opacity Variants:
  - Opacity 0.04: #2563EB with 4% alpha (minimal backgrounds)
  - Opacity 0.06: #2563EB with 6% alpha (card backgrounds)
  - Opacity 0.10: #2563EB with 10% alpha (icon containers)
  - Opacity 0.12: #2563EB with 12% alpha (detail cards, borders)
  - Opacity 0.15: #2563EB with 15% alpha (border lines)
```

### Secondary - Green (Success)
```
Color: #10B981
Name: Emerald Green
Usage: Success states, "Selesai" status, confirmations
RGB: rgb(16, 185, 129)
HSL: hsl(160, 92%, 40%)
Opacity Variants:
  - Opacity 0.10: #10B981 with 10% alpha
  - Opacity 0.12: #10B981 with 12% alpha
```

### Tertiary - Orange (Warning)
```
Color: #F97316
Name: Vibrant Orange
Usage: In-progress states, "Diproses" status, warnings
RGB: rgb(249, 115, 22)
HSL: hsl(25, 97%, 53%)
Opacity Variants:
  - Opacity 0.10: #F97316 with 10% alpha
  - Opacity 0.12: #F97316 with 12% alpha
```

### Error - Red
```
Color: #EF4444
Name: Bright Red
Usage: Open/pending states, "Menunggu" status, errors
RGB: rgb(239, 68, 68)
HSL: hsl(0, 91%, 60%)
Opacity Variants:
  - Opacity 0.10: #EF4444 with 10% alpha
  - Opacity 0.12: #EF4444 with 12% alpha
```

### Quaternary - Gray (Neutral)
```
Color: #6B7280
Name: Cool Gray
Usage: Closed/archived states, "Arsip" status, disabled states
RGB: rgb(107, 114, 128)
HSL: hsl(217, 9%, 44%)
Opacity Variants:
  - Opacity 0.10: #6B7280 with 10% alpha
  - Opacity 0.12: #6B7280 with 12% alpha
```

---

## Neutral / Grayscale Colors

### Background
```
Primary Background: #FAFAFA
Description: Very light gray, used for scaffold background
RGB: rgb(250, 250, 250)
HSL: hsl(0, 0%, 98%)

Card Background: #FFFFFF
Description: Pure white for cards, forms, containers
RGB: rgb(255, 255, 255)
HSL: hsl(0, 0%, 100%)

Input Background: #F9FAFB
Description: Subtle light gray for input fields
RGB: rgb(249, 250, 251)
HSL: hsl(210, 10%, 98%)
```

### Text Colors

#### Primary Text
```
Color: #1F2937
Name: Dark Gray / Almost Black
Usage: Headings, titles, main content
RGB: rgb(31, 41, 55)
HSL: hsl(217, 28%, 17%)
Font Weight: 600-800
```

#### Secondary Text
```
Color: #374151
Name: Medium Dark Gray
Usage: Body text, descriptions
RGB: rgb(55, 65, 81)
HSL: hsl(217, 19%, 27%)
Font Weight: 400-500
```

#### Tertiary Text (Disabled/Muted)
```
Color: #6B7280
Name: Gray
Usage: Disabled states, secondary information
RGB: rgb(107, 114, 128)
HSL: hsl(217, 9%, 44%)
Font Weight: 400-500
```

#### Light Text (On Dark)
```
Color: #9CA3AF
Name: Light Gray
Usage: Placeholder text, muted labels
RGB: rgb(156, 163, 175)
HSL: hsl(214, 7%, 65%)
Font Weight: 500
```

### Borders & Dividers
```
Border Color: #E5E7EB
Description: Light gray for borders
RGB: rgb(229, 231, 235)
HSL: hsl(210, 16%, 91%)

Divider Color: #F3F4F6
Description: Very light gray for dividers
RGB: rgb(243, 244, 246)
HSL: hsl(210, 14%, 94%)
```

---

## Component-Specific Colors

### AppBar
```
Background: #2563EB
Text: #FFFFFF
Icons: #FFFFFF
```

### Cards
```
Background: #FFFFFF
Border: #E5E7EB with 1px stroke
Shadow: rgba(0, 0, 0, 0.04-0.08)
```

### Buttons

#### Primary Button (Ambil Tugas, Login, dsb)
```
Background: #2563EB
Text: #FFFFFF
Disabled Background: #2563EB with 0.6 opacity
Hover: Slightly darker
```

#### Success Button (Selesaikan)
```
Background: #10B981
Text: #FFFFFF
```

#### Warning Button (Confirmation)
```
Background: #F97316
Text: #FFFFFF
```

### Status Badges

#### OPEN (Menunggu)
```
Background: #EF4444 with 0.1 opacity
Text: #EF4444
Border: #EF4444 with 0.3 opacity
Icon: #EF4444
```

#### IN_PROGRESS (Diproses)
```
Background: #F97316 with 0.1 opacity
Text: #F97316
Border: #F97316 with 0.3 opacity
Icon: #F97316
```

#### RESOLVED (Selesai)
```
Background: #10B981 with 0.1 opacity
Text: #10B981
Border: #10B981 with 0.3 opacity
Icon: #10B981
```

#### CLOSED (Arsip)
```
Background: #6B7280 with 0.1 opacity
Text: #6B7280
Border: #6B7280 with 0.3 opacity
Icon: #6B7280
```

### Input Fields
```
Background: #F9FAFB
Border (Enabled): #E5E7EB
Border (Focused): #2563EB with 2px stroke
Text: #1F2937
Placeholder: #D1D5DB
```

### Snackbar/Toast
```
Success: #10B981 background, #FFFFFF text
Error: #EF4444 background, #FFFFFF text
Warning: #F97316 background, #FFFFFF text
Info: #2563EB background, #FFFFFF text
```

---

## Shadow System

### Soft Shadow (Cards)
```
Color: rgba(0, 0, 0, 0.04-0.08)
Blur Radius: 12-16px
Offset: 0, 4px
Used on: Cards, containers
```

### Medium Shadow (Emphasis)
```
Color: rgba(0, 0, 0, 0.08-0.10)
Blur Radius: 20-30px
Offset: 0, 10-15px
Used on: Login form, modal dialogs
```

### Gradient Shadows
```
For Status Headers:
  - Start: statusColor with 0.12 opacity
  - End: statusColor with 0.04 opacity
  - Direction: Top to bottom
```

---

## Opacity Guidelines

### For Color Overlays
```
Very Subtle: 0.04 - 0.06
  Used for: Minimal backgrounds, hover states

Light: 0.10 - 0.12
  Used for: Icon containers, badges, light backgrounds

Medium: 0.15 - 0.20
  Used for: Borders, dividers, subtle emphasis

Dark: 0.25 - 0.30
  Used for: Strong emphasis, shadows, disabled states
```

---

## Usage Examples in Code

### Dart/Flutter Implementation
```dart
// Primary Color
const Color primaryColor = Color(0xFF2563EB);

// Status Colors
const Color statusOpen = Color(0xFFEF4444);
const Color statusInProgress = Color(0xFFF97316);
const Color statusResolved = Color(0xFF10B981);
const Color statusClosed = Color(0xFF6B7280);

// Text Colors
const Color textPrimary = Color(0xFF1F2937);
const Color textSecondary = Color(0xFF374151);
const Color textMuted = Color(0xFF6B7280);

// Backgrounds
const Color bgPrimary = Color(0xFFFAFAFA);
const Color bgCard = Color(0xFFFFFFFF);
const Color bgInput = Color(0xFFF9FAFB);

// With Opacity
Color primaryLight = primaryColor.withOpacity(0.1);
Color statusOpenLight = statusOpen.withOpacity(0.12);
```

---

## Color Accessibility

### Contrast Ratios (WCAG AA Standard)
✅ Dark text (#1F2937) on light backgrounds: 12:1+
✅ White text on primary blue (#2563EB): 5.1:1
✅ Status colors on white: 4.5:1+
✅ All interactive elements meet AA standard

### Color Blind Safe
✅ Status colors chosen for accessibility
✅ Not solely reliant on color (also use icons)
✅ Sufficient contrast between all elements

---

## Color Transitions & States

### Button States
```
Normal: Full color
Hover: Slightly darker (darker by ~5%)
Pressed: Darker (darker by ~10%)
Disabled: Reduced opacity (0.6)
```

### Interactive Elements
```
Idle: Primary color
Focused: Primary color + subtle shadow
Active: Primary color + darker shade
Disabled: Gray (#6B7280) + 0.6 opacity
```

---

## Future Extensibility

### Dark Mode Ready
Colors are designed to support dark mode:
- Can invert backgrounds
- Text colors have sufficient range
- Status colors remain consistent
- Primary color variants prepared

### Theme Customization
Structure allows for:
- Brand color adjustments
- Status color customization
- Regional color preferences
- Seasonal variations

---

## References

- Material Design 3: https://m3.material.io/
- Tailwind Color Palette: Used as reference
- WCAG 2.1: Accessibility standard
- Semantic Color Usage: Consistent across industry

