import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/language_service.dart';
import 'services/settings_service.dart';
import 'services/favorites_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.initialize();
  
  // Initialize favorites service
  final favoritesService = FavoritesService();
  await favoritesService.initialize();
  
  // Get available cameras
  final cameras = await availableCameras();
  
  // Get the first back camera
  final camera = cameras.firstWhere(
    (camera) => camera.lensDirection == CameraLensDirection.back,
    orElse: () => cameras.first,
  );
  
  runApp(MyApp(
    camera: camera,
    settingsService: settingsService,
    favoritesService: favoritesService,
  ));
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;
  final SettingsService settingsService;
  final FavoritesService favoritesService;
  final LanguageService languageService = LanguageService();
  
  MyApp({
    super.key,
    required this.camera,
    required this.settingsService,
    required this.favoritesService,
  });
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Groceye',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: OnboardingScreen(
        camera: camera,
        languageService: languageService,
        settingsService: settingsService,
        favoritesService: favoritesService,
      ),
    );
  }
}
