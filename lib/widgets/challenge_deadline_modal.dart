import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../models/challenge.dart';

class ChallengeDeadlineModal extends StatefulWidget {
  final Challenge challenge;
  final void Function(int saveChoice) onComplete;
  final void Function(int minutes) onSnooze;
  final VoidCallback onCancel;

  const ChallengeDeadlineModal({
    Key? key,
    required this.challenge,
    required this.onComplete,
    required this.onSnooze,
    required this.onCancel,
  }) : super(key: key);

  static Future<void> show(
    BuildContext context, {
    required Challenge challenge,
    required void Function(int saveChoice) onComplete,
    required void Function(int minutes) onSnooze,
    required VoidCallback onCancel,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ChallengeDeadlineModal(
        challenge: challenge,
        onComplete: onComplete,
        onSnooze: onSnooze,
        onCancel: onCancel,
      ),
    );
  }

  @override
  State<ChallengeDeadlineModal> createState() => _ChallengeDeadlineModalState();
}

class _ChallengeDeadlineModalState extends State<ChallengeDeadlineModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  // Action states: null = choosing, 'complete' = save choice, 'snooze' = snooze input
  String? _actionState;
  final _snoozeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    );
    _animController.forward();
    _confettiController = ConfettiController(duration: const Duration(milliseconds: 700));
  }

  @override
  void dispose() {
    _animController.dispose();
    _confettiController.dispose();
    _snoozeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          backgroundColor: const Color(0xFF1D1E33),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purpleAccent.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.timer_off,
                      color: Colors.purpleAccent,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'TIME\'S UP!',
                    style: TextStyle(
                      color: Colors.purpleAccent,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Did you complete "${widget.challenge.habitDisplayName}"?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 15,
                    ),
                  ),
                  if (widget.challenge.snoozeCount > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Snoozed ${widget.challenge.snoozeCount} time${widget.challenge.snoozeCount > 1 ? 's' : ''}',
                      style: TextStyle(
                        color: Colors.orange.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // Action buttons or sub-states
                  if (_actionState == null) _buildMainActions(),
                  if (_actionState == 'complete') _buildSaveChoice(),
                  if (_actionState == 'snooze') _buildSnoozeInput(),
                ],
              ),
            ),
          ),
        ),
        // Confetti overlay
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            particleDrag: 0.05,
            emissionFrequency: 0.05,
            numberOfParticles: 20,
            gravity: 0.3,
            shouldLoop: false,
            colors: const [
              Colors.purpleAccent,
              Colors.amber,
              Colors.pink,
              Colors.cyan,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainActions() {
    return Column(
      children: [
        // HELL YEAH button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              setState(() => _actionState = 'complete');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'HELL YEAH!',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // SNOOZE button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              setState(() => _actionState = 'snooze');
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'SNOOZE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        // CANCEL button
        TextButton(
          onPressed: () {
            widget.onCancel();
            Navigator.pop(context);
          },
          child: Text(
            'CANCEL CHALLENGE',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 13,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveChoice() {
    return Column(
      children: [
        Text(
          'How do you want to save it?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _handleComplete(1),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.green.withOpacity(0.5)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 28),
                      SizedBox(height: 6),
                      Text(
                        'Log as\nHabit',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _handleComplete(2),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                      SizedBox(height: 6),
                      Text(
                        'Save as\nBadge',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _actionState = null),
          child: Text(
            'BACK',
            style: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
        ),
      ],
    );
  }

  Widget _buildSnoozeInput() {
    return Column(
      children: [
        Text(
          'Snooze for how long?',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        // Quick presets
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SnoozePreset(minutes: 5, onTap: () => _handleSnooze(5)),
            _SnoozePreset(minutes: 15, onTap: () => _handleSnooze(15)),
            _SnoozePreset(minutes: 30, onTap: () => _handleSnooze(30)),
          ],
        ),
        const SizedBox(height: 12),
        // Custom input
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _snoozeController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Custom minutes',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.orange),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                final mins = int.tryParse(_snoozeController.text);
                if (mins != null && mins > 0) {
                  _handleSnooze(mins);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: const Text('GO', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() => _actionState = null),
          child: Text(
            'BACK',
            style: TextStyle(color: Colors.white.withOpacity(0.4)),
          ),
        ),
      ],
    );
  }

  void _handleComplete(int saveChoice) {
    _confettiController.play();
    Future.delayed(const Duration(milliseconds: 800), () {
      widget.onComplete(saveChoice);
      if (mounted) Navigator.pop(context);
    });
  }

  void _handleSnooze(int minutes) {
    widget.onSnooze(minutes);
    Navigator.pop(context);
  }
}

class _SnoozePreset extends StatelessWidget {
  final int minutes;
  final VoidCallback onTap;

  const _SnoozePreset({required this.minutes, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.withOpacity(0.4)),
        ),
        child: Text(
          '${minutes}m',
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
