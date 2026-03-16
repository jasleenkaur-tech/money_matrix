// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:money_matrix/screens/settings_page.dart';
// import 'package:money_matrix/services/auth_service.dart';
// import 'package:provider/provider.dart';
// import 'app.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//       systemNavigationBarColor: Colors.black,
//       systemNavigationBarIconBrightness: Brightness.light,
//     ),
//   );
//
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//   ]);
//
//   runApp(  const MyApp());
// }
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:money_matrix/screens/home_page.dart';
// import 'package:money_matrix/screens/settings_page.dart';
// import 'package:money_matrix/services/auth_service.dart';
// import 'package:provider/provider.dart';
// import 'app.dart'; // your App widget
//
// // Make sure ThemeProvider & NotificationProvider are imported or defined
// import 'screens/settings_page.dart'; // if ThemeProvider & NotificationProvider are inside
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   SystemChrome.setSystemUIOverlayStyle(
//     const SystemUiOverlayStyle(
//       statusBarColor: Colors.transparent,
//       statusBarIconBrightness: Brightness.light,
//       systemNavigationBarColor: Colors.black,
//       systemNavigationBarIconBrightness: Brightness.light,
//     ),
//   );
//
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//   ]);
//
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ThemeProvider()),
//         ChangeNotifierProvider(create: (_) => NotificationProvider()),
//         ChangeNotifierProvider(create: (_) => AuthService()),
//       ],
//       child: const MyApp(),
//     ),
//   );
// }
//
// // ================= MY APP =================
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     // ✅ Listen to theme changes
//     final themeProvider = Provider.of<ThemeProvider>(context);
//
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Money Matrix',
//       theme: ThemeData.light(),
//       darkTheme: ThemeData.dark(),
//       themeMode: themeProvider.isDark ? ThemeMode.light : ThemeMode.dark,
//       home: const HomePage(), // Start with SettingsPage for now
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/auth_service.dart';
import 'screens/settings_page.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(

    MultiProvider(
      providers: [

        ChangeNotifierProvider(create: (_) => ThemeProvider()),

        ChangeNotifierProvider(create: (_) => NotificationProvider()),

        ChangeNotifierProvider(create: (_) => AuthService()),

      ],

      child: const MyApp(),

    ),

  );

}