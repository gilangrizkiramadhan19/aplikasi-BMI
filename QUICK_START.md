# 🚀 Quick Start Guide - Sistem Teknisi BMI

## 🎯 Overview
Aplikasi Sistem Teknisi Maintenance telah diupgrade dengan UI/UX profesional. Panduan ini menjelaskan cara menggunakan aplikasi.

## 📱 Screen Walkthrough

### 1️⃣ Login Screen
```
URL: http://localhost:3000/ (atau 3001)

Visual Elements:
├── Logo BMI (atas tengah)
├── Judul "Sistem Teknisi"
├── Email input (dengan icon mail)
├── Password input (dengan icon lock)
├── "Masuk ke Sistem" button (biru, full-width)
└── Demo credentials info

Cara Login:
• Email: teknisi@bmi.com
• Password: demo123 (atau apapun, ini demo mode)
• Click "Masuk ke Sistem"
```

---

### 2️⃣ Dashboard
```
URL: /dashboard

Visual Layout:
├── Header Sticky
│   ├── Logo BMI + Title
│   ├── "Tugas Baru" button (blue)
│   └── "Keluar" button (logout)
├── Statistics Cards (3)
│   ├── Menunggu Dikerjakan (amber) - 2 tasks
│   ├── Sedang Dikerjakan (blue) - 1 task
│   └── Sudah Selesai (green) - 1 task
├── Daftar Tugas Section
│   ├── Tabs (Menunggu, Diproses, Selesai, Arsip)
│   └── Task Cards Grid
│       ├── Task Title
│       ├── Machine Name + icon wrench
│       ├── Location + icon map-pin
│       ├── Date + icon clock
│       ├── Priority badge (Tinggi/Sedang/Rendah)
│       └── "Detail →" link
```

**Features**:
- ✅ Filter tasks by status (tabs)
- ✅ See task count di setiap status
- ✅ Click task card untuk lihat detail
- ✅ Responsive grid layout
- ✅ Hover effects on cards

**Try This**:
1. Click "Menunggu" tab
2. Lihat 2 tasks yang pending
3. Click "Diproses" tab
4. Lihat 1 task yang sedang dikerjakan
5. Click salah satu task card

---

### 3️⃣ Task Detail Page
```
URL: /dashboard/task/[id]

Example: /dashboard/task/1

Visual Layout:
├── Header
│   ├── "← Kembali ke Dashboard" link
│   └── Logo BMI
├── Task Title + Description
├── Status & Priority Cards
│   ├── Status badge (color-coded)
│   └── Priority badge (dengan description)
├── Information Cards
│   ├── Machine Info Card
│   │   ├── Machine name
│   │   ├── Location
│   │   └── Estimated time
│   └── Timeline Info Card
│       ├── Created date
│       └── Due date
├── Assignment Info Card
│   ├── Assigned to
│   └── Created by
└── Action Buttons (Dynamic)
    ├── For Pending: "Ambil Tugas" (blue button)
    ├── For In-Progress:
    │   ├── "Selesaikan Tugas" (green button)
    │   └── "Upload Bukti Foto" (slate button)
    └── For Completed: "✓ Tugas Selesai" (disabled)
```

**Status Codes**:
- 🟡 **Menunggu** (Pending) - Task belum diambil
- 🔵 **Diproses** (In-Progress) - Task sedang dikerjakan
- 🟢 **Selesai** (Completed) - Task sudah selesai
- ⚫ **Arsip** (Archived) - Task sudah di-archive

**Try This**:
1. Click "Ambil Tugas" button (jika pending)
   - Button akan change status ke "Sedang Dikerjakan"
   - Toast notification akan muncul
2. Click "Selesaikan Tugas" button (jika in-progress)
   - Status akan change ke "Selesai"
   - Toast notification akan muncul
3. Click "Upload Bukti Foto" untuk upload evidence

---

### 4️⃣ Upload Evidence Page
```
URL: /dashboard/task/[id]/upload

Example: /dashboard/task/1/upload

Visual Layout:
├── Header
│   └── "← Kembali ke Detail Tugas" link
├── Title + Description
├── Upload Area (Drag & Drop)
│   ├── Large drop zone
│   ├── "Seret foto ke sini" text
│   └── 2 Buttons:
│       ├── "Pilih dari Galeri" (blue)
│       └── "Buka Kamera" (outline)
├── Uploaded Images Grid (jika ada)
│   ├── Image thumbnails (1-3 per row)
│   ├── Delete button on hover
│   └── File info (name, size)
├── Notes Section
│   ├── Textarea (placeholder text)
│   └── "Catatan minimal 20 karakter" info
├── Tips Box (blue info)
│   └── Upload tips list
└── Action Buttons
    ├── "Submit Bukti Pekerjaan" (green, disabled jika kosong)
    └── "Batal" link
```

**Features**:
- ✅ Drag & drop images
- ✅ Click to select from gallery
- ✅ Camera button untuk mobile
- ✅ Image preview dengan delete option
- ✅ Show file size
- ✅ Textarea untuk catatan
- ✅ Validation (min 20 chars, min 1 photo)
- ✅ Submit button enable/disable based on validation

**Try This**:
1. Drag & drop an image
   - atau click "Pilih dari Galeri"
2. Image akan muncul di grid
3. Write notes (minimal 20 karakter)
4. Click "Submit Bukti Pekerjaan"
5. Toast notification success
6. Redirect ke task detail page

---

## 🎨 Design Features

### Colors Used
```css
Primary Blue:    #2563EB    (Buttons, actions, links)
Success Green:   #10b981    (Status selesai)
Warning Orange:  #f97316    (Status pending)
Gold Accent:     #D4A574    (Logo accent)
Slate Gray:      #64748b    (Secondary text, borders)
```

### Icons Used
```
📍 Map Pin       - Location
🔧 Wrench        - Machine/Tools
🕒 Clock         - Time/Date
📷 Camera        - Image upload
📸 Image Plus    - Gallery/Upload
✓  Check Circle  - Completed status
⚠️  Alert Circle - High priority
☰  Menu (optional)
```

### Cards & Spacing
- Border radius: 14px (14px = rounded)
- Shadows: Soft, subtle
- Spacing: 8px grid system
- Gaps between items

---

## ⌨️ Keyboard Navigation

```
Tab          - Move between fields/buttons
Enter        - Submit forms
Escape       - Close dialogs (jika ada)
Click        - Select buttons/links
```

---

## 📱 Mobile Experience

**Optimized for**:
- ✅ Portrait orientation
- ✅ Single column layout
- ✅ Full-width buttons
- ✅ Larger touch targets
- ✅ Readable text sizes
- ✅ Camera button untuk upload

---

## 🔄 User Flow Diagram

```
┌─────────────────┐
│   Login Page    │ ← Start here
│ (email + pass)  │
└────────┬────────┘
         │ (Click "Masuk ke Sistem")
         ↓
┌─────────────────────────────────┐
│      Dashboard                  │
│ (See all tasks with filters)    │
│ - Menunggu (2)                  │
│ - Diproses (1)                  │
│ - Selesai (1)                   │
│ - Arsip                         │
└────────┬────────────────────────┘
         │ (Click task card)
         ↓
┌──────────────────────────────────┐
│    Task Detail Page              │
│ - View full task info            │
│ - Status badges                  │
│ - Action buttons (dynamic)       │
│                                  │
│ [Ambil Tugas] button (if pending)│
│        ↓                         │
│ [Selesaikan] [Upload Bukti]      │
│ (if in-progress)                 │
└──────────┬───────────────────────┘
           │ (Click "Upload Bukti Foto")
           ↓
┌────────────────────────────────────┐
│    Upload Evidence Page            │
│ - Drag & drop images               │
│ - Write notes                      │
│ - [Submit Bukti Pekerjaan]        │
└────────────────────────────────────┘
           │ (Success)
           ↓
   Back to Task Detail
   (Status updated to "Selesai")
```

---

## 🧪 Testing Scenarios

### Scenario 1: Accept a Task
```
1. Go to Dashboard
2. Click "Menunggu" tab (see 2 pending tasks)
3. Click first task card
4. Click "Ambil Tugas" button
5. See toast: "Tugas berhasil diambil!"
6. Button changes to show "Sedang Dikerjakan"
7. See "Selesaikan Tugas" & "Upload Bukti Foto" buttons
```

### Scenario 2: Complete a Task with Evidence
```
1. Continue from Scenario 1 (task in-progress)
2. Click "Upload Bukti Foto"
3. Drag image (or click "Pilih dari Galeri")
4. Image appears in grid
5. Write notes (min 20 chars)
6. Click "Submit Bukti Pekerjaan"
7. Toast: "Bukti pekerjaan berhasil diunggah!"
8. Redirect to task detail
9. Click "Selesaikan Tugas"
10. Toast: "Tugas berhasil diselesaikan!"
11. Status changes to "Selesai"
```

### Scenario 3: Filter Tasks
```
1. Go to Dashboard
2. Default shows "Menunggu" tab (2 tasks)
3. Click "Diproses" tab (1 task)
4. Click "Selesai" tab (1 task)
5. Click "Arsip" tab (1 task)
6. Each tab shows different tasks
7. Task counts shown on tab labels
```

### Scenario 4: Validation on Upload
```
1. Go to upload page
2. Try to click "Submit Bukti Pekerjaan" without images
   - Button is disabled (grayed out)
3. Add image
   - Button still disabled (needs notes)
4. Add notes < 20 chars
   - Button still disabled
5. Add notes >= 20 chars
   - Button enabled (green, clickable)
6. Click Submit
   - Success!
```

---

## 🎯 Key Interactions

| Action | Visual Feedback |
|--------|-----------------|
| Hover button | Shadow increases, color slightly darker |
| Click button | Button disabled temporarily, spinner shown |
| Success | Green toast notification appears |
| Error | Red/orange toast notification appears |
| Upload image | Image grid updates with preview |
| Delete image | Removed from grid, info toast |
| Status change | Toast notification, button text updates |
| Tab switch | Content filters instantly |
| Link hover | Color changes to darker blue |

---

## 📝 Form Validation

### Login Form
```
✓ Email: Valid email format required
✓ Password: Any value (demo mode)
Submit: Button always enabled
```

### Notes Textarea
```
✓ Minimum 20 characters required
✓ Shows character indicator
✓ Submit button disabled if < 20 chars
```

### Image Upload
```
✓ Minimum 1 image required
✓ Only image files accepted
✓ Multiple images supported
✓ Delete individual images
✓ Submit button disabled if no images
```

---

## 🚨 Error Handling

```
❌ Upload kosong
   → Toast: "Silakan upload minimal 1 foto"
   → Submit button disabled

❌ Notes kosong/terlalu pendek
   → Toast: "Silakan isi catatan pekerjaan"
   → Submit button disabled

❌ Non-image file
   → Toast: "Hanya file gambar yang didukung"
   → File not added to grid

✅ Success actions
   → Green success toast
   → Redirect atau state update
```

---

## 💡 Tips & Tricks

1. **Multiple Uploads**: You can drag multiple images at once
2. **Delete Images**: Hover over image, click X button to remove
3. **Long Notes**: Textarea auto-wraps long text
4. **Responsive**: Resize browser to see mobile layout
5. **Tabs**: Each tab remembers its scroll position
6. **Back Navigation**: Click back link to return to previous page

---

## 🔄 Mock Data

The app uses mock data for demonstration:

```javascript
Tasks: {
  "1": { title: "Perawatan Mesin Produksi", status: "pending", ... },
  "2": { title: "Perbaikan Conveyor Belt", status: "in-progress", ... },
  "3": { title: "Penggantian Oli Mesin", status: "completed", ... },
  "4": { title: "Inspeksi Rutin Kompressor", status: "pending", ... },
  "5": { title: "Sertifikasi Peralatan", status: "archived", ... },
}
```

All changes are client-side only (no persistence).

---

## 📞 Troubleshooting

**Q: Button not responding?**
- A: Check browser console for errors. Refresh page if needed.

**Q: Images not uploading?**
- A: Check file is valid image (JPG, PNG). Max 5MB per file.

**Q: Toast notification not showing?**
- A: Check browser allows notifications. Look bottom-right of screen.

**Q: Page layout broken?**
- A: Try refreshing browser or clearing cache.

---

## 🎓 Next Steps

1. ✅ Understand the UI/UX (this guide)
2. 📱 Test on mobile/tablet
3. 🔗 Connect to backend (database, API)
4. 🔐 Implement real authentication
5. 💾 Add data persistence
6. 📤 Setup file storage for images

---

## 📚 Additional Resources

- **UI Upgrade Details**: See `UPGRADE_NOTES.md`
- **Summary**: See `UI_UPGRADE_SUMMARY.md`
- **Tech Stack**: Next.js 16, Tailwind CSS, shadcn/ui
- **Source Code**: Check `/app` directory

---

**Happy Using! 🚀**

For questions or feedback, refer to the documentation files or review the source code.
