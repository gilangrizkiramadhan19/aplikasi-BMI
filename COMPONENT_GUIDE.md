# BMI Maintenance - Component Guide

## Updated UI Components

### 1. Task List Card (`_TicketCard`)
Professional card design with status indicators and quick actions.

**Key Features:**
- Status icon in colored circle
- Title with location (2-line max)
- Status badge with appropriate color
- Reporter name and date
- "Lihat Detail" button for navigation

**Color Coding:**
- Open: Red (#E53935) - ⭕ Assignment icon
- In Progress: Orange (#F57C00) - 🔧 Build icon
- Resolved: Green (#43A047) - ✓ Check Circle icon
- Closed: Gray (#616161) - ✓ Archive icon

### 2. Detail Information Card (`_DetailCard`)
Consistent information display with icons and styling.

**Sections:**
- Location details
- Damage description
- Reporter information
- Assigned technician
- Materials used
- Timestamps (created/updated)
- Proof photo (when available)

### 3. Status Header
Modern gradient background with status badge and task title.

**Elements:**
- Circular icon container with status color
- Status label badge
- Task title
- Gradient background based on status

### 4. Action Buttons

#### OPEN Status
```
[Ambil Tugas] - Orange button
↓ Shows confirmation dialog
Status: OPEN → IN_PROGRESS
```

#### IN_PROGRESS Status
```
[Selesaikan Tugas] - Green button
↓ Navigates to complete screen
Status: IN_PROGRESS → RESOLVED (after photo upload)
```

#### RESOLVED Status
```
Status information display - Gray container
No action available from technician
```

#### CLOSED Status
```
Archive status information - Gray container
Historical record only
```

### 5. Filter Tabs
Horizontal scrollable status filter with active state highlighting.

**States:**
- Inactive: Transparent white background with white text
- Active: White background with blue text and border

**Labels:**
- Menunggu (Open)
- Diproses (In Progress)
- Selesai (Resolved)
- Arsip (Closed)

### 6. Photo Upload Area

**Empty State:**
- Large upload area with dashed border
- Upload icon and "Pilih Foto" text
- Helper text: "Tap untuk ambil dari kamera atau galeri"

**Filled State:**
- Image preview with shadow
- Close button (X) in top-right corner
- "Foto dipilah" badge in bottom-right
- "Ganti Foto" button for replacement

### 7. Info Messages

**Success (Green):**
```
Color: #43A047
Icon: check_circle
"Tugas berhasil diambil dan sedang diproses"
"Tugas berhasil diselesaikan dan disimpan!"
```

**Error (Red):**
```
Color: #E53935
Icon: error_outline
"Error: {message}"
```

**Info (Blue):**
```
Color: #1565C0
Icon: info_outline
"Upload foto perbaikan dan deskripsi untuk menyelesaikan tugas ini"
```

## Design System

### Colors
```
Primary: #1565C0 (Blue)
Success: #43A047 (Green)
Warning: #F57C00 (Orange)
Error: #E53935 (Red)
Info: #1565C0 (Blue)
Disabled: #616161 (Gray)
Text Primary: #1A1A1A (Dark Gray)
Text Secondary: #616161 (Gray)
Background: #F5F5F5 (Light Gray)
```

### Typography
```
Font Family: Default Material Design Font

Headlines:
- Title (20px): FontWeight.w700
- Subtitle (16px): FontWeight.w700
- Card Title (15px): FontWeight.w700

Body:
- Regular (13-14px): FontWeight.w500-600
- Small (12px): FontWeight.w400-500
- Label (11px): FontWeight.w600
```

### Spacing Scale
```
XS: 4px
SM: 8px
MD: 12px
LG: 16px
XL: 20px
2XL: 24px
3XL: 28px
4XL: 32px
```

### Border Radius
```
Small: 8px (input fields, small badges)
Medium: 10px (buttons, containers)
Large: 12px (cards, dialogs)
Extra Large: 14px (main card components)
Circle: 20-24px (icon badges)
```

### Shadows
```
Subtle: color.withOpacity(0.1), blurRadius: 10
Medium: color.withOpacity(0.2), blurRadius: 8, offset(0, 2)
Heavy: color.withOpacity(0.3), blurRadius: 12, offset(0, 4)
```

## Interactive States

### Buttons
```
Enabled: Full opacity, clickable
Disabled: 0.5 opacity, not clickable
Pressed: Elevation increases
Loading: Spinner overlay
```

### Input Fields
```
Default: Light border, light background
Focused: Blue border (2px), full opacity
Error: Red border
Disabled: Gray background, no interaction
```

### Cards
```
Default: Subtle shadow, hover effect
Pressed: Elevated shadow
Selected: Colored border, background tint
```

## Confirmation Dialog

```
┌─────────────────────────────────┐
│  Ambil Tugas                    │
├─────────────────────────────────┤
│ Apakah Anda yakin ingin mengambil │
│ tugas ini untuk dikerjakan?        │
├─────────────────────────────────┤
│ [Batal]  [Konfirmasi]           │
└─────────────────────────────────┘
```

## Empty States

```
┌───────────────────────────┐
│         ⬜ (Icon Circle)   │
│                           │
│    Tidak ada tugas         │
│  Belum ada tugas pada      │
│   kategori ini             │
└───────────────────────────┘
```

## Loading States

**Spinner:**
- CircularProgressIndicator
- Color: #1565C0 (Blue)
- Stroke Width: 3

**Button Loading:**
- Shows spinner inside button
- Spinner color: White
- Disabled state during loading

## Accessibility Features

1. **High Contrast**: Colors meet WCAG AA standards
2. **Touch Targets**: Minimum 48px for interactive elements
3. **Text Labels**: Clear, descriptive labels for all actions
4. **Error Messages**: Specific and actionable
5. **Icons + Text**: Always paired for clarity
6. **Focus States**: Visible focus indicators

## Responsive Behavior

- **Portrait**: Full-width cards, stacked layout
- **Landscape**: Adjusted spacing, side-by-side elements
- **Tablet**: Wider content area with padding
- **Scaling**: All elements scale appropriately with text size

## Dark Mode Support

Currently: Light theme only

Future consideration: Dark theme support with:
- Adjusted color scheme for dark backgrounds
- Reduced contrast for readability
- Alternative shadow effects
