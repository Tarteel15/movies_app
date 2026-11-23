import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AvatarPickerWidget extends StatelessWidget {
  final List<String> avatars;
  final String? selectedAvatar;
  final ValueChanged<String> onSelect;

  const AvatarPickerWidget({
    super.key,
    required this.avatars,
    required this.selectedAvatar,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: avatars.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final avatarPath = avatars[index];
          final isSelected = avatarPath == selectedAvatar;

          return GestureDetector(
            onTap: () => onSelect(avatarPath),
            child: Container(
              width: 74,
              height: 74,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textPrimary.withValues(alpha: 0.2),
                  width: isSelected ? 2.5 : 1.5,
                ),
              ),
              child: ClipOval(
                child: Image.asset(
                  avatarPath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: AppColors.surface,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
