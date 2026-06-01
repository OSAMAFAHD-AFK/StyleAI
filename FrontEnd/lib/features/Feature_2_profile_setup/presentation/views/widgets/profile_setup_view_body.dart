import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/widgets/shimmer_style_ai_title.dart';
import '../../../../../core/l10n/app_strings.dart';
import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/app_router.dart';
import '../../../../../core/utils/style.dart';
import '../../../../../core/widgets/custom_dropdown_field.dart';
import '../../../../../core/widgets/custom_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../core/widgets/radial_glow_background.dart';
import '../../manager/profile_setup_cubit.dart';
import 'gender_selection_card.dart';

class ProfileSetupViewBody extends StatefulWidget {
  const ProfileSetupViewBody({super.key});

  @override
  State<ProfileSetupViewBody> createState() => _ProfileSetupViewBodyState();
}

class _ProfileSetupViewBodyState extends State<ProfileSetupViewBody> {
  late final TextEditingController _nameController;
  bool _showNameError = false;

  static const _countries = [
    DropdownOption(value: 'SA', label: 'Saudi Arabia', leading: Text('🇸🇦')),
    DropdownOption(value: 'AE', label: 'United Arab Emirates', leading: Text('🇦🇪')),
    DropdownOption(value: 'US', label: 'United States', leading: Text('🇺🇸')),
    DropdownOption(value: 'GB', label: 'United Kingdom', leading: Text('🇬🇧')),
  ];

  static const _currencies = [
    DropdownOption(value: 'SAR', label: 'Saudi Riyal (SAR)'),
    DropdownOption(value: 'AED', label: 'UAE Dirham (AED)'),
    DropdownOption(value: 'USD', label: 'US Dollar (USD)'),
    DropdownOption(value: 'GBP', label: 'British Pound (GBP)'),
  ];

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileSetupCubit, ProfileSetupState>(
      listenWhen: (previous, current) =>
          current.isComplete && !previous.isComplete,
      listener: (context, state) {
        context.go(AppRoutes.home);
      },
      builder: (context, state) {
        return RadialGlowBackground(
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppStyle.horizontalPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  Center(
                    child: ShimmerStyleAiTitle(
                      showTagline: false,
                      fontSize: 28.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Center(
                    child: Text(
                      AppStrings.welcomeTitle,
                      style: AppStyle.headlineMedium.copyWith(
                        color: AppColors.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      AppStrings.welcomeSubtitle,
                      style: AppStyle.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 28.h),
                  CustomTextField(
                    label: AppStrings.yourName,
                    controller: _nameController,
                    hintText: AppStrings.nameHint,
                    textInputAction: TextInputAction.next,
                    hasError: _showNameError,
                    errorText: AppStrings.nameRequired,
                    onChanged: (value) {
                      context.read<ProfileSetupCubit>().updateDisplayName(value);
                      if (_showNameError && value.trim().isNotEmpty) {
                        setState(() => _showNameError = false);
                      }
                    },
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  ),
                  SizedBox(height: 24.h),
                  Text(AppStrings.whoAreYou, style: AppStyle.fieldLabel),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Expanded(
                        child: GenderSelectionCard(
                          label: AppStrings.male,
                          icon: Icons.man_outlined,
                          selected: state.gender == 'male',
                          onTap: () => context.read<ProfileSetupCubit>().selectGender('male'),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GenderSelectionCard(
                          label: AppStrings.female,
                          icon: Icons.woman_outlined,
                          selected: state.gender == 'female',
                          onTap: () => context.read<ProfileSetupCubit>().selectGender('female'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  CustomDropdownField<String>(
                    label: AppStrings.shoppingCountry,
                    options: _countries,
                    value: state.countryCode,
                    onChanged: context.read<ProfileSetupCubit>().selectCountry,
                  ),
                  SizedBox(height: 20.h),
                  CustomDropdownField<String>(
                    label: AppStrings.preferredCurrency,
                    options: _currencies,
                    value: state.currencyCode,
                    onChanged: context.read<ProfileSetupCubit>().selectCurrency,
                  ),
                  SizedBox(height: 40.h),
                  PrimaryButton(
                    label: AppStrings.startExploring,
                    isLoading: state.isSaving,
                    onPressed: state.isSaving
                        ? null
                        : () => _submitSetup(context),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _submitSetup(BuildContext context) {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _showNameError = true);
      return;
    }

    context.read<ProfileSetupCubit>().completeSetup(displayName: name);
  }
}
