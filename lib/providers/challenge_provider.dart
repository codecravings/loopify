import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/challenge.dart';
import '../services/hive_service.dart';
import '../services/challenge_service.dart';

class ChallengeNotifier extends StateNotifier<List<Challenge>> {
  ChallengeNotifier() : super([]) {
    _loadTodayChallenges();
  }

  void _loadTodayChallenges() {
    state = HiveService.getTodayChallenges();
  }

  Future<void> addChallenge(Challenge challenge) async {
    await HiveService.saveChallenge(challenge);
    await ChallengeService.scheduleNotification(challenge);
    state = [...state, challenge];
  }

  Future<void> completeChallenge(String id, int saveChoice) async {
    final updated = await ChallengeService.completeChallenge(id, saveChoice);
    state = [
      for (final c in state)
        if (c.id == id) updated else c
    ];
  }

  Future<void> snoozeChallenge(String id, int minutes) async {
    final updated = await ChallengeService.snoozeChallenge(id, minutes);
    state = [
      for (final c in state)
        if (c.id == id) updated else c
    ];
  }

  Future<void> cancelChallenge(String id) async {
    final updated = await ChallengeService.cancelChallenge(id);
    state = [
      for (final c in state)
        if (c.id == id) updated else c
    ];
  }

  Future<void> expireOldChallenges() async {
    await ChallengeService.expireOldChallenges();
    _loadTodayChallenges();
  }

  void reload() {
    _loadTodayChallenges();
  }
}

final challengeProvider = StateNotifierProvider<ChallengeNotifier, List<Challenge>>((ref) {
  return ChallengeNotifier();
});

final activeChallengesProvider = Provider<List<Challenge>>((ref) {
  final allChallenges = ref.watch(challengeProvider);
  return allChallenges
      .where((c) => c.isActive)
      .toList()
    ..sort((a, b) => a.effectiveDeadline.compareTo(b.effectiveDeadline));
});
