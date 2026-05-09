import 'package:flutter/material.dart';

enum AchievementType {
  streak,
  habits,
  recovery,
  consistency,
  legendary,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final int requiredValue;
  final String reward;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.requiredValue,
    required this.reward,
  });
}

// Achievement definitions
final Map<String, Achievement> achievements = {
  'first_blood': Achievement(
    id: 'first_blood',
    name: 'First Blood',
    description: 'Complete your first habit',
    icon: Icons.star,
    color: Colors.yellow,
    type: AchievementType.habits,
    requiredValue: 1,
    reward: 'Bronze Badge',
  ),
  'spark': Achievement(
    id: 'spark',
    name: 'Spark Ignited',
    description: 'Reach a 3-day streak',
    icon: Icons.local_fire_department,
    color: Colors.orange,
    type: AchievementType.streak,
    requiredValue: 3,
    reward: '+1 Recovery Token',
  ),
  'first_flame': Achievement(
    id: 'first_flame',
    name: 'First Flame',
    description: 'Reach a 7-day streak',
    icon: Icons.whatshot,
    color: Colors.deepOrange,
    type: AchievementType.streak,
    requiredValue: 7,
    reward: 'Fire Theme Unlocked',
  ),
  'habit_forged': Achievement(
    id: 'habit_forged',
    name: 'Habit Forged',
    description: 'Reach a 21-day streak',
    icon: Icons.military_tech,
    color: Colors.amber,
    type: AchievementType.streak,
    requiredValue: 21,
    reward: 'Gold Theme + 2 Tokens',
  ),
  'centurion': Achievement(
    id: 'centurion',
    name: 'Centurion',
    description: 'Reach a 100-day streak',
    icon: Icons.workspace_premium,
    color: Colors.purple,
    type: AchievementType.streak,
    requiredValue: 100,
    reward: 'Legendary Theme + 5 Tokens',
  ),
  'phoenix': Achievement(
    id: 'phoenix',
    name: 'Phoenix Rising',
    description: 'Recover from a streak break',
    icon: Icons.flight,
    color: Colors.red,
    type: AchievementType.recovery,
    requiredValue: 1,
    reward: '+1 Recovery Token',
  ),
  'iron_will': Achievement(
    id: 'iron_will',
    name: 'Iron Will',
    description: 'Complete 100 habits lifetime',
    icon: Icons.fitness_center,
    color: Colors.grey,
    type: AchievementType.habits,
    requiredValue: 100,
    reward: 'Steel Theme',
  ),
  'perfectionist': Achievement(
    id: 'perfectionist',
    name: 'Perfectionist',
    description: 'Complete all 11 habits in one day',
    icon: Icons.verified,
    color: Colors.cyan,
    type: AchievementType.habits,
    requiredValue: 11,
    reward: '+2 Recovery Tokens',
  ),
  'month_warrior': Achievement(
    id: 'month_warrior',
    name: 'Month Warrior',
    description: 'Maintain streak for 30 days',
    icon: Icons.shield,
    color: Colors.blue,
    type: AchievementType.streak,
    requiredValue: 30,
    reward: 'Ocean Theme + 2 Tokens',
  ),
  'consistency_king': Achievement(
    id: 'consistency_king',
    name: 'Consistency King',
    description: 'Complete at least 3 habits for 14 days straight',
    icon: Icons.diamond,
    color: Colors.indigo,
    type: AchievementType.consistency,
    requiredValue: 14,
    reward: 'Royal Theme',
  ),
  'legend': Achievement(
    id: 'legend',
    name: 'Legend',
    description: 'Reach a 365-day streak',
    icon: Icons.emoji_events,
    color: Colors.deepPurple,
    type: AchievementType.legendary,
    requiredValue: 365,
    reward: 'Legendary Status + 10 Tokens',
  ),
  'dark_phoenix': Achievement(
    id: 'dark_phoenix',
    name: 'Dark Phoenix',
    description: 'Break a 50+ day streak and rebuild to 50',
    icon: Icons.dark_mode,
    color: Colors.black,
    type: AchievementType.recovery,
    requiredValue: 50,
    reward: 'Dark Phoenix Theme + 5 Tokens',
  ),
};

// Theme definitions
final Map<String, Map<String, Color>> themes = {
  'default': {
    'primary': Color(0xFFFF6B35),
    'background': Color(0xFF0A0E21),
    'card': Color(0xFF1D1E33),
  },
  'fire': {
    'primary': Color(0xFFFF4500),
    'background': Color(0xFF1A0000),
    'card': Color(0xFF330000),
  },
  'gold': {
    'primary': Color(0xFFFFD700),
    'background': Color(0xFF1A1400),
    'card': Color(0xFF332800),
  },
  'legendary': {
    'primary': Color(0xFF9B59B6),
    'background': Color(0xFF0D0019),
    'card': Color(0xFF1A0033),
  },
  'steel': {
    'primary': Color(0xFF708090),
    'background': Color(0xFF0A0A0A),
    'card': Color(0xFF1A1A1A),
  },
  'ocean': {
    'primary': Color(0xFF00CED1),
    'background': Color(0xFF001419),
    'card': Color(0xFF002833),
  },
  'royal': {
    'primary': Color(0xFF4B0082),
    'background': Color(0xFF0D001A),
    'card': Color(0xFF1A0033),
  },
  'dark_phoenix': {
    'primary': Color(0xFFFF0000),
    'background': Color(0xFF000000),
    'card': Color(0xFF1A0000),
  },
};
