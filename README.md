# Notes App

A production-grade Flutter notes app built for internship portfolio review.

## Architecture

```
lib/
├── core/
│   ├── theme/          # AppTheme, AppColors, AppTypography
│   ├── constants/      # AppConstants (no magic numbers)
│   └── utils/          # DateFormatter, Debouncer
├── data/
│   ├── models/         # Note (HiveObject)
│   └── repositories/   # NoteRepository (abstract) + HiveNoteRepository
├── domain/
│   └── providers/      # NotesProvider, ThemeProvider
└── presentation/
    └── screens/
        ├── home/        # HomeScreen + NotesGrid, NotesList, NoteCard, etc.
        ├── editor/      # EditorScreen + ColorPickerRow, WordCountBar
        └── archive/     # ArchiveScreen
```

## Run Instructions

```bash
# 1. Install dependencies
flutter pub get

# 2. Generate Hive adapter + Mockito mocks
flutter packages pub run build_runner build --delete-conflicting-outputs

# 3. Run the app
flutter run

# 4. Run tests
flutter test
```

## Features

- Create, read, update, delete notes with Hive local storage
- Staggered masonry grid + list view toggle (persisted)
- Real-time search with 300ms debounce
- Sort by last edited, oldest, newest, A–Z (persisted)
- Pin notes (float to top)
- Soft delete → archive with undo snackbar
- Permanent delete from archive
- 7 note accent colors
- Auto-save with 1.5s debounce + visual indicator
- Word count + character count in editor
- Dark / light mode toggle (persisted)
- Hero animation: card → editor
- Staggered entrance animations on home screen
- FAB morphs extended → mini on scroll
- Haptic feedback on pin, delete, long-press
