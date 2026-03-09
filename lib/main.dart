import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/listing/listing_bloc.dart';
import 'bloc/my_listings/my_listings_bloc.dart';
import 'bloc/settings/settings_bloc.dart';
import 'bloc/settings/settings_event.dart';
import 'bloc/settings/settings_state.dart';
import 'services/auth_service.dart';
import 'services/listing_service.dart';
import 'services/settings_service.dart';
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with platform-specific options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize services
    final authService = AuthService();
    final listingService = ListingService();
    final settingsService = SettingsService();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(create: (context) => authService),
        RepositoryProvider<ListingService>(create: (context) => listingService),
        RepositoryProvider<SettingsService>(
          create: (context) => settingsService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authService: authService)
                  ..add(const AuthCheckRequested()),
          ),
          BlocProvider<ListingBloc>(
            create: (context) => ListingBloc(listingService: listingService),
          ),
          BlocProvider<MyListingsBloc>(
            create: (context) => MyListingsBloc(listingService: listingService),
          ),
          BlocProvider<SettingsBloc>(
            create: (context) =>
                SettingsBloc(settingsService: settingsService)
                  ..add(const LoadSettings()),
          ),
        ],
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, settingsState) {
            return MaterialApp(
              title: 'Kigali City Services Directory',
              debugShowCheckedModeBanner: false,
              themeMode: settingsState.darkModeEnabled
                  ? ThemeMode.dark
                  : ThemeMode.light,
              theme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.light,
                ),
                useMaterial3: true,
                appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
                cardTheme: CardThemeData(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              darkTheme: ThemeData(
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.deepPurple,
                  brightness: Brightness.dark,
                ),
                useMaterial3: true,
                appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
                cardTheme: CardThemeData(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              home: const AuthWrapper(),
            );
          },
        ),
      ),
    );
  }
}
