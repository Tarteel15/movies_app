import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../auth/presentation/widgets/avatar_picker_widget.dart';
import '../bloc/profile_bloc.dart';

class UpdateProfilePage extends StatefulWidget {
  final String initialName;
  final String? initialAvatarPath;

  const UpdateProfilePage({
    super.key,
    required this.initialName,
    this.initialAvatarPath,
  });

  @override
  State<UpdateProfilePage> createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initialName);
  late String _selectedAvatar =
      (widget.initialAvatarPath != null && widget.initialAvatarPath!.isNotEmpty)
          ? widget.initialAvatarPath!
          : AppAssets.avatars.first;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _onSavePressed() {
    if (!_formKey.currentState!.validate()) return;
    context.read<ProfileBloc>().add(
          UpdateProfileEvent(
            name: _nameController.text.trim(),
            avatarPath: _selectedAvatar,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.loaded) {
            Navigator.pop(context);
          } else if (state.status == ProfileStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state.status == ProfileStatus.loading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choose Avatar',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AvatarPickerWidget(
                    avatars: AppAssets.avatars,
                    selectedAvatar: _selectedAvatar,
                    onSelect: (path) {
                      setState(() {
                        _selectedAvatar = path;
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Save Changes',
                    isLoading: isLoading,
                    onPressed: isLoading ? null : _onSavePressed,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}