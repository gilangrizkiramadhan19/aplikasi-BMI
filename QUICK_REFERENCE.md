# BMI Maintenance - Quick Reference Guide

## Color Palette Quick Reference

### Status Colors
| Status | Color | Hex | When Used | Button |
|--------|-------|-----|-----------|--------|
| 🔴 Menunggu (Open) | Red | #E53935 | Task waiting for acceptance | — |
| 🟠 Diproses (In Progress) | Orange | #F57C00 | Task being worked on | [Ambil Tugas] |
| 🟢 Selesai (Resolved) | Green | #43A047 | Task completed | [Selesaikan Tugas] |
| ⚪ Arsip (Closed) | Gray | #616161 | Task in history | — |
| 🔵 Primary | Blue | #1565C0 | Buttons, navigation | All buttons |

## Screen Flow

```
HOME SCREEN
    │
    ├─► [Lihat Tugas] (Task List)
    │        │
    │        ├─ Scroll through tasks
    │        ├─ Filter by status (tabs)
    │        ├─ Search by location/title
    │        └─ Tap card ──────────────┐
    │                                 │
    ├─► [Buat Laporan] ────────────┐  │
    │   (Create Report)            │  │
    │                              ▼  ▼
    └─ [Refresh]              DETAIL SCREEN
                              (Task Details)
                                   │
                         Status: OPEN
                                   │
                         ┌─────────▼──────────┐
                         │   [Ambil Tugas]    │
                         │   (Orange Button)  │
                         └─────────┬──────────┘
                                   │
                         Confirm Dialog
                                   │
                                   ▼
                         Status: IN_PROGRESS
                                   │
                         ┌─────────▼──────────┐
                         │[Selesaikan Tugas]  │
                         │  (Green Button)    │
                         └─────────┬──────────┘
                                   │
                                   ▼
                      COMPLETE TASK SCREEN
                      (Upload Photo & Details)
                                   │
                         ┌─────────▼──────────┐
                         │ Select Photo       │
                         │ Add Description    │
                         │ [Selesaikan & Simpan]
                         └─────────┬──────────┘
                                   │
                                   ▼
                         Status: RESOLVED
                         (Awaiting Validation)
                                   │
                                   ▼
                         Status: CLOSED
                         (Historical Record)
```

## Button Reference

### Primary Buttons (Full Width)
```
┌─────────────────────────────────────┐
│  [Ambil Tugas]  - Accept Task       │  Orange
│  [Selesaikan Tugas] - Complete      │  Green
│  [Selesaikan & Simpan] - Save       │  Green
└─────────────────────────────────────┘
```

### Secondary Buttons
```
┌─────────────────────────────────────┐
│  [Ganti Foto] - Change Photo        │  Outlined Blue
│  [Kembali] - Go Back                │  Outlined Blue
└─────────────────────────────────────┘
```

## Task Card Layout

```
┌─ STATUS ICON ─────────────────── STATUS BADGE ─┐
│  🎯 (Colored Circle)         [Menunggu/Diproses]│
│                                                 │
│  Task Title                                     │
│  📍 Location Name                               │
├─────────────────────────────────────────────────┤
│  👤 Pelapor: John Doe    📅 27 Apr 2026        │
├─────────────────────────────────────────────────┤
│         [Lihat Detail →]                        │
└─────────────────────────────────────────────────┘
```

## Form Fields Reference

### Photo Upload Field
- **Empty**: Tap to open camera/gallery
- **Filled**: Shows preview with close button
- **Action**: Ganti Foto button to replace

### Description Field
- **Type**: TextArea (4 lines)
- **Optional**: Yes
- **Placeholder**: "Contoh: Ganti oli mesin, setel bearing..."

## Status Indicators

### Task List
- 🔴 Red badge: Task waiting (Open)
- 🟠 Orange badge: Task in progress
- 🟢 Green badge: Task completed
- ⚪ Gray badge: Task archived

### Detail Screen
- 🎯 Icon + Gradient background
- Color matches status
- Shows status label in Indonesian

## Dialog Reference

### Confirmation Dialog
```
┌─────────────────────────────────┐
│  Ambil Tugas                    │
├─────────────────────────────────┤
│  Apakah Anda yakin ingin       │
│  mengambil tugas ini untuk      │
│  dikerjakan?                    │
├─────────────────────────────────┤
│  [Batal]      [Konfirmasi]     │
└─────────────────────────────────┘
```

## Search & Filter Tips

### Search Bar
- Searches: Judul, Lokasi, Deskripsi
- Real-time filtering
- Case-insensitive

### Filter Tabs
- **Menunggu**: Tasks waiting for technician
- **Diproses**: Tasks currently being worked on
- **Selesai**: Completed tasks
- **Arsip**: Historical/closed tasks

## Message Types

### Success (Green)
```
✓ Tugas berhasil diambil dan sedang diproses
✓ Tugas berhasil diselesaikan dan disimpan!
```

### Error (Red)
```
✗ Error: [message details]
✗ Foto bukti harus dipilih
```

### Info (Blue)
```
ℹ Upload foto perbaikan dan deskripsi untuk
  menyelesaikan tugas ini
```

## Keyboard Shortcuts / Gestures

| Action | Method |
|--------|--------|
| Search | Tap search box, type |
| Filter | Tap status tab |
| View Detail | Tap card anywhere |
| Select Photo | Tap upload area |
| Change Photo | Tap "Ganti Foto" button |
| Go Back | Press back button or tap [Kembali] |
| Confirm | Tap [Konfirmasi] button |

## Data Fields by Status

### OPEN Status Shows
- ✓ Title
- ✓ Location
- ✓ Description
- ✓ Reporter Name
- ✓ Creation Date
- ✓ Status

### IN_PROGRESS Status Shows
- ✓ All OPEN fields
- ✓ Technician Name
- ✓ Can upload photo
- ✓ Can add description
- ✓ Action: [Selesaikan Tugas]

### RESOLVED Status Shows
- ✓ All IN_PROGRESS fields
- ✓ Proof Photo
- ✓ Repair Description
- ✓ Materials Used
- ✓ Update Timestamp
- ✓ Status: Awaiting Validation

### CLOSED Status Shows
- ✓ Complete history record
- ✓ All previous data
- ✓ Final status
- ✓ No actions available

## Typography Sizes

```
Page Title:        20px Bold
Card Title:        15px Bold
Body Text:         13px Medium
Small Text:        12px Regular
Label:             11px Semibold
Placeholder:       12px Regular (Gray)
```

## Spacing Guide

```
Between Cards:     12px
Card Padding:      16px
Section Margin:    28-32px
Top/Bottom:        20px
Left/Right:        16px
```

## Icons Used

| Icon | Purpose | Status |
|------|---------|--------|
| 📋 assignment | Open tasks | Green |
| 🔧 build | In progress | Orange |
| ✓ check_circle | Completed | Green |
| ✓ check_circle_outline | Closed/Archive | Gray |
| 📸 camera_alt | Photo upload | Blue |
| 📍 location_on | Location info | Status |
| 👤 person | Reporter | Blue |
| 🔨 engineering | Technician | Blue |
| 📦 inventory | Materials | Blue |
| 📅 calendar_today | Created date | Blue |
| 🔄 update | Updated date | Blue |
| ⚠️ info_outline | Information | Status |
| ❌ close | Delete/Remove | Red |
| ↩️ arrow_back | Go back | Gray |

## Common Workflows

### Accept a Task
1. Open "Lihat Tugas" from home
2. Find task with status "Menunggu"
3. Tap card to view details
4. Tap [Ambil Tugas] button
5. Confirm in dialog
✅ Status changes to "Diproses"

### Complete a Task
1. Find task with status "Diproses"
2. Tap card to view details
3. Tap [Selesaikan Tugas]
4. Tap photo area to select image
5. Optionally add description
6. Tap [Selesaikan & Simpan]
✅ Status changes to "Selesai"

### View Task History
1. Open "Lihat Tugas"
2. Tap "Arsip" filter tab
3. View completed tasks
4. Tap any card to see full details
5. Use back button to return

## Troubleshooting Quick Tips

| Issue | Solution |
|-------|----------|
| Task not appearing | Tap [Refresh] on home screen |
| Can't accept task | Ensure status is "Menunggu" |
| Can't complete task | Status must be "Diproses" |
| Photo not selected | Tap the upload area and choose source |
| Navigation stuck | Use device back button |
| Text too small/large | Check device settings |

---

**Last Updated**: April 27, 2026
**App Version**: 2.0
**UI Version**: Professional Enhancement
