import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/services/user_preferences_service.dart';
import 'core/utils/api_service.dart';
import 'core/utils/app_router.dart';
import 'core/utils/service_locator.dart';
import 'core/utils/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  final prefs = sl<UserPreferencesService>();
  sl<ApiService>().setCountryCode(prefs.preferredCountry);
  runApp(const StyleAiApp());
}

class StyleAiApp extends StatelessWidget {
  const StyleAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp.router(
          title: 'StyleAI',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}
