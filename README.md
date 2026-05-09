# Loopify 🔥

> 💪 A habit tracking app that turns consistency into a game — streaks, milestones, motivational widgets, and a bit of attitude. 🚀

---

## ✨ Features

- 🎯 **11 Predefined Habits** — meditation, skincare, workouts, study sessions, and more
- ➕ **Unlimited Custom Habits** — build your own with personalized icons, colors, and types
- 🔥 **Streak System** — daily streaks, weekly grace passes, milestone rewards
- 📱 **Home Screen Widget** — dynamic Android widget that morphs as your day fills up
- 🎨 **3 Habit Types** — Simple ✅, Duration ⏱️, Numeric 🔢 (with custom units)
- 📊 **Project Tracking** — long-term goals with custom icons and colors
- 🌙 **Dark Mode First** — modern Material Design 3 aesthetic
- 💾 **Offline-First** — all data stored locally with Hive (zero cloud, zero accounts)
- 🔔 **Smart Notifications** — evening reminders + streak warnings
- 🏆 **Achievements & Notes** — capture wins as they happen

---

## 🛠️ Tech Stack

| Layer | Tool |
|------|------|
| 📱 Framework | Flutter (Dart) |
| 🧠 State | Riverpod |
| 💾 Database | Hive (NoSQL, local) |
| 🔔 Notifications | flutter_local_notifications + timezone |
| 🤖 Native Widget | Kotlin + AppWidgetProvider |
| 🌉 Bridge | home_widget plugin |
| 🎬 Animations | Lottie + Confetti |

---

## 🚀 Getting Started

```bash
# 1️⃣ Install dependencies
flutter pub get

# 2️⃣ Generate Hive adapters
flutter pub run build_runner build

# 3️⃣ Run the app
flutter run

# 📦 Build release APK
flutter build apk --release
```

> 💡 Widget images live in `assets/widget/` (`1.png`, `2.png`, `3.png`).

---

## 🧱 Architecture

```
🗂️  Models (Hive)  →  🔧 Services  →  🧠 Providers (Riverpod)  →  🎨 UI
```

- **`lib/models/`** — Hive `@HiveType` data classes (`.g.dart` files are generated 🤖)
- **`lib/services/`** — database, notifications, widget bridge, streak calc, midnight rollover
- **`lib/providers/`** — Riverpod `StateNotifier`s
- **`lib/screens/`** — full-page UIs
- **`lib/widgets/`** — reusable components (modals, chips, rings, gauges)

### 🔌 Android Widget Bridge

```
Flutter (WidgetService)  ─►  HomeWidget.saveWidgetData()
                              │
                              ▼
                  Native LoopifyWidget.kt  ─►  RemoteViews 📺
```

---

## 🎯 The 11 Predefined Habits

| # | Habit | Vibe | Color |
|---|-------|------|-------|
| 1️⃣ | 🧘 Sit & Shine | Meditation | Purple |
| 2️⃣ | ✨ Glow Potion | Skincare / Serum | Pink |
| 3️⃣ | 🥶 Ice Warrior | Cold Shower | Blue |
| 4️⃣ | 💪 Jaw Gym | Face Exercises | Orange |
| 5️⃣ | 😬 Chew Quest | Chewing Drills | Cyan |
| 6️⃣ | 🥩 Protein Power-Up | Protein Intake | Green |
| 7️⃣ | 📚 Study Grind | Study Time | Indigo |
| 8️⃣ | ♟️ Mind Gambit | Chess | Brown |
| 9️⃣ | 🚴 Pedal Power | Cycling | Light Green |
| 🔟 | 💻 Build Streak | Coding Projects | Deep Orange |
| 1️⃣1️⃣ | 🧪 Mad Scientist Mode | Experiments | Deep Purple |

---

## 🪟 Widget Logic

The home screen widget reacts to your daily progress:

| Habits Logged | Image | Vibe |
|--------------|-------|------|
| 0–2 ✅ | `1.png` | 💥 *"Wake up LEGEND!"* |
| 3–5 ✅ | `2.png` | 🔥 *"ON FIRE! Keep going!"* |
| 6+ ✅ | `3.png` | 🏆 *"LEGEND STATUS!"* |

> ⚡ Updates automatically on every habit log. Tap to open the app.

---

## 🔥 Streak Mechanics

- 🎚️ **Strict mode** → ≥ 3 habits/day count
- 🌱 **Lenient mode** → ≥ 1 habit/day counts
- 🛡️ **Grace pass** → 1 free skip per week (auto-resets every Monday)
- 🏅 **Milestones** at **3 / 7 / 21 / 100** days — celebration unlocked 🎉
- ☠️ **Streak break** → obituary modal so you can grieve properly

---

## 🎨 Custom Habits

Build your own with:

- 🧮 **3 types**: Simple ✅ • Duration ⏱️ • Numeric 🔢
- 🖼️ **16 icons** to choose from
- 🎨 **10 vibrant colors**
- 💬 **Personal microcopy** for that habit
- 📈 Counts toward your daily total + widget

---

## 🌙 Theme & Vibe

- 🎨 **Background:** `#0A0E21` (deep dark blue-black)
- 🟧 **Cards:** `#1D1E33`
- 🔥 **Accent:** Orange / Deep Orange
- 🌐 **Language:** Hindi/English mix in motivational quips for personality

---

## 📱 iOS Notes

Loopify is built on Flutter, so the core app — habits, streaks, scheduled notifications, Hive persistence, projects, achievements — runs on iOS as-is once the project is opened on a Mac.

### 🍏 First-time setup on macOS

```bash
flutter pub get
cd ios
pod install
open Runner.xcworkspace
```

> ⚙️ Minimum iOS deployment target is **13.0** (required by `flutter_local_notifications` 17.x).
> 🆔 Bundle identifier matches the Android app: `com.loopify.loopify`.
> 🔔 Notification permissions are requested at runtime by `flutter_local_notifications`. Foreground banners are wired through `UNUserNotificationCenter` in `AppDelegate.swift`.

### 🪟 Home-screen widget on iOS

The **Android home-screen widget does not auto-port to iOS**. iOS widgets are a separate native surface (WidgetKit) and need their own target inside Xcode. To add one later:

1. ➕ In Xcode: `File → New → Target → Widget Extension`
2. 🤝 Share data with the Flutter app via an **App Group** (e.g. `group.com.loopify.loopify`) so `home_widget` can write into it
3. 🎨 Re-implement the widget UI in **SwiftUI** (mirroring `LoopifyWidget.kt`'s 3-state vibe)

Until then, on iOS the widget is gracefully skipped — `home_widget` calls become no-ops and the rest of the app behaves normally.

---

## 🚧 Roadmap

- [ ] 🍎 iOS widget support
- [ ] 📅 Weekly / monthly habit analytics
- [ ] ✏️ Manage / edit / delete custom habits UI polish
- [ ] 📦 Unarchive + delete options for archived projects
- [ ] 🎨 Improved color & icon picker UI for projects
- [ ] 📈 Project statistics and progress tracking

---

## 📜 License

Personal project — all rights reserved. ✌️
