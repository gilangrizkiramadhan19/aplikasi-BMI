# Multiple Photo Upload Feature

## Overview
This update enables users to upload and attach up to 3 photos to task completion reports instead of just 1. Photos can be viewed in detail with zoom functionality.

## Changes Made

### 1. **submit_pm_report_screen.dart**
   - Changed single image storage from `File? _selectedImage` to `List<File> _selectedImages`
   - Changed `Uint8List? _selectedImageBytes` to `List<Uint8List> _selectedImageBytes`
   - Added `maxPhotos = 3` constant
   - Updated `_compressAndSetImage()` to append to list instead of replacing and check max limit
   - Modified UI to show photo grid with thumbnails instead of single preview
   - Added ability to remove individual photos
   - Added "Tambah" (Add) button to upload more photos (visible when under limit)
   - Each photo shows a zoom icon to view in detail
   - Updated compression info display to show all photos' compression stats

### 2. **photo_zoom_viewer.dart** (NEW FILE)
   - Created new component for viewing photos in detail with zoom capability
   - Features:
     - Full-screen photo viewer with black background
     - Swipe between multiple photos
     - Double-tap to zoom in/out
     - Pinch-zoom capability via InteractiveViewer
     - Photo counter showing "Foto X dari Y"
     - Close button to return to form

### 3. **schedule_provider.dart**
   - Updated `submitReport()` method signature
   - Changed `String filePath` to `List<String> filePaths`
   - Changed `Uint8List? fileBytes` to `List<Uint8List>? fileBytes`

### 4. **api_service.dart**
   - Updated `submitScheduleReport()` method signature
   - Changed `String filePath` to `List<String> filePaths`
   - Changed `Uint8List? fileBytes` to `List<Uint8List>? fileBytes`
   - Modified multipart form to send multiple files with field name 'photos' (array support)
   - Updated debug logs to show photo count

## User Experience

### Before
- User could only upload 1 photo
- No zoom capability
- "Ganti Foto" button replaced the photo

### After
- User can upload up to 3 photos
- Photos displayed in grid layout with thumbnails
- Each photo has:
  - Remove (X) button in top-right
  - Zoom icon in bottom-right indicating tap to view
- When clicked, photo opens in full-screen zoom viewer
- Can swipe/pan between multiple photos in detail view
- Double-tap zooms in/out
- Pinch-zoom for precise control
- Counter shows "Foto X dari Y" in detail view
- Compression stats show data for all uploaded photos

## Validation
- Minimum: 1 photo required (same as before)
- Maximum: 3 photos allowed
- Error message shown if trying to add more than 3 photos

## Backend Integration
The API backend should be updated to accept multiple photos via the 'photos' field in the multipart form data, or updated to accept individual 'photo_1', 'photo_2', 'photo_3' fields if that's preferred.
