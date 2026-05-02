# Image Zoom - Integration Guide

Panduan cepat untuk mengintegrasikan fitur zoom gambar di screen atau widget apapun.

---

## 🚀 Quick Start

### 1. Import Widget
```dart
import '../widgets/zoomable_image.dart';
```

### 2. Gunakan ZoomableImage untuk Single Image
```dart
ZoomableImage.network(
  'https://api.example.com/photo.jpg',
  width: double.infinity,
  height: 220,
  borderRadius: BorderRadius.circular(10),
)
```

### 3. Gunakan ZoomableImageGallery untuk Multiple Images
```dart
ZoomableImageGallery(
  images: _selectedImages.map((f) => ImageSource.fromFile(f)).toList(),
  itemWidth: 100,
  itemHeight: 100,
  borderRadius: BorderRadius.circular(10),
)
```

---

## 📌 Common Scenarios

### Scenario 1: Replace Image.network di Detail Screen
**Before:**
```dart
Image.network(
  imageUrl,
  width: double.infinity,
  height: 220,
  fit: BoxFit.cover,
)
```

**After:**
```dart
ZoomableImage.network(
  imageUrl,
  width: double.infinity,
  height: 220,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(10),
)
```

---

### Scenario 2: Display Local File with Zoom
**Code:**
```dart
ZoomableImage.file(
  selectedFile,
  width: 200,
  height: 200,
  borderRadius: BorderRadius.circular(10),
)
```

---

### Scenario 3: Multiple Images from List
**Code:**
```dart
List<File> photos = [...];

ZoomableImageGallery(
  images: photos.map((f) => ImageSource.fromFile(f)).toList(),
  itemWidth: 100,
  itemHeight: 100,
  borderRadius: BorderRadius.circular(8),
)
```

---

### Scenario 4: Custom Actions on Tap
**Code:**
```dart
ZoomableImage.file(
  file,
  onTap: () {
    print("Custom action");
    // Custom logic here
  },
)
```

---

## 🎯 ImageSourceType

### FromFile
```dart
ImageSource.fromFile(File file)
// Digunakan untuk local image files sebelum/sesudah upload
```

### FromNetwork
```dart
ImageSource.fromNetwork(String url)
// Digunakan untuk gambar dari API
```

### FromMemory
```dart
ImageSource.fromMemory(Uint8List bytes)
// Digunakan untuk web platform atau in-memory images
```

---

## 🔄 Migrating Existing Code

### Find All Image.network() Calls
```bash
grep -r "Image.network" lib/
```

### Find All Image.file() Calls
```bash
grep -r "Image.file" lib/
```

### Replace Pattern
1. Add import: `import '../widgets/zoomable_image.dart';`
2. Replace `Image.network()` → `ZoomableImage.network()`
3. Replace `Image.file()` → `ZoomableImage.file()`
4. Add optional styling: `borderRadius`, `onTap`

---

## 📋 Checklist untuk Integration

- [ ] Import `zoomable_image.dart`
- [ ] Identify semua `Image.network()` yang perlu zoom
- [ ] Identify semua `Image.file()` yang perlu zoom
- [ ] Replace dengan `ZoomableImage.network()` atau `.file()`
- [ ] Test zoom functionality pada masing-masing image
- [ ] Test network image loading (progress bar)
- [ ] Test file image zoom
- [ ] Test swipe navigation untuk multiple images

---

## 🧪 Testing

### Test File Image Zoom
```dart
// 1. Pick file dari gallery
// 2. Tap image → zoom viewer membuka
// 3. Pinch zoom in
// 4. Pan image
// 5. Double tap untuk reset
// 6. Back button close viewer
```

### Test Network Image Zoom
```dart
// 1. Navigate ke detail page
// 2. Wait for image load (check progress)
// 3. Tap image → zoom viewer
// 4. Pinch dan pan
// 5. Back button close
```

### Test Multiple Images
```dart
// 1. Upload 2-3 photos
// 2. Tap first photo → zoom viewer
// 3. Swipe ke photo kedua
// 4. Verify counter (Foto 2 dari 3)
// 5. Pinch zoom
// 6. Back button close
```

---

## 🐛 Troubleshooting

### Image tidak bisa di-zoom
- Pastikan menggunakan `ZoomableImage` bukan `Image`
- Check konsol untuk error messages

### Loading bar tidak muncul
- Loading bar hanya muncul untuk network images
- Pastikan imagenya benar-benar dari network (dimulai dengan `http`)

### Swipe tidak jalan
- Swipe hanya jalan untuk multiple images di ImageZoomViewer
- Pastikan pass `List<ImageSource>` dengan 2+ items

### Error loading network image
- Check URL validity
- Check ngrok-skip-browser-warning header (sudah included)
- Check network connectivity

---

## 📚 API Reference

### ZoomableImage

**Constructors:**
- `.file(File, ...options)`
- `.network(String url, ...options)`
- `.memory(Uint8List, ...options)`

**Parameters:**
- `BoxFit fit` - Image fit mode (default: cover)
- `double? width` - Container width
- `double? height` - Container height
- `BorderRadius? borderRadius` - Border radius
- `Widget? loadingBuilder` - Custom loading widget
- `VoidCallback? onTap` - Custom tap handler

---

### ImageZoomViewer

**Constructor:**
```dart
ImageZoomViewer({
  required List<ImageSource> images,
  int initialIndex = 0,
})
```

**Gesture Support:**
- Pinch zoom: 1x - 4x
- Pan: Full pan when zoomed
- Double tap: Toggle zoom
- Swipe: Navigate images

---

### ZoomableImageGallery

**Constructor:**
```dart
ZoomableImageGallery({
  required List<ImageSource> images,
  int? maxVisibleImages,
  double? itemWidth,
  double? itemHeight,
  BorderRadius? borderRadius,
})
```

---

## 💡 Best Practices

1. **Always provide size hints:**
   ```dart
   ZoomableImage.network(url, width: 200, height: 200)
   ```

2. **Use borderRadius untuk visual polish:**
   ```dart
   borderRadius: BorderRadius.circular(10)
   ```

3. **Handle network errors gracefully:**
   - errorBuilder sudah built-in di ZoomableImage
   - Akan menampilkan error widget otomatis

4. **Optimize network images:**
   - Pastikan backend mengirim reasonably-sized images
   - Use lazy loading untuk image lists

5. **Test gestures thoroughly:**
   - Test pinch zoom dengan 2 fingers
   - Test pan setelah zoom
   - Test double tap zoom toggle

---

## 🎓 Examples dari Implementasi

### TicketDetailScreen
```dart
// Import
import '../widgets/zoomable_image.dart';

// Usage
ZoomableImage.network(
  imageUrl,
  width: double.infinity,
  height: 220,
  fit: BoxFit.cover,
  borderRadius: BorderRadius.circular(10),
  loadingBuilder: Container(
    color: _BMI.blueLight,
    child: Center(child: CircularProgressIndicator()),
  ),
)
```

### CompleteTicketScreen
```dart
// Import
import '../widgets/zoomable_image.dart';

// Usage
ZoomableImageGallery(
  images: _selectedImages.map((f) => ImageSource.fromFile(f)).toList(),
  itemWidth: 100,
  itemHeight: 100,
)
```

---

Generated: 2026-04-30
Ready for Implementation ✅
