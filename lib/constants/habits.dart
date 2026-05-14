import 'package:flutter/material.dart';

enum HabitType {
  meditation,
  serum,
  coldShower,
  jawGym,
  chewQuest,
  protein,
  study,
  chess,
  cycling,
  buildStreak,
  madScientist,
}

class HabitInfo {
  final String name;
  final String microcopy;
  final IconData icon;
  final Color color;
  final bool isDuration;
  final bool isProtein;
  final bool isProject;

  const HabitInfo({
    required this.name,
    required this.microcopy,
    required this.icon,
    required this.color,
    this.isDuration = false,
    this.isProtein = false,
    this.isProject = false,
  });
}

const Map<HabitType, HabitInfo> habitDetails = {
  HabitType.meditation: HabitInfo(
    name: 'Sit & Shine',
    microcopy: 'Close your tabs. Including brain.exe.',
    icon: Icons.self_improvement,
    color: Color(0xFF9C27B0), // Purple
    isDuration: true,
  ),
  HabitType.serum: HabitInfo(
    name: 'Glow Potion',
    microcopy: 'Future you says thanks for the glass-skin DLC.',
    icon: Icons.water_drop,
    color: Color(0xFFE91E63), // Pink
  ),
  HabitType.coldShower: HabitInfo(
    name: 'Ice Warrior',
    microcopy: 'You vs. the water she told you not to worry about.',
    icon: Icons.ac_unit,
    color: Color(0xFF2196F3), // Blue
  ),
  HabitType.jawGym: HabitInfo(
    name: 'Gym',
    microcopy: 'Sweat now, flex later.',
    icon: Icons.fitness_center,
    color: Color(0xFFFF9800), // Orange
  ),
  HabitType.chewQuest: HabitInfo(
    name: 'Chew Quest',
    microcopy: 'Chew like rent\'s due.',
    icon: Icons.auto_awesome,
    color: Color(0xFF00BCD4), // Cyan
  ),
  HabitType.protein: HabitInfo(
    name: 'Protein Power-Up',
    microcopy: 'Muscle fuel unlocked. Biceps loading…',
    icon: Icons.fitness_center,
    color: Color(0xFF4CAF50), // Green
    isProtein: true,
  ),
  HabitType.study: HabitInfo(
    name: 'Study Grind',
    microcopy: 'Knowledge PR attempt. Headphones on.',
    icon: Icons.menu_book,
    color: Color(0xFF3F51B5), // Indigo
    isDuration: true,
  ),
  HabitType.chess: HabitInfo(
    name: 'Mind Gambit',
    microcopy: 'Outplay yesterday. One less blunder, one more idea.',
    icon: Icons.psychology,
    color: Color(0xFF795548), // Brown
    isDuration: true,
  ),
  HabitType.cycling: HabitInfo(
    name: 'Pedal Power',
    microcopy: 'Quads online. Wind = free pre-workout.',
    icon: Icons.directions_bike,
    color: Color(0xFF8BC34A), // Light Green
    isDuration: true,
  ),
  HabitType.buildStreak: HabitInfo(
    name: 'Build Streak',
    microcopy: 'Pixels were moved. Commits were committed.',
    icon: Icons.construction,
    color: Color(0xFFFF5722), // Deep Orange
    isProject: true,
  ),
  HabitType.madScientist: HabitInfo(
    name: 'Mad Scientist Mode',
    microcopy: 'You invented a future. Again.',
    icon: Icons.science,
    color: Color(0xFF673AB7), // Deep Purple
  ),
};

// Widget quip pools
const List<String> startQuips = [
  "Small steps, chaotic results.",
  "Tap once. Momentum does the rest.",
  "Today's the tutorial level—easy XP.",
];

const List<String> keepGoingQuips = [
  "Consistency is your cheat code.",
  "You're one boring day away from greatness.",
  "Keep the flame fed. Snacks: tiny actions.",
];

const List<String> unstoppableQuips = [
  "Your future self is sending high-fives in bulk.",
  "At this point, habits fear you.",
  "Elite mode: activated. Don't break the spell.",
];

// Milestone labels
const Map<int, String> milestoneLabels = {
  1: 'Origin Story',
  3: 'Spark Ignited',
  7: 'First Flame',
  21: 'Habit Forged',
  100: 'Centurion',
};

// Humorous streak completion messages (for >5 habits in a day)
const List<String> completionQuips = [
  "Maqsad pura hua! 🎯",
  "Mission accomplished! 🚀",
  "Boss mode activated! 👑",
  "Grind nahi, art hai! 🎨",
  "Legends don't skip days! ⚡",
  "Main character energy! 💪",
  "Sigma mindset unlocked! 🔥",
  "Future billionaire vibes! 💰",
  "Aaj ka quota full! ✅",
  "Consistency > Talent! 🎓",
];

// Widget quips for different streak levels
const List<String> widgetStartQuips = [
  "Wake up LEGEND! 💥",
  "Speedrun mode: ON! 🏃",
  "Main character energy! ⚡",
  "Abhi bhi flex time hai!",
  "Villain arc STARTS NOW! 😈",
  "Level 1. LET'S GO! 🚀",
  "Your glow-up begins! ✨",
];

const List<String> widgetKeepGoingQuips = [
  "ON FIRE! Keep going! 🔥",
  "MOMENTUM INSANE! 💪",
  "This is YOUR era! ✨",
  "GRINDING! Love it! 💯",
  "Habits ki BAAP! 👑",
  "BEAST MODE ON! ⚡",
];

const List<String> widgetUnstoppableQuips = [
  "LEGEND STATUS! 🏆",
  "BUILT DIFFERENT! 💎",
  "UNSTOPPABLE! 🚀",
  "GOD-TIER UNLOCKED! ⚡",
  "Ruk hi nahi sakte! 🔥",
  "Billionaire vibes! 💰",
];
