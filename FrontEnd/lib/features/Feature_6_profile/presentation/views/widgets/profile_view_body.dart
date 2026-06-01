import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/widgets/app_brand_header_bar.dart';
import '../../../../../core/widgets/custom_dropdown_field.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/glass_bottom_nav_bar.dart';
import '../../../../../core/widgets/glass_container.dart';
import '../../../../../core/widgets/logout_button.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/radial_glow_background.dart';
import '../../manager/profile_cubit.dart';

const _languageOptions = [
  DropdownOption(value: 'en', label: 'English (US)'),
  DropdownOption(value: 'ar', label: 'Arabic (Egypt)'),
];

const _currencyOptions = [
  DropdownOption(value: 'USD', label: '(\$) USD'),
  DropdownOption(value: 'SAR', label: 'Saudi Riyal (SAR)'),
  DropdownOption(value: 'AED', label: 'UAE Dirham (AED)'),
];

const _countryOptions = [
  DropdownOption(value: 'SA', label: 'Saudi Arabia'),
  DropdownOption(value: 'US', label: 'United States'),
  DropdownOption(value: 'AE', label: 'United Arab Emirates'),
];

class ProfileViewBody extends StatefulWidget {
  const ProfileViewBody({super.key});

  @override
  State<ProfileViewBody> createState() => _ProfileViewBodyState();
}

class _ProfileViewBodyState extends State<ProfileViewBody> {
  late final TextEditingController _nameController;
  bool _showNameError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _labelFor(String code, List<DropdownOption<String>> options) {
    return options.firstWhere((o) => o.value == code, orElse: () => options.first).label;
  }

  String _genderLabel(String gender) {
    return gender == 'male' ? AppStrings.male : AppStrings.female;
  }

  void _startEditing(ProfileState state) {
    _nameController.text = state.displayName;
    _showNameError = false;
    context.read<ProfileCubit>().startEditing();
  }

  void _cancelEditing() {
    _showNameError = false;
    context.read<ProfileCubit>().cancelEditing();
  }

  Future<void> _saveChanges() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }

    setState(() => _showNameError = false);
    context.read<ProfileCubit>().updateDisplayName(name);
    await context.read<ProfileCubit>().saveChanges();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return RadialGlowBackground(
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                const AppBrandHeaderBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      AppStyle.horizontalPadding,
                      0,
                      AppStyle.horizontalPadding,
                      GlassBottomNavBar.contentBottomInset(context),
                    ),
                    child: Column(
                      children: [
                        SizedBox(height: 12.h),
                        if (state.isEditing)
                          _EditProfileCard(
                            state: state,
                            nameController: _nameController,
                            showNameError: _showNameError,
                            onNameChanged: (value) {
                              if (_showNameError && value.trim().isNotEmpty) {
                                setState(() => _showNameError = false);
                              }
                              context.read<ProfileCubit>().updateDisplayName(value);
                            },
                            onSave: _saveChanges,
                            onCancel: _cancelEditing,
                          )
                        else
                          _ReadOnlyProfileCard(
                            state: state,
                            languageLabel: _labelFor(state.languageCode, _languageOptions),
                            currencyLabel: _labelFor(state.currencyCode, _currencyOptions),
                            countryLabel: _labelFor(state.countryCode, _countryOptions),
                            genderLabel: _genderLabel(state.gender),
                            onEdit: () => _startEditing(state),
                          ),
                        SizedBox(height: 24.h),
                        LogoutButton(
                          onPressed: () async {
                            await context.read<ProfileCubit>().logout();
                            if (context.mounted) context.go(AppRoutes.splash);
                          },
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReadOnlyProfileCard extends StatelessWidget {
  const _ReadOnlyProfileCard({
    required this.state,
    required this.languageLabel,
    required this.currencyLabel,
    required this.countryLabel,
    required this.genderLabel,
    required this.onEdit,
  });

  final ProfileState state;
  final String languageLabel;
  final String currencyLabel;
  final String countryLabel;
  final String genderLabel;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: BorderRadius.circular(24.r),
      padding: EdgeInsets.all(24.w),
      opacity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded, color: AppColors.primary, size: 24.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  AppStrings.accountPreferences,
                  style: AppStyle.titleMedium.copyWith(fontSize: 18.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            state.displayName,
            style: AppStyle.headlineMedium.copyWith(fontSize: 26.sp),
          ),
          SizedBox(height: 28.h),
          _ReadOnlyField(label: AppStrings.language, value: languageLabel),
          SizedBox(height: 18.h),
          _ReadOnlyField(label: AppStrings.preferredCurrency, value: currencyLabel),
          SizedBox(height: 18.h),
          _ReadOnlyField(label: AppStrings.country, value: countryLabel),
          SizedBox(height: 18.h),
          _ReadOnlyField(label: AppStrings.gender, value: genderLabel),
          SizedBox(height: 28.h),
          PrimaryButton(
            label: AppStrings.edit,
            icon: Icon(Icons.edit_outlined, color: AppColors.onPrimary, size: 20.sp),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _EditProfileCard extends StatelessWidget {
  const _EditProfileCard({
    required this.state,
    required this.nameController,
    required this.showNameError,
    required this.onNameChanged,
    required this.onSave,
    required this.onCancel,
  });

  final ProfileState state;
  final TextEditingController nameController;
  final bool showNameError;
  final ValueChanged<String> onNameChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();

    return GlassContainer(
      borderRadius: BorderRadius.circular(24.r),
      padding: EdgeInsets.all(24.w),
      opacity: 0.06,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.settings, color: AppColors.primary, size: 22.sp),
              SizedBox(width: 8.w),
              Text(AppStrings.accountPreferences, style: AppStyle.titleMedium),
            ],
          ),
          SizedBox(height: 24.h),
          CustomTextField(
            label: AppStrings.yourName,
            controller: nameController,
            hintText: AppStrings.nameHint,
            textInputAction: TextInputAction.next,
            hasError: showNameError,
            errorText: showNameError ? AppStrings.nameRequired : null,
            onChanged: onNameChanged,
          ),
          SizedBox(height: 20.h),
          CustomDropdownField<String>(
            label: AppStrings.language,
            value: state.languageCode,
            options: _languageOptions,
            onChanged: cubit.updateLanguage,
          ),
          SizedBox(height: 16.h),
          CustomDropdownField<String>(
            label: AppStrings.preferredCurrency,
            value: state.currencyCode,
            options: _currencyOptions,
            onChanged: cubit.updateCurrency,
          ),
          SizedBox(height: 16.h),
          CustomDropdownField<String>(
            label: AppStrings.country,
            value: state.countryCode,
            options: _countryOptions,
            onChanged: cubit.updateCountry,
          ),
          SizedBox(height: 20.h),
          Text(AppStrings.gender, style: AppStyle.bodySmall),
          SizedBox(height: 10.h),
          Row(
            children: [
              _GenderRadio(
                label: AppStrings.male,
                selected: state.gender == 'male',
                onTap: () => cubit.updateGender('male'),
              ),
              SizedBox(width: 24.w),
              _GenderRadio(
                label: AppStrings.female,
                selected: state.gender == 'female',
                onTap: () => cubit.updateGender('female'),
              ),
            ],
          ),
          SizedBox(height: 28.h),
          PrimaryButton(
            label: AppStrings.saveChanges,
            isLoading: state.isSaving,
            onPressed: onSave,
          ),
          SizedBox(height: 12.h),
          Center(
            child: TextButton(
              onPressed: state.isSaving ? null : onCancel,
              child: Text(
                AppStrings.cancel,
                style: AppStyle.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppStyle.bodySmall.copyWith(color: AppColors.textMuted),
        ),
        SizedBox(height: 6.h),
        Text(value, style: AppStyle.bodyLarge),
      ],
    );
  }
}

class _GenderRadio extends StatelessWidget {
  const _GenderRadio({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            selected ? Icons.radio_button_checked : Icons.radio_button_off,
            color: selected ? AppColors.primary : AppColors.textMuted,
            size: 22.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppStyle.bodyLarge.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
