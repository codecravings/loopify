# Loopify 🔥

A habit tracking app that helps you build consistency through gamification, streaks, and motivational widgets.

## Features

- **11 Customizable Habits**: Track meditation, skincare, workouts, study sessions, and more
- **Custom Habit Creation**: Add unlimited custom habits with personalized icons, colors, and types
- **Streak System**: Build momentum with daily streaks and milestone rewards
- **Home Screen Widget**: Dynamic Android widget that adapts based on your daily progress
- **Project Tracking**: Long-term projects with customizable icons and colors
- **Dark Mode Design**: Modern UI with Material Design 3
- **Offline-First**: All data stored locally using Hive database
- **Progress Persistence**: All habit data is stored permanently in local database

## Tech Stack

- **Flutter**: Cross-platform mobile framework (Dart)
- **Riverpod**: State management with providers and notifiers
- **Hive**: Local NoSQL database for offline storage
- **Kotlin**: Native Android widget implementation
- **Home Widget Plugin**: Flutter bridge for home screen widgets

## File Structure

### Core App Files

- **lib/main.dart**: App entry point, initializes Hive and providers
- **lib/screens/main_screen.dart**: Bottom navigation with home, stats, and projects tabs
- **lib/screens/home_screen.dart**: Main habit tracking interface
- **lib/screens/stats_screen.dart**: Streak visualization and progress stats
- **lib/screens/projects_screen.dart**: Long-term project management

### State Management

- **lib/providers/habit_provider.dart**: Manages daily habit completion state
- **lib/providers/project_provider.dart**: Manages active and archived projects
- **lib/providers/streak_provider.dart**: Tracks and updates streak counts

### Services

- **lib/services/hive_service.dart**: Database operations for habits, projects, and streaks
- **lib/services/widget_service.dart**: Updates home screen widget with current progress
- **lib/services/notifications_service.dart**: Daily reminders and streak notifications

### Constants & Models

- **lib/constants/habits.dart**: Habit definitions, icons, colors, and motivational quips
- **lib/models/habit_log.dart**: Data model for daily habit entries
- **lib/models/day_log.dart**: Daily log with all 11 habits + custom habits map
- **lib/models/project.dart**: Data model for projects with metadata
- **lib/models/custom_habit.dart**: Data model for user-created custom habits
- **lib/models/streak_state.dart**: Current streak and best streak tracking

### Android Widget

- **android/app/src/main/kotlin/com/loopify/loopify/LoopifyWidget.kt**: Native widget provider
- **android/app/src/main/res/layout/loopify_widget.xml**: Widget layout (3x1 horizontal design)
- **android/app/src/main/res/xml/loopify_widget_info.xml**: Widget size configuration
- **android/app/src/main/res/drawable/widget_background.xml**: Dark gradient background

## Widget Logic

The home screen widget dynamically updates based on habits completed today:

- **0-2 habits**: Shows `1.png` + random START quip ("Wake up LEGEND! 💥")
- **3-5 habits**: Shows `2.png` + random KEEP GOING quip ("ON FIRE! Keep going! 🔥")
- **6+ habits**: Shows `3.png` + random UNSTOPPABLE quip ("LEGEND STATUS! 🏆")

Widget updates automatically when habits are logged. Tap to open app.

## Design Philosophy

- **Gamification**: Turn habits into a game with streaks, milestones, and motivational quips
- **Brevity**: Short, punchy messages with Hindi/English mix for personality
- **Visual Feedback**: Dynamic widgets and progress indicators for instant gratification
- **Dark Aesthetics**: Modern dark mode (#0A0E21 background, #1D1E33 cards, orange accents)

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Add widget images to `assets/`:
   - `1.png`, `2.png`, `3.png`
4. Run the app:
   ```bash
   flutter run
   ```

## Habit Types

1. **Sit & Shine** (Meditation) - Purple
2. **Glow Potion** (Serum) - Pink
3. **Ice Warrior** (Cold Shower) - Blue
4. **Jaw Gym** (Face Exercises) - Orange
5. **Chew Quest** (Chewing Exercises) - Cyan
6. **Protein Power-Up** (Protein Intake) - Green
7. **Study Grind** (Study Time) - Indigo
8. **Mind Gambit** (Chess) - Brown
9. **Pedal Power** (Cycling) - Light Green
10. **Build Streak** (Coding Projects) - Deep Orange
11. **Mad Scientist Mode** (Experiments) - Deep Purple

## Custom Habits

Users can create unlimited custom habits with:
- **3 Types**: Simple (checkbox), Duration (minutes), Numeric (with custom units)
- **Custom Icons**: 16 popular icons to choose from
- **Custom Colors**: 10 vibrant colors
- **Motivational Quotes**: Personalized microcopy for each habit
- **Persistent Storage**: All custom habits saved in Hive database
- **Progress Tracking**: Counts toward daily total and widget updates

## Pending Features

- [ ] Unarchive and delete options for archived projects
- [ ] Improved color and icon picker UI for projects
- [ ] Project statistics and progress tracking
- [ ] iOS widget support
- [ ] Weekly/monthly habit analytics
- [ ] Manage/edit/delete custom habits
