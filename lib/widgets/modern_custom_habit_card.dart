import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/custom_habit.dart';
import '../models/habit_log.dart';
import 'gradient_box_border.dart';

/// A modern, glassmorphic card for custom habits with stunning visuals
class ModernCustomHabitCard extends StatefulWidget {
  final CustomHabit habit;
  final HabitLog habitLog;
  final Function(HabitLog) onConfirm;

  const ModernCustomHabitCard({
    Key? key,
    required this.habit,
    required this.habitLog,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<ModernCustomHabitCard> createState() => _ModernCustomHabitCardState();
}

class _ModernCustomHabitCardState extends State<ModernCustomHabitCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (!widget.habitLog.logged) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ModernCustomHabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habitLog.logged != oldWidget.habitLog.logged) {
      if (widget.habitLog.logged) {
        _pulseController.stop();
      } else {
        _pulseController.repeat(reverse: true);
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.habitLog.logged) return;
    setState(() => _isPressed = true);
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
  }

  void _handleTap() {
    if (widget.habitLog.logged) return;

    if (widget.habit.isDuration) {
      _showDurationPicker();
    } else if (widget.habit.isNumeric) {
      _showNumericPicker();
    } else {
      // Simple habit - just log it with animation
      _showSuccessAnimation();
      widget.onConfirm(HabitLog(logged: true));
    }
  }

  void _showSuccessAnimation() {
    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isLocked = widget.habitLog.logged;

    return GestureDetector(
      onTap: _handleTap,
      onLongPress: isLocked ? _showEditDeleteDialog : null,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            margin: EdgeInsets.symmetric(
              vertical: 8,
              horizontal: _isPressed ? 20 : 16,
            ),
            transform: Matrix4.identity()
              ..scale(_isPressed
                  ? 0.98
                  : (!isLocked ? 1.0 + (_pulseController.value * 0.01) : 1.0)),
            decoration: _buildDecoration(isLocked),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background glow effect
                  if (isLocked)
                    Positioned(
                      top: -40,
                      right: -40,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.habit.color.withOpacity(0.3),
                        ),
                      ),
                    ),
                  // Animated gradient shimmer for incomplete habits
                  if (!isLocked)
                    Positioned.fill(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 2000),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              widget.habit.color.withOpacity(0.03 + (_pulseController.value * 0.02)),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment(-2 + (_pulseController.value * 4), -1),
                            end: Alignment(2 - (_pulseController.value * 4), 1),
                          ),
                        ),
                      ),
                    ),
                  // Main content
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        // Animated icon container
                        _buildIconContainer(isLocked),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildTitle(isLocked),
                              const SizedBox(height: 4),
                              _buildSubtitle(isLocked),
                              if (isLocked && widget.habitLog.seconds != null)
                                _buildValueChip(
                                  '${(widget.habitLog.seconds! / 60).round()} min',
                                ),
                              if (isLocked && widget.habitLog.grams != null)
                                _buildValueChip(
                                  '${widget.habitLog.grams} ${widget.habit.unit ?? ''}',
                                ),
                            ],
                          ),
                        ),
                        _buildStatusIndicator(isLocked),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isLocked) {
    if (isLocked) {
      // Completed state
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.habit.color.withOpacity(0.25),
            widget.habit.color.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.habit.color.withOpacity(0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.habit.color.withOpacity(0.25),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 8),
          ),
        ],
      );
    }

    // Incomplete state - glassmorphism
    return BoxDecoration(
      color: const Color(0xFF1D1E33).withOpacity(0.8),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: widget.habit.color.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: widget.habit.color.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: -5,
        ),
        BoxShadow(
          color: Colors.black.withOpacity(_isPressed ? 0.4 : 0.3),
          blurRadius: _isPressed ? 8 : 15,
          offset: Offset(0, _isPressed ? 4 : 8),
        ),
      ],
    );
  }

  Widget _buildIconContainer(bool isLocked) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: isLocked
            ? LinearGradient(
                colors: [
                  widget.habit.color.withOpacity(0.4),
                  widget.habit.color.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : LinearGradient(
                colors: [
                  widget.habit.color.withOpacity(0.15),
                  widget.habit.color.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLocked
              ? widget.habit.color.withOpacity(0.6)
              : widget.habit.color.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: isLocked
            ? [
                BoxShadow(
                  color: widget.habit.color.withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : [
                BoxShadow(
                  color: widget.habit.color.withOpacity(0.1),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Icon(
        widget.habit.icon,
        color: isLocked ? Colors.white : widget.habit.color.withOpacity(0.9),
        size: 28,
      ),
    );
  }

  Widget _buildTitle(bool isLocked) {
    return Text(
      widget.habit.name,
      style: TextStyle(
        color: isLocked ? widget.habit.color : Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildSubtitle(bool isLocked) {
    return Text(
      widget.habit.microcopy,
      style: TextStyle(
        color: isLocked
            ? widget.habit.color.withOpacity(0.7)
            : Colors.white.withOpacity(0.5),
        fontSize: 12,
        letterSpacing: 0.2,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildValueChip(String value) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: widget.habit.color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: widget.habit.color.withOpacity(0.4),
            width: 1,
          ),
        ),
        child: Text(
          value,
          style: TextStyle(
            color: widget.habit.color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool isLocked) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.elasticOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return ScaleTransition(
          scale: animation,
          child: RotationTransition(
            turns: Tween(begin: 0.5, end: 0.0).animate(animation),
            child: child,
          ),
        );
      },
      child: isLocked
          ? Container(
              key: const ValueKey('completed'),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: widget.habit.color.withOpacity(0.2),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.habit.color.withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.check_rounded,
                color: widget.habit.color,
                size: 26,
              ),
            )
          : Container(
              key: const ValueKey('pending'),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.1),
                  width: 1.5,
                ),
              ),
              child: Icon(
                Icons.add,
                color: Colors.white.withOpacity(0.3),
                size: 24,
              ),
            ),
    );
  }

  void _showDurationPicker() {
    int selectedMinutes = 5;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheet(
        title: widget.habit.name,
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minutes selector
              Container(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: selectedMinutes > 1
                          ? () => setState(() => selectedMinutes--)
                          : null,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: selectedMinutes > 1
                            ? Colors.white70
                            : Colors.white24,
                        size: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$selectedMinutes',
                            style: TextStyle(
                              color: widget.habit.color,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'minutes',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => selectedMinutes++),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: widget.habit.color,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Quick presets
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [5, 10, 15, 30, 60].map((min) {
                  final isSelected = selectedMinutes == min;
                  return GestureDetector(
                    onTap: () => setState(() => selectedMinutes = min),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? widget.habit.color.withOpacity(0.3)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? widget.habit.color.withOpacity(0.6)
                              : Colors.white.withOpacity(0.1),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        '$min',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              // Confirm button
              GestureDetector(
                onTap: () {
                  _showSuccessAnimation();
                  widget.onConfirm(HabitLog(
                    logged: true,
                    seconds: selectedMinutes * 60,
                  ));
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.habit.color.withOpacity(0.8),
                        widget.habit.color.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.habit.color.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Log Habit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNumericPicker() {
    int selectedCount = widget.habit.target ?? 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheet(
        title: widget.habit.name,
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Counter
              Container(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: selectedCount > 1
                          ? () => setState(() => selectedCount--)
                          : null,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: selectedCount > 1
                            ? Colors.white70
                            : Colors.white24,
                        size: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$selectedCount',
                            style: TextStyle(
                              color: widget.habit.color,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.habit.unit ?? 'times',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => selectedCount++),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: widget.habit.color,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Confirm button
              GestureDetector(
                onTap: () {
                  _showSuccessAnimation();
                  widget.onConfirm(HabitLog(
                    logged: true,
                    grams: selectedCount,
                  ));
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.habit.color.withOpacity(0.8),
                        widget.habit.color.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.habit.color.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Log Habit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSheet({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1E33),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: widget.habit.color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'How much did you complete?',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  void _showEditDeleteDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1D1E33),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: widget.habit.color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.habit.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to do?',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              if (widget.habit.isDuration || widget.habit.isNumeric)
                _buildActionButton(
                  'Edit Entry',
                  Icons.edit,
                  widget.habit.color,
                  () {
                    Navigator.pop(context);
                    if (widget.habit.isDuration) {
                      _showEditDuration();
                    } else {
                      _showEditNumeric();
                    }
                  },
                ),
              const SizedBox(height: 12),
              _buildActionButton(
                'Delete Entry',
                Icons.delete_outline,
                Colors.red,
                () {
                  Navigator.pop(context);
                  _showDeleteConfirm();
                },
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                'Cancel',
                Icons.close,
                Colors.white54,
                () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDuration() {
    int selectedMinutes =
        ((widget.habitLog.seconds ?? 300) / 60).round();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheet(
        title: 'Edit ${widget.habit.name}',
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: selectedMinutes > 1
                          ? () => setState(() => selectedMinutes--)
                          : null,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: selectedMinutes > 1
                            ? Colors.white70
                            : Colors.white24,
                        size: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$selectedMinutes',
                            style: TextStyle(
                              color: widget.habit.color,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'minutes',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => selectedMinutes++),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: widget.habit.color,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  widget.onConfirm(HabitLog(
                    logged: true,
                    seconds: selectedMinutes * 60,
                  ));
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.habit.color.withOpacity(0.8),
                        widget.habit.color.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.habit.color.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Update',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditNumeric() {
    int selectedCount = widget.habitLog.grams ?? widget.habit.target ?? 1;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildBottomSheet(
        title: 'Edit ${widget.habit.name}',
        child: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 120,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: selectedCount > 1
                          ? () => setState(() => selectedCount--)
                          : null,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: selectedCount > 1
                            ? Colors.white70
                            : Colors.white24,
                        size: 32,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$selectedCount',
                            style: TextStyle(
                              color: widget.habit.color,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.habit.unit ?? 'times',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => selectedCount++),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: widget.habit.color,
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  widget.onConfirm(HabitLog(
                    logged: true,
                    grams: selectedCount,
                  ));
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        widget.habit.color.withOpacity(0.8),
                        widget.habit.color.withOpacity(0.6),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: widget.habit.color.withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_rounded, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'Update',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete Entry?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Remove ${widget.habit.name} from today\'s log?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onConfirm(HabitLog(logged: false));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
