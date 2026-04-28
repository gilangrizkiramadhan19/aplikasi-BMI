# Design Implementation Guide

## Overview

Aplikasi Sistem Teknisi Maintenance telah mengalami redesign menyeluruh untuk mencapai standar Material Design 3 dan tampilan yang lebih profesional. Panduan ini menjelaskan implementasi dan cara merawat design system.

---

## 🎯 Design Goals Achieved

✅ **Professional Appearance**: Aplikasi terlihat seperti enterprise-grade app
✅ **Modern Aesthetics**: Clean, minimalist, contemporary design
✅ **Consistent Theming**: Unified color system di seluruh aplikasi
✅ **Better UX**: Improved spacing, typography, interactions
✅ **Material Design 3**: Following latest Google design standards
✅ **Accessible**: WCAG AA compliant contrast ratios
✅ **Maintainable**: Clear design tokens and guidelines

---

## 📚 Documentation Files

### 1. **COLOR_PALETTE.md**
   - Detailed color system dengan hex codes
   - Opacity variants untuk setiap color
   - Component-specific color usage
   - Accessibility information
   - Dart/Flutter code examples

### 2. **DESIGN_UPDATES.md**
   - Summary of all design changes
   - Screen-by-screen improvements
   - Component enhancements
   - Typography system
   - Animation details

### 3. **UI_IMPROVEMENTS_SUMMARY.md**
   - Before & after comparison
   - Detailed visual hierarchy changes
   - CSS-like styling specifications
   - Feature checklist
   - Quality improvements

---

## 🛠️ How to Use & Maintain

### Primary Color Changes

#### Sebelum
```dart
const Color primaryColor = Color(0xFF1565C0);
```

#### Sesudah
```dart
const Color primaryColor = Color(0xFF2563EB);
// Semua referensi #1565C0 sudah diupdate ke #2563EB
```

**Files Updated:**
- `lib/main.dart` - Theme configuration
- `lib/screens/login_screen.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/ticket_list_screen.dart`
- `lib/screens/ticket_detail_screen.dart`

### Status Colors

#### Implementation Pattern

```dart
Color _getStatusColor(String status) {
  switch (status) {
    case 'OPEN':
      return const Color(0xFFEF4444);      // Red
    case 'IN_PROGRESS':
      return const Color(0xFFF97316);      // Orange
    case 'RESOLVED':
      return const Color(0xFF10B981);      // Green
    case 'CLOSED':
      return const Color(0xFF6B7280);      // Gray
    default:
      return const Color(0xFF9CA3AF);      // Light Gray
  }
}

String _getStatusLabel(String status) {
  switch (status) {
    case 'OPEN':
      return 'Menunggu';
    case 'IN_PROGRESS':
      return 'Diproses';
    case 'RESOLVED':
      return 'Selesai';
    case 'CLOSED':
      return 'Selesai (Arsip)';
    default:
      return status;
  }
}

IconData _getStatusIcon(String status) {
  switch (status) {
    case 'OPEN':
      return Icons.assignment_late;
    case 'IN_PROGRESS':
      return Icons.auto_awesome;
    case 'RESOLVED':
      return Icons.check_circle_outline;
    case 'CLOSED':
      return Icons.check_circle_outline;
    default:
      return Icons.help_outline;
  }
}
```

---

## 🎨 Component Styling Patterns

### Cards

```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),  // 16px radius
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),  // 6% opacity
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
    border: Border.all(
      color: Colors.grey.withOpacity(0.1),
      width: 1,
    ),
  ),
  child: // Your content here
)
```

### Detail Cards with Icons

```dart
Container(
  padding: const EdgeInsets.all(14),
  decoration: BoxDecoration(
    color: color.withOpacity(0.06),        // 6% tinted background
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: color.withOpacity(0.15),      // 15% colored border
      width: 1,
    ),
  ),
  child: Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),  // 12% icon background
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    ],
  ),
)
```

### Status Badges

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
  decoration: BoxDecoration(
    color: statusColor.withOpacity(0.1),     // 10% background
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: statusColor.withOpacity(0.3),   // 30% border
      width: 0.5,
    ),
  ),
  child: Text(
    statusLabel,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: statusColor,
    ),
  ),
)
```

### Buttons

```dart
SizedBox(
  width: double.infinity,
  height: 50,
  child: ElevatedButton(
    onPressed: () {},
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF2563EB),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),  // 10px radius
      ),
      elevation: 0,  // Flat design, no elevation
      padding: const EdgeInsets.symmetric(vertical: 12),
    ),
    child: const Text(
      'Button Text',
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    ),
  ),
)
```

---

## 📏 Spacing Guidelines (8px Grid System)

Semua spacing HARUS menggunakan kelipatan 8px:

```dart
// ✅ CORRECT
const EdgeInsets.all(8)                    // 8px
const EdgeInsets.all(12)                   // 8 + 4
const EdgeInsets.all(16)                   // 8 + 8
const EdgeInsets.all(20)                   // 8 + 8 + 4
const SizedBox(height: 24)                 // 8 + 8 + 8
const SizedBox(height: 32)                 // 8 + 8 + 8 + 8

// ❌ WRONG
const EdgeInsets.all(10)                   // Not multiple of 8
const EdgeInsets.all(15)                   // Not multiple of 8
const EdgeInsets.all(13)                   // Not multiple of 8
const SizedBox(height: 25)                 // Not multiple of 8
```

### Common Spacing Values

```
8px   - Minor spacing between small elements
12px  - Component internal padding
14px  - Card padding (sometimes)
16px  - Standard padding (most common)
20px  - Header padding, larger components
24px  - Section padding
28px  - Form container padding
32px  - Major section gaps
40px  - Large gaps
48px  - Very large spacing
56px  - Screen padding (large gaps)
```

---

## 📱 Typography System

### Font Weights

```dart
// Light content
fontWeight: FontWeight.w400  // 400

// Body text
fontWeight: FontWeight.w500  // 500
fontWeight: FontWeight.w600  // 600

// Important content
fontWeight: FontWeight.w700  // 700 (bold)

// Headings
fontWeight: FontWeight.w800  // 800 (extra bold)
```

### Font Sizes & Weights

```dart
// Display
fontSize: 32, fontWeight: FontWeight.w700    // displayLarge

// Heading
fontSize: 20, fontWeight: FontWeight.w700    // headlineSmall

// Titles
fontSize: 18, fontWeight: FontWeight.w700    // titleLarge
fontSize: 16, fontWeight: FontWeight.w600    // titleMedium

// Body
fontSize: 16, fontWeight: FontWeight.w500    // bodyLarge
fontSize: 14, fontWeight: FontWeight.w400    // bodyMedium

// Labels & captions
fontSize: 12, fontWeight: FontWeight.w600    // labels
fontSize: 11, fontWeight: FontWeight.w600    // small labels
```

### Letter Spacing

```dart
// Headings (tighter)
letterSpacing: -0.5,  // Headings to be more compact

// Labels (expanded)
letterSpacing: 0.3,   // Small labels untuk emphasis

// Normal
letterSpacing: 0,     // Default, most text
```

---

## 🎞️ Animations

### Menu Card Scale Animation

```dart
class _MenuCard extends StatefulWidget {
  // ...
  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),  // 150ms
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        _controller.forward();
      },
      onTapUp: (_) {
        _controller.reverse();
        // Perform action
      },
      onTapCancel: () {
        _controller.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: // Your card content
      ),
    );
  }
}
```

---

## 🔄 Common Updates & Maintenance

### Adding a New Status Color

1. **Update _getStatusColor()**
   ```dart
   case 'NEW_STATUS':
     return const Color(0xFF......);  // Add color
   ```

2. **Update _getStatusLabel()**
   ```dart
   case 'NEW_STATUS':
     return 'Indonesian Label';
   ```

3. **Update _getStatusIcon()**
   ```dart
   case 'NEW_STATUS':
     return Icons.icon_name;  // Use outline icons
   ```

4. **Document in COLOR_PALETTE.md**

### Changing Primary Color

⚠️ **IMPORTANT**: Primary color is used in:
- `lib/main.dart` - Theme seedColor
- All screen AppBars
- Primary buttons
- Links and active states
- Icon highlights

Find and replace all instances:
```bash
grep -r "0xFF2563EB" lib/
```

Then update consistently.

### Adding New Component

1. Extract styling patterns to reusable method
2. Use design tokens (colors from COLOR_PALETTE.md)
3. Follow 8px grid system for spacing
4. Ensure accessibility (contrast ratios)
5. Document in DESIGN_UPDATES.md

---

## ✅ Quality Checklist

Before committing changes:

- [ ] All colors use defined palette
- [ ] Spacing follows 8px grid
- [ ] Border radius uses 12px, 16px, or 20px
- [ ] Shadow follows soft shadow pattern
- [ ] Typography matches system
- [ ] Icons are outlined style
- [ ] Button heights minimum 48px for touch
- [ ] Contrast ratios meet WCAG AA
- [ ] Animations are smooth (150-250ms)
- [ ] No hardcoded colors (use COLOR_PALETTE)

---

## 🚀 Future Enhancements

### Planned Features

1. **Dark Mode Support**
   - Color variants prepared
   - Needs implementation in ThemeData

2. **Localization**
   - Status labels can be easily localized
   - Currently hardcoded Indonesian strings

3. **Theme Customization**
   - Primary color easily changeable
   - Status colors can be customized
   - Typography scales configurable

4. **Animations**
   - Page transitions (fade, slide)
   - Loading animations
   - Success/error feedback animations

---

## 📖 References & Standards

- **Material Design 3**: https://m3.material.io/
- **Flutter Material Library**: https://api.flutter.dev/flutter/material/material-library.html
- **WCAG 2.1 AA Compliance**: https://www.w3.org/WAI/WCAG21/quickref/
- **Dart Style Guide**: https://dart.dev/guides/language/effective-dart/style

---

## 🤝 Team Guidelines

### When Adding Features

1. **Respect Design System**
   - Use existing colors and components
   - Follow spacing and typography rules
   - Don't introduce new color without approval

2. **Maintain Consistency**
   - Use existing patterns
   - Follow current conventions
   - Update documentation

3. **Accessibility First**
   - Check contrast ratios
   - Ensure touch targets are 48px minimum
   - Test with accessibility tools

4. **Code Quality**
   - Extract reusable components
   - Use meaningful variable names
   - Comment complex styling logic

---

## 📞 Design Support

**Color Questions?**
→ See COLOR_PALETTE.md for hex codes and opacity variants

**Component Styling?**
→ Check examples in this file or DESIGN_UPDATES.md

**Typography Issues?**
→ Refer to Typography System section above

**Questions about Changes?**
→ See UI_IMPROVEMENTS_SUMMARY.md for before/after

---

## Version History

**v2.0** - Material Design 3 Redesign (Current)
- Modern color system
- Enhanced components
- Improved typography
- Animations & transitions

**v1.0** - Initial Implementation
- Functional UI
- Basic styling
- Gradient backgrounds

---

