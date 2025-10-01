# Guest User Module - Implementation Guide

**Status:** ✅ Foundation Complete - Views Need Update
**Date:** October 1, 2025

---

## 🎯 Objective

Transform static guest user pages into **interactive, engaging experiences** that:
1. Load real data from local SQLite database
2. Sync with Firebase for updated public content
3. Provide smooth navigation (Next/Previous buttons)
4. Encourage user registration with compelling CTAs
5. Offer a taste of premium features

---

## ✅ Completed

### 1. **GuestContentService** Created
**File:** `lib/core/services/guest_content_service.dart`

**Features:**
- ✅ Loads words/translations from SQLite (`cameroon_languages.db`)
- ✅ Loads demo lessons from SQLite
- ✅ Fetches public content from Firebase (overlay)
- ✅ Merges SQLite + Firebase data (SQLite first, Firebase enhancement)
- ✅ Search functionality
- ✅ Category filtering
- ✅ Language filtering
- ✅ Content statistics

**Key Methods:**
```dart
// Get basic words for guests
GuestContentService.getBasicWords(languageCode: 'ewondo', limit: 20)

// Get demo lessons
GuestContentService.getDemoLessons(limit: 5)

// Get lesson content/chapters
GuestContentService.getLessonContent(lessonId)

// Search words
GuestContentService.searchWords('bonjour')

// Get words by category
GuestContentService.getWordsByCategory(categoryId)
```

### 2. **GuestDashboardViewModel** Updated
**File:** `lib/features/guest/presentation/viewmodels/guest_dashboard_viewmodel.dart`

**Changes:**
- ❌ Removed static/hardcoded data
- ✅ Uses real SQLite + Firebase data
- ✅ Loads: languages, lessons, words, categories, stats
- ✅ Error handling
- ✅ Loading states
- ✅ Refresh capability

---

## 🔄 Next Steps - Views to Update

### Priority 1: Interactive Demo Lessons View

**File to Update:** `lib/features/guest/presentation/views/demo_lessons_view.dart`

**Current State:** Static data, no real functionality

**Required Implementation:**
```dart
// Instead of static list:
final List<Map<String, dynamic>> _demoLessons = [...]

// Use ViewModel:
class _DemoLessonsViewState extends State<DemoLessonsView> {
  final _viewModel = GuestDashboardViewModel();

  @override
  void initState() {
    super.initState();
    _viewModel.initialize();
  }

  // Then use: _viewModel.demoLessons in UI
}
```

**Features to Add:**
1. **Lesson Navigation:**
   - Next/Previous buttons
   - Progress indicator (Lesson 1/3)
   - Chapter navigation within lesson

2. **Interactive Content:**
   - Display actual lesson chapters from SQLite
   - Audio playback for pronunciations
   - Simple quizzes/exercises
   - Progress tracking

3. **CTA (Call-to-Action):**
   - After 3 lessons: "Want more? Sign up now!"
   - "Unlock 50+ lessons" banner
   - "See your progress" teaser

### Priority 2: Guest Words/Dictionary View

**New File to Create:** `lib/features/guest/presentation/views/guest_words_view.dart`

**Features:**
- Display basic words from SQLite
- Filter by language
- Filter by category
- Search functionality
- Next/Previous navigation (pagination)
- Audio pronunciation (if available)
- CTA: "Register to save favorites"

**Example Implementation:**
```dart
class GuestWordsView extends StatefulWidget {
  final String? languageCode;
  final int? categoryId;

  const GuestWordsView({this.languageCode, this.categoryId});
}

// Features:
// - Show 10 words per page
// - Next/Previous buttons
// - Search bar
// - "Register to unlock 1000+ words"
```

### Priority 3: Update Guest Dashboard View

**File to Update:** `lib/features/guest/presentation/views/guest_dashboard_view.dart`

**Required Changes:**
- Replace static content with ViewModel data
- Add engaging statistics (e.g., "500+ words available")
- Quick action buttons: "Try a lesson", "Browse words", "Explore languages"
- Progress hint: "See what you've learned - Register now!"

### Priority 4: Interactive Lesson Player

**New File to Create:** `lib/features/guest/presentation/views/guest_lesson_player_view.dart`

**Features:**
- Display lesson chapters sequentially
- Next/Previous chapter navigation
- Progress bar
- Audio playback
- Simple exercises (multiple choice)
- "Continue as guest" vs "Register for full experience"

---

## 📊 SQLite Database Schema (Assumed)

Based on the service implementation, the database should have:

```sql
-- Tables
CREATE TABLE languages (
  id INTEGER PRIMARY KEY,
  name TEXT,
  code TEXT,
  flag_emoji TEXT,
  is_active INTEGER DEFAULT 1
);

CREATE TABLE categories (
  id INTEGER PRIMARY KEY,
  name TEXT,
  description TEXT,
  icon_name TEXT,
  is_active INTEGER DEFAULT 1
);

CREATE TABLE translations (
  id INTEGER PRIMARY KEY,
  word TEXT,
  translation TEXT,
  pronunciation TEXT,
  language_id INTEGER,
  category_id INTEGER,
  is_public INTEGER DEFAULT 1,
  FOREIGN KEY (language_id) REFERENCES languages(id),
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

CREATE TABLE lessons (
  id INTEGER PRIMARY KEY,
  title TEXT,
  description TEXT,
  difficulty_level TEXT,
  duration_minutes INTEGER,
  language_id INTEGER,
  is_public INTEGER DEFAULT 1,
  order_index INTEGER,
  FOREIGN KEY (language_id) REFERENCES languages(id)
);

CREATE TABLE chapters (
  id INTEGER PRIMARY KEY,
  title TEXT,
  content TEXT,
  chapter_type TEXT,
  lesson_id INTEGER,
  order_index INTEGER,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id)
);
```

**Important:** Verify actual schema matches this. If different, update `GuestContentService` queries accordingly.

---

## 🎨 UI/UX Best Practices for Guest Views

### 1. **Visual Hierarchy**
- Clear "Guest Mode" indicator
- Progress indicators everywhere
- Countdown: "2 more lessons available"

### 2. **Engaging CTAs**
Position | Message | Action
---------|---------|-------
After Lesson 1 | "Great start! 🎉" | Continue
After Lesson 3 | "Want to continue? Register now!" | Sign Up
Words View | "Unlock 1000+ words" | Register
Dashboard | "Save your progress" | Create Account

### 3. **Navigation Flow**
```
Guest Dashboard
├── Browse Words
│   ├── By Language
│   ├── By Category
│   └── Search
│       └── CTA: Register to save
├── Demo Lessons
│   ├── Lesson 1 → Chapters → Next
│   ├── Lesson 2 → Chapters → Next
│   └── Lesson 3 → Chapters → CTA
└── Explore Languages
    └── Language Info → Sample Content → CTA
```

### 4. **Gamification Elements**
- ✅ Checkmarks for completed lessons
- 🏆 "You've learned 15 words!"
- 📊 "78% of users continue after registering"
- ⭐ "Unlock badges and certificates"

---

## 🔗 Firebase Public Content Structure

For teachers/admins to publish content accessible to guests:

```json
{
  "public_content": {
    "words": {
      "items": {
        "{wordId}": {
          "word": "Mboté",
          "translation": "Bonjour",
          "pronunciation": "mm-boh-teh",
          "languageName": "Ewondo",
          "languageCode": "ewondo",
          "categoryName": "Greetings",
          "isPublic": true,
          "addedBy": "admin",
          "addedAt": "2025-10-01T00:00:00Z"
        }
      }
    },
    "lessons": {
      "items": {
        "{lessonId}": {
          "title": "Greetings in Ewondo",
          "description": "Learn basic greetings",
          "difficultyLevel": "beginner",
          "durationMinutes": 10,
          "languageName": "Ewondo",
          "languageCode": "ewondo",
          "isPublic": true,
          "chapters": [...]
        }
      }
    }
  }
}
```

---

## 🧪 Testing Checklist

### Guest User Experience
- [ ] Guest can view basic words from SQLite
- [ ] Guest can complete 3 demo lessons
- [ ] Next/Previous navigation works smoothly
- [ ] Search returns relevant results
- [ ] Category filtering works
- [ ] Language filtering works
- [ ] Firebase public content displays (when available)
- [ ] CTAs are prominent and compelling
- [ ] "Register" buttons redirect to sign-up
- [ ] Progress is indicated visually
- [ ] Content loads quickly (<2 seconds)
- [ ] Works offline (SQLite only)
- [ ] Works online (SQLite + Firebase)

### Data Integration
- [ ] SQLite database loads successfully
- [ ] Firebase public content fetches (if available)
- [ ] Data merging works correctly
- [ ] No duplicate entries
- [ ] Content statistics are accurate

---

## 📝 Implementation Code Samples

### Example: Interactive Lesson Player

```dart
class GuestLessonPlayerView extends StatefulWidget {
  final int lessonId;
  const GuestLessonPlayerView({required this.lessonId});

  @override
  State<GuestLessonPlayerView> createState() => _GuestLessonPlayerViewState();
}

class _GuestLessonPlayerViewState extends State<GuestLessonPlayerView> {
  final _viewModel = GuestDashboardViewModel();
  List<Map<String, dynamic>> _chapters = [];
  int _currentChapterIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadLessonContent();
  }

  Future<void> _loadLessonContent() async {
    final chapters = await _viewModel.getLessonContent(widget.lessonId);
    setState(() {
      _chapters = chapters;
    });
  }

  void _nextChapter() {
    if (_currentChapterIndex < _chapters.length - 1) {
      setState(() {
        _currentChapterIndex++;
      });
    } else {
      // End of lesson - show CTA
      _showCompletionDialog();
    }
  }

  void _previousChapter() {
    if (_currentChapterIndex > 0) {
      setState(() {
        _currentChapterIndex--;
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🎉 Leçon terminée!'),
        content: Text('Inscrivez-vous pour débloquer 50+ leçons supplémentaires!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              // Navigate to registration
              context.go('/register');
            },
            child: Text('S\'inscrire maintenant'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_chapters.isEmpty) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentChapter = _chapters[_currentChapterIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Chapitre ${_currentChapterIndex + 1}/${_chapters.length}'),
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentChapterIndex + 1) / _chapters.length,
          ),

          // Chapter content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    currentChapter['title'] ?? '',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Text(currentChapter['content'] ?? ''),
                ],
              ),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                if (_currentChapterIndex > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousChapter,
                      icon: Icon(Icons.arrow_back),
                      label: Text('Précédent'),
                    ),
                  ),
                if (_currentChapterIndex > 0) SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextChapter,
                    icon: Icon(Icons.arrow_forward),
                    label: Text(
                      _currentChapterIndex < _chapters.length - 1
                          ? 'Suivant'
                          : 'Terminer',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## 🚀 Deployment Checklist

Before release:
- [ ] Verify SQLite database is included in `assets/databases/`
- [ ] Test guest flow end-to-end
- [ ] Ensure Firebase rules allow public content reads
- [ ] Test offline functionality
- [ ] Verify CTAs redirect correctly
- [ ] Check performance (< 2s load time)
- [ ] Test on low-end devices

---

**Status:** 🟡 In Progress
**Next:** Update demo_lessons_view.dart with real implementation
**Priority:** High - This is the first impression for non-registered users!
