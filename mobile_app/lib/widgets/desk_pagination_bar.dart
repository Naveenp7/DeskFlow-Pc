import 'package:flutter/material.dart';

class DeskPaginationBar extends StatelessWidget {
  final int totalPages;
  final int currentPage;
  final String pageTitle;
  final bool isAutoCycle;
  final Function(int page) onPageSelected;
  final VoidCallback onToggleAutoCycle;

  const DeskPaginationBar({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.pageTitle,
    required this.isAutoCycle,
    required this.onPageSelected,
    required this.onToggleAutoCycle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Dots List
          Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(totalPages, (index) {
              final isActive = index == currentPage;
              return GestureDetector(
                onTap: () => onPageSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 16 : 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ]
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 12),

          // Pause / Play Auto-cycle Toggle
          GestureDetector(
            onTap: onToggleAutoCycle,
            child: Icon(
              isAutoCycle ? Icons.pause_rounded : Icons.play_arrow_rounded,
              size: 11,
              color: isAutoCycle
                  ? const Color(0xFF00E5FF)
                  : Colors.white.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(width: 8),

          // Page Title Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              pageTitle.toUpperCase(),
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: Colors.white.withValues(alpha: 0.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
