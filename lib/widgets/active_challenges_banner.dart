import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/challenge_provider.dart';

class ActiveChallengesBanner extends ConsumerStatefulWidget {
  const ActiveChallengesBanner({Key? key}) : super(key: key);

  @override
  ConsumerState<ActiveChallengesBanner> createState() => _ActiveChallengesBannerState();
}

class _ActiveChallengesBannerState extends ConsumerState<ActiveChallengesBanner> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String _formatTimeRemaining(DateTime deadline) {
    final now = DateTime.now();
    final diff = deadline.difference(now);

    if (diff.isNegative) return 'OVERDUE';

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours > 0) return '${hours}h ${minutes}m left';
    if (minutes > 0) return '${minutes}m left';
    return '<1m left';
  }

  @override
  Widget build(BuildContext context) {
    final activeChallenges = ref.watch(activeChallengesProvider);

    if (activeChallenges.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              children: [
                Icon(Icons.timer, color: Colors.purpleAccent.withOpacity(0.7), size: 14),
                const SizedBox(width: 6),
                Text(
                  'ACTIVE CHALLENGES',
                  style: TextStyle(
                    color: Colors.purpleAccent.withOpacity(0.7),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
          ),
          ...activeChallenges.map((challenge) {
            final isOverdue = challenge.isOverdue;
            final isSnoozed = challenge.isSnoozed;
            final borderColor = isOverdue
                ? Colors.red
                : isSnoozed
                    ? Colors.orange.withOpacity(0.5)
                    : Colors.purpleAccent.withOpacity(0.4);

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF1D1E33),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderColor, width: isOverdue ? 2 : 1),
              ),
              child: Row(
                children: [
                  Icon(
                    isOverdue ? Icons.warning_amber_rounded : Icons.timer,
                    color: isOverdue ? Colors.red : Colors.purpleAccent,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge.habitDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSnoozed
                              ? 'Snoozed - ${_formatTimeRemaining(challenge.snoozedUntil!)}'
                              : _formatTimeRemaining(challenge.effectiveDeadline),
                          style: TextStyle(
                            color: isOverdue ? Colors.red : Colors.white54,
                            fontSize: 11,
                            fontWeight: isOverdue ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      ref.read(challengeProvider.notifier).cancelChallenge(challenge.id);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.close,
                        color: Colors.white.withOpacity(0.3),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
