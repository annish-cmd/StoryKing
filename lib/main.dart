/*
 * MAIN APPLICATION ENTRY POINT
 * ----------------------------
 * This file serves as the entry point for the StoryKing application.
 * 
 * Key functionality:
 * 1. Initializes the Flutter app and required services
 * 2. Sets up the authentication service for user management
 * 3. Configures system UI styling (status bar transparency, etc.)
 * 4. Creates the MaterialApp with theme configuration (dark/light mode)
 * 5. Sets the initial route to the splash screen
 * 
 * The app follows a clean architecture pattern with:
 * - Screens: UI components (splash, auth, main, etc.)
 * - Services: Business logic (auth, storage, etc.)
 * - Models: Data structures (user, story, etc.)
 */

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'screens/splash_screen.dart';
// // import 'services/auth_service.dart';
// import 'services/auth/auth_service.dart';
// import 'favorites_page.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() async {
//   // required for initializing firebase in flutter
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // Initialize auth service
//   // final authService = await AuthService.init(useFirebase: true);
//   final authService = await AuthService.init();

//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//     ),
//   );

//   runApp(MyApp(authService: authService));
// }

// class MyApp extends StatefulWidget {
//   final AuthService authService;

//   const MyApp({Key? key, required this.authService}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();

//   // Provide a way to access the state from anywhere
//   static _MyAppState? of(BuildContext context) {
//     return context.findAncestorStateOfType<_MyAppState>();
//   }
// }

// class _MyAppState extends State<MyApp> {
//   bool _darkMode = true;
//   double _textScaleFactor = 1.0; // Default text scale factor

//   bool get isDarkMode => _darkMode;
//   double get textScaleFactor => _textScaleFactor;

//   @override
//   void initState() {
//     super.initState();
//     _loadPreferences();
//   }

//   Future<void> _loadPreferences() async {
//     await _loadDarkModePreference();
//     await _loadTextScaleFactorPreference();
//   }

//   Future<void> _loadDarkModePreference() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _darkMode =
//             prefs.getBool('darkMode') ?? true; // Default to true if not set
//         print('App loaded darkMode: $_darkMode'); // Debug statement
//       });
//     } catch (e) {
//       print('Error loading darkMode preference: $e');
//     }
//   }

//   Future<void> _loadTextScaleFactorPreference() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
//         print(
//             'App loaded textScaleFactor: $_textScaleFactor'); // Debug statement
//       });
//     } catch (e) {
//       print('Error loading textScaleFactor preference: $e');
//     }
//   }

//   Future<void> _saveDarkModePreference(bool value) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('darkMode', value);
//       print('App saved darkMode: $value'); // Debug statement
//     } catch (e) {
//       print('Error saving darkMode preference: $e');
//     }
//   }

//   Future<void> _saveTextScaleFactorPreference(double value) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('textScaleFactor', value);
//       print('App saved textScaleFactor: $value'); // Debug statement
//     } catch (e) {
//       print('Error saving textScaleFactor preference: $e');
//     }
//   }

//   void toggleTheme() async {
//     setState(() {
//       _darkMode = !_darkMode;
//     });
//     await _saveDarkModePreference(_darkMode);
//   }

//   void setTextScaleFactor(double scaleFactor) async {
//     setState(() {
//       _textScaleFactor = scaleFactor;
//     });
//     await _saveTextScaleFactorPreference(_textScaleFactor);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'StoryKing',
//       debugShowCheckedModeBanner: false,
//       builder: (context, child) {
//         return MediaQuery(
//           // Apply the global text scale factor to the entire app
//           data: MediaQuery.of(context).copyWith(
//             textScaleFactor: _textScaleFactor,
//           ),
//           child: child!,
//         );
//       },
//       theme: _darkMode
//           ? ThemeData.dark().copyWith(
//               primaryColor: const Color(0xFF6448FE),
//               scaffoldBackgroundColor: Colors.black,
//               appBarTheme: const AppBarTheme(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//               ),
//             )
//           : ThemeData.light().copyWith(
//               brightness: Brightness.light,
//               primaryColor: const Color(0xFF6448FE),
//               scaffoldBackgroundColor: Colors.white,
//               cardColor: Colors.white,
//               appBarTheme: const AppBarTheme(
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.black,
//                 iconTheme: IconThemeData(color: Colors.black),
//                 actionsIconTheme: IconThemeData(color: Colors.black),
//                 titleTextStyle: TextStyle(
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold),
//                 elevation: 0,
//               ),
//               textTheme: const TextTheme(
//                 bodyLarge: TextStyle(color: Colors.black),
//                 bodyMedium: TextStyle(color: Colors.black),
//                 bodySmall: TextStyle(color: Colors.black),
//                 titleLarge: TextStyle(color: Colors.black),
//                 titleMedium: TextStyle(color: Colors.black),
//                 titleSmall: TextStyle(color: Colors.black),
//                 labelLarge: TextStyle(color: Colors.black),
//               ),
//               iconTheme: const IconThemeData(
//                 color: Colors.black,
//               ),
//             ),
//       home: SplashScreen(
//         authService: widget.authService,
//         toggleTheme: toggleTheme,
//         setTextScaleFactor: setTextScaleFactor,
//       ),
//     );
//   }
// }

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   _HomePageState createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   final List<String> favoriteStories = [];
//   final List<String> allStories = [
//     "Story 1",
//     "Story 2",
//     "Story 3"
//   ]; // Example stories

//   void _toggleFavorite(String story) {
//     setState(() {
//       if (favoriteStories.contains(story)) {
//         favoriteStories.remove(story);
//       } else {
//         favoriteStories.add(story);
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Home'),
//       ),
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             DrawerHeader(
//               child: Text('Menu'),
//               decoration: BoxDecoration(
//                 color: Colors.deepPurple,
//               ),
//             ),
//             ListTile(
//               title: const Text('Home'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               title: const Text('Favorites'),
//               onTap: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) =>
//                         FavoritesPage(favoriteStories: favoriteStories),
//                   ),
//                 );
//               },
//             ),

//             // Add other menu items here
//           ],
//         ),
//       ),
//       body: ListView.builder(
//         itemCount: allStories.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(allStories[index]),
//             trailing: IconButton(
//               icon: Icon(
//                 favoriteStories.contains(allStories[index])
//                     ? Icons.favorite
//                     : Icons.favorite_border,
//               ),
//               onPressed: () => _toggleFavorite(allStories[index]),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:firebase_core/firebase_core.dart';

// // App screens
// import 'screens/splash_screen.dart';

// // Services
// import 'services/auth/auth_service.dart';
// import 'firebase_options.dart';

// void main() async {
//   // Required for initializing Firebase in Flutter
//   WidgetsFlutterBinding.ensureInitialized();

//   // Initialize Firebase
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // Initialize auth service with Firebase authentication
//   final authService = await AuthService.init(useFirebase: true);

//   // Set system UI style
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//     ),
//   );

//   // Run the app with auth service dependency
//   runApp(MyApp(authService: authService));
// }

// class MyApp extends StatefulWidget {
//   final AuthService authService;

//   const MyApp({Key? key, required this.authService}) : super(key: key);

//   @override
//   _MyAppState createState() => _MyAppState();

//   // Provide a way to access the state from anywhere
//   static _MyAppState? of(BuildContext context) {
//     return context.findAncestorStateOfType<_MyAppState>();
//   }
// }

// class _MyAppState extends State<MyApp> {
//   bool _darkMode = true;
//   double _textScaleFactor = 1.0; // Default text scale factor

//   bool get isDarkMode => _darkMode;
//   double get textScaleFactor => _textScaleFactor;

//   @override
//   void initState() {
//     super.initState();
//     _loadPreferences();
//   }

//   Future<void> _loadPreferences() async {
//     await _loadDarkModePreference();
//     await _loadTextScaleFactorPreference();
//   }

//   Future<void> _loadDarkModePreference() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _darkMode =
//             prefs.getBool('darkMode') ?? true; // Default to true if not set
//       });
//     } catch (e) {
//       print('Error loading darkMode preference: $e');
//     }
//   }

//   Future<void> _loadTextScaleFactorPreference() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
//       });
//     } catch (e) {
//       print('Error loading textScaleFactor preference: $e');
//     }
//   }

//   Future<void> _saveDarkModePreference(bool value) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setBool('darkMode', value);
//     } catch (e) {
//       print('Error saving darkMode preference: $e');
//     }
//   }

//   Future<void> _saveTextScaleFactorPreference(double value) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setDouble('textScaleFactor', value);
//     } catch (e) {
//       print('Error saving textScaleFactor preference: $e');
//     }
//   }

//   void toggleTheme() async {
//     setState(() {
//       _darkMode = !_darkMode;
//     });
//     await _saveDarkModePreference(_darkMode);
//   }

//   void setTextScaleFactor(double scaleFactor) async {
//     setState(() {
//       _textScaleFactor = scaleFactor;
//     });
//     await _saveTextScaleFactorPreference(_textScaleFactor);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'StoryKing',
//       debugShowCheckedModeBanner: false,
//       builder: (context, child) {
//         return MediaQuery(
//           // Apply the global text scale factor to the entire app
//           data: MediaQuery.of(context).copyWith(
//             textScaleFactor: _textScaleFactor,
//           ),
//           child: child!,
//         );
//       },
//       theme: _darkMode
//           ? ThemeData.dark().copyWith(
//               primaryColor: const Color(0xFF6448FE),
//               scaffoldBackgroundColor: Colors.black,
//               appBarTheme: const AppBarTheme(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//               ),
//             )
//           : ThemeData.light().copyWith(
//               brightness: Brightness.light,
//               primaryColor: const Color(0xFF6448FE),
//               scaffoldBackgroundColor: Colors.white,
//               cardColor: Colors.white,
//               appBarTheme: const AppBarTheme(
//                 backgroundColor: Colors.white,
//                 foregroundColor: Colors.black,
//                 iconTheme: IconThemeData(color: Colors.black),
//                 actionsIconTheme: IconThemeData(color: Colors.black),
//                 titleTextStyle: TextStyle(
//                     color: Colors.black,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold),
//                 elevation: 0,
//               ),
//               textTheme: const TextTheme(
//                 bodyLarge: TextStyle(color: Colors.black),
//                 bodyMedium: TextStyle(color: Colors.black),
//                 bodySmall: TextStyle(color: Colors.black),
//                 titleLarge: TextStyle(color: Colors.black),
//                 titleMedium: TextStyle(color: Colors.black),
//                 titleSmall: TextStyle(color: Colors.black),
//                 labelLarge: TextStyle(color: Colors.black),
//               ),
//               iconTheme: const IconThemeData(
//                 color: Colors.black,
//               ),
//             ),
//       home: SplashScreen(
//         authService: widget.authService,
//         toggleTheme: toggleTheme,
//         setTextScaleFactor: setTextScaleFactor,
//       ),
//     );
//   }
// }

import 'package:android_app/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';

// Screens
import 'screens/splash_screen.dart';

// Services
import 'services/auth/auth_service.dart';
import 'services/storage_service.dart';
import 'services/storage/firebase_storage_repository.dart';
import 'firebase_options.dart';

void main() async {
  // Required for initializing Firebase in Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize auth service with Firebase authentication
  final authService = await AuthService.init(useFirebase: true);

  // Initialize storage service
  final firebaseRepository = FirebaseStorageRepository();
  await StorageService.init(
      firebaseRepository: firebaseRepository, useFirebase: true);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Run the app with auth service dependency
  runApp(MyApp(authService: authService));
}

class MyApp extends StatefulWidget {
  final AuthService authService;

  const MyApp({Key? key, required this.authService}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();

  // Provide a way to access the state from anywhere
  static _MyAppState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MyAppState>();
  }
}

class _MyAppState extends State<MyApp> {
  bool _darkMode = true;
  double _textScaleFactor = 1.0; // Default text scale factor

  bool get isDarkMode => _darkMode;
  double get textScaleFactor => _textScaleFactor;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    await _loadDarkModePreference();
    await _loadTextScaleFactorPreference();
  }

  Future<void> _loadDarkModePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _darkMode =
            prefs.getBool('darkMode') ?? true; // Default to true if not set
      });
    } catch (e) {
      print('Error loading darkMode preference: $e');
    }
  }

  Future<void> _loadTextScaleFactorPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _textScaleFactor = prefs.getDouble('textScaleFactor') ?? 1.0;
      });
    } catch (e) {
      print('Error loading textScaleFactor preference: $e');
    }
  }

  Future<void> _saveDarkModePreference(bool value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('darkMode', value);
    } catch (e) {
      print('Error saving darkMode preference: $e');
    }
  }

  Future<void> _saveTextScaleFactorPreference(double value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('textScaleFactor', value);
    } catch (e) {
      print('Error saving textScaleFactor preference: $e');
    }
  }

  void toggleTheme() async {
    setState(() {
      _darkMode = !_darkMode;
    });
    await _saveDarkModePreference(_darkMode);
  }

  void setTextScaleFactor(double scaleFactor) async {
    setState(() {
      _textScaleFactor = scaleFactor;
    });
    await _saveTextScaleFactorPreference(_textScaleFactor);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StoryKing',
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return MediaQuery(
          // Apply the global text scale factor to the entire app
          data: MediaQuery.of(context).copyWith(
            textScaleFactor: _textScaleFactor,
          ),
          child: child!,
        );
      },
      theme: _darkMode
          ? ThemeData.dark().copyWith(
              primaryColor: const Color(0xFF6448FE),
              scaffoldBackgroundColor: Colors.black,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.transparent,
                elevation: 0,
              ),
            )
          : ThemeData.light().copyWith(
              brightness: Brightness.light,
              primaryColor: const Color(0xFF6448FE),
              scaffoldBackgroundColor: Colors.white,
              cardColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                iconTheme: IconThemeData(color: Colors.black),
                actionsIconTheme: IconThemeData(color: Colors.black),
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
                elevation: 0,
              ),
              textTheme: const TextTheme(
                bodyLarge: TextStyle(color: Colors.black),
                bodyMedium: TextStyle(color: Colors.black),
                bodySmall: TextStyle(color: Colors.black),
                titleLarge: TextStyle(color: Colors.black),
                titleMedium: TextStyle(color: Colors.black),
                titleSmall: TextStyle(color: Colors.black),
                labelLarge: TextStyle(color: Colors.black),
              ),
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
            ),
      routes: {
        '/': (context) => SplashScreen(
              authService: widget.authService,
              toggleTheme: toggleTheme,
              setTextScaleFactor: setTextScaleFactor,
            ),
        '/main_screen': (context) => MainScreen(
            authService: widget.authService,
            toggleTheme: toggleTheme,
            setTextScaleFactor: setTextScaleFactor)
      },
    );
  }
}
