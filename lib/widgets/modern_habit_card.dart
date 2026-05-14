import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/habits.dart';
import '../models/habit_log.dart';
import 'gradient_box_border.dart';

/// A modern, stunning habit card with glassmorphism effects,
/// animated gradients, and delightful micro-interactions.
class LoopifyHabitCard extends StatefulWidget {
  final HabitType habitType;
  final HabitLog habitLog;
  final Function(HabitLog) onConfirm;
  final int? defaultDuration;
  final int? proteinTarget;
  final List<String>? availableProjects;

  const LoopifyHabitCard({
    Key? key,
    required this.habitType,
    required this.habitLog,
    required this.onConfirm,
    this.defaultDuration,
    this.proteinTarget,
    this.availableProjects,
  }) : super(key: key);

  @override
  State<LoopifyHabitCard> createState() => _LoopifyHabitCardState();
}

class _LoopifyHabitCardState extends State<LoopifyHabitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  bool _isExpanded = false;
  bool _isPressed = false;

  // Duration habits
  int _selectedMinutes = 0;
  int _selectedSeconds = 0;

  // Protein
  int _selectedGrams = 0;

  // Projects
  Set<String> _selectedProjects = {};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );
    _heightAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    if (habitDetails[widget.habitType]!.isDuration) {
      _selectedMinutes = widget.defaultDuration ?? 10;
    }
    if (habitDetails[widget.habitType]!.isProtein) {
      _selectedGrams = widget.proteinTarget ?? 100;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    if (widget.habitLog.logged) return;

    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
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

  void _onLongPress() {
    if (!widget.habitLog.logged) return;

    // Show dialog to uncheck/remove the habit
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Remove ${habitDetails[widget.habitType]!.name}?',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'This will uncheck this habit for today.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Send an empty/unchecked habit log
              widget.onConfirm(HabitLog(logged: false));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirm() {
    if (widget.habitLog.logged) return;

    final info = habitDetails[widget.habitType]!;
    HabitLog newLog;

    if (info.isDuration) {
      final totalSeconds = (_selectedMinutes * 60) + _selectedSeconds;
      if ((widget.habitType == HabitType.chess ||
              widget.habitType == HabitType.cycling) &&
          totalSeconds < 300) {
        _showWarmupDialog(totalSeconds);
        return;
      }
      newLog = HabitLog(logged: true, seconds: totalSeconds);
    } else if (info.isProtein) {
      newLog = HabitLog(logged: true, grams: _selectedGrams);
    } else if (info.isProject) {
      if (_selectedProjects.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select at least one project')),
        );
        return;
      }
      newLog = HabitLog(logged: true, projectIds: _selectedProjects.toList());
    } else {
      newLog = HabitLog(logged: true);
    }

    if (mounted) {
      HapticFeedback.mediumImpact();
    }
    widget.onConfirm(newLog);
    setState(() {
      _isExpanded = false;
      _controller.reverse();
    });
  }

  void _showWarmupDialog(int totalSeconds) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1E33),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Count as warm-up?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Won\'t add to streak requirement',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final newLog = HabitLog(logged: false, seconds: totalSeconds);
              widget.onConfirm(newLog);
              setState(() {
                _isExpanded = false;
                _controller.reverse();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Yes, log it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = habitDetails[widget.habitType]!;
    final isLocked = widget.habitLog.logged;

    return GestureDetector(
      onTap: _toggleExpand,
      onLongPress: _onLongPress,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        margin: EdgeInsets.symmetric(
          vertical: 8,
          horizontal: _isPressed ? 20 : 16,
        ),
        transform: Matrix4.identity()
          ..scale(_isPressed ? 0.98 : 1.0),
        decoration: _buildDecoration(isLocked, info),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Animated gradient background
              if (!isLocked)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 3000),
                  curve: Curves.linear,
                  left: _isExpanded ? -50 : 0,
                  right: _isExpanded ? 0 : -50,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF1D1E33),
                          const Color(0xFF252847),
                          const Color(0xFF1D1E33),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment(-1.0 + (_isExpanded ? 0.3 : 0), 0),
                        end: Alignment(1.0 - (_isExpanded ? 0.3 : 0), 0),
                      ),
                    ),
                  ),
                ),
              // Glow effect for completed state
              if (isLocked)
                Positioned(
                  top: -30,
                  right: -30,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: info.color.withOpacity(0.3),
                      boxShadow: [
                        BoxShadow(
                          color: info.color.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              // Main content
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeader(isLocked, info),
                    SizeTransition(
                      sizeFactor: _heightAnimation,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: _buildControls(info),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(bool isLocked, HabitInfo info) {
    if (isLocked) {
      // Completed state - glowing gradient card
      return BoxDecoration(
        gradient: LinearGradient(
          colors: [
            info.color.withOpacity(0.25),
            info.color.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: info.color.withOpacity(0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: info.color.withOpacity(0.25),
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

    // Default state - glassmorphism
    return BoxDecoration(
      color: const Color(0xFF1D1E33).withOpacity(0.8),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(
        color: Colors.white.withOpacity(0.12),
        width: 1.5,
      ),
      boxShadow: [
        // Inner glow
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          blurRadius: 20,
          spreadRadius: -5,
        ),
        // Drop shadow
        BoxShadow(
          color: Colors.black.withOpacity(_isPressed ? 0.4 : 0.3),
          blurRadius: _isPressed ? 8 : 15,
          offset: Offset(0, _isPressed ? 4 : 8),
        ),
      ],
    );
  }

  Widget _buildHeader(bool isLocked, HabitInfo info) {
    return Row(
      children: [
        // Animated icon container
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: isLocked
                ? LinearGradient(
                    colors: [
                      info.color.withOpacity(0.4),
                      info.color.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isLocked ? null : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLocked
                  ? info.color.withOpacity(0.6)
                  : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
            boxShadow: isLocked
                ? [
                    BoxShadow(
                      color: info.color.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Icon(
            info.icon,
            color: isLocked ? Colors.white : info.color.withOpacity(0.9),
            size: 26,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                info.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isLocked ? info.color : Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              if (!isLocked) ...[
                const SizedBox(height: 4),
                Text(
                  info.microcopy,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
              if (isLocked && widget.habitLog.seconds != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${(widget.habitLog.seconds! / 60).round()} min completed',
                  style: TextStyle(
                    fontSize: 12,
                    color: info.color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (isLocked && widget.habitLog.grams != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${widget.habitLog.grams}g logged',
                  style: TextStyle(
                    fontSize: 12,
                    color: info.color.withOpacity(0.8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Animated checkmark
        AnimatedSwitcher(
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: info.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    color: info.color,
                    size: 24,
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('empty')),
        ),
      ],
    );
  }

  Widget _buildControls(HabitInfo info) {
    if (info.isDuration) {
      return _buildDurationControls(info);
    } else if (info.isProtein) {
      return _buildProteinControls(info);
    } else if (info.isProject) {
      return _buildProjectControls(info);
    } else {
      return _buildSimpleConfirm(info);
    }
  }

  Widget _buildDurationControls(HabitInfo info) {
    return Column(
      children: [
        // Preset buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [5, 10, 15, 30].map((minutes) {
            final isSelected = _selectedMinutes == minutes && _selectedSeconds == 0;
            return _buildPresetChip(
              '$minutes min',
              isSelected,
              () => setState(() {
                _selectedMinutes = minutes;
                _selectedSeconds = 0;
              }),
              info.color,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Number pickers
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildNumberWheel('min', _selectedMinutes, 0, 120, (val) {
              setState(() => _selectedMinutes = val);
            }, info.color),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                ':',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: info.color.withOpacity(0.8),
                ),
              ),
            ),
            _buildNumberWheel('sec', _selectedSeconds, 0, 59, (val) {
              setState(() => _selectedSeconds = val);
            }, info.color),
          ],
        ),
        const SizedBox(height: 20),
        // Confirm button
        _buildConfirmButton(info),
      ],
    );
  }

  Widget _buildProteinControls(HabitInfo info) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [80, 100, 120, 150].map((grams) {
            final isSelected = _selectedGrams == grams;
            return _buildPresetChip(
              '${grams}g',
              isSelected,
              () => setState(() => _selectedGrams = grams),
              info.color,
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Custom input
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18),
            decoration: InputDecoration(
              labelText: 'Exact grams',
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              border: InputBorder.none,
              suffixText: 'g',
              suffixStyle: TextStyle(color: info.color, fontWeight: FontWeight.bold),
            ),
            onChanged: (val) {
              final grams = int.tryParse(val);
              if (grams != null) {
                setState(() => _selectedGrams = grams);
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        _buildConfirmButton(info),
      ],
    );
  }

  Widget _buildProjectControls(HabitInfo info) {
    return Column(
      children: [
        if (widget.availableProjects != null &&
            widget.availableProjects!.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.availableProjects!.map((project) {
              final isSelected = _selectedProjects.contains(project);
              return FilterChip(
                selected: isSelected,
                label: Text(project),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedProjects.add(project);
                    } else {
                      _selectedProjects.remove(project);
                    }
                  });
                },
                selectedColor: info.color.withOpacity(0.3),
                checkmarkColor: info.color,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 13,
                ),
                backgroundColor: Colors.white.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? info.color.withOpacity(0.5)
                        : Colors.white.withOpacity(0.1),
                  ),
                ),
              );
            }).toList(),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No active projects. Add one in Projects tab!',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        const SizedBox(height: 20),
        _buildConfirmButton(info),
      ],
    );
  }

  Widget _buildSimpleConfirm(HabitInfo info) {
    return _buildConfirmButton(info, label: 'Mark as Complete');
  }

  Widget _buildPresetChip(
    String label,
    bool isSelected,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    color.withOpacity(0.4),
                    color.withOpacity(0.2),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.6)
                : Colors.white.withOpacity(0.1),
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildNumberWheel(
    String label,
    int value,
    int min,
    int max,
    Function(int) onChanged,
    Color accentColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.4),
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          height: 100,
          width: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: ListWheelScrollView.useDelegate(
            itemExtent: 36,
            perspective: 0.008,
            diameterRatio: 1.8,
            physics: const FixedExtentScrollPhysics(),
            controller: FixedExtentScrollController(initialItem: value),
            onSelectedItemChanged: (index) => onChanged(index),
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index < min || index > max) return null;
                final isSelected = index == value;
                return Container(
                  decoration: BoxDecoration(
                    color: isSelected ? accentColor.withOpacity(0.2) : null,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      index.toString().padLeft(2, '0'),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? accentColor : Colors.white70,
                      ),
                    ),
                  ),
                );
              },
              childCount: max + 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(HabitInfo info, {String? label}) {
    return GestureDetector(
      onTap: _confirm,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              info.color.withOpacity(0.8),
              info.color.withOpacity(0.6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: info.color.withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label ?? 'Confirm',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
