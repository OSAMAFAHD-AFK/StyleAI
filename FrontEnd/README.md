# StyleAI Flutter App

## Run (important)

Commands must run from this folder (`FrontEnd`), where `pubspec.yaml` lives:

```powershell
cd d:\StyleAI\FrontEnd
flutter run -d windows
```

If you see `No pubspec.yaml file found`, you are in the wrong directory (e.g. `StyleAI` root).

### Other targets

```powershell
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8080
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:8080
```

## Architecture

Feature-first MVVM with Cubit:

```
features/
  Feature_1_splash/          # مقدمة + تسجيل دخول
  Feature_2_profile_setup/   # إعداد أولي
  Feature_3_home/            # الرئيسية
  Feature_4_visual_search/   # بحث بالصورة (عدة شاشات)
  Feature_5_collections/     # محفوظات + سجل
  Feature_6_profile/         # إعدادات الحساب
```

كل feature:
```
  data/ → data_sources, models, repos
  presentation/ → manager, views, widgets
```

Shared: `core/` (theme, API, navigation, widgets).

Main tabs use `MainShell` + `GlassBottomNavBar` via `go_router` `ShellRoute`.
