// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/theme.dart';
// import '../services/auth_service.dart';
// import '../screens/splash_screen.dart';
// import '../screens/home_page.dart';
// import '../screens/auth/login_page.dart';
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) {
//         final auth = AuthService();
//         auth.loadFromStorage();
//         return auth;
//       },
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.darkTheme,
//         home: const AuthWrapper(),
//       ),
//     );
//   }
// }
//
// /// AUTH FLOW CONTROLLER
// class AuthWrapper extends StatelessWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<AuthService>(
//       builder: (context, auth, _) {
//         if (auth.isLoading) {
//           return const SplashScreen();
//         }
//         return auth.loggedIn ? const HomePage() : const LoginPage();
//       },
//     );
//   }
// }
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../core/theme.dart';
// import '../services/auth_service.dart';
// import '../screens/splash_screen.dart';
// import '../screens/home_page.dart';
// import '../screens/auth/login_page.dart';
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) {
//         final auth = AuthService();
//         auth.loadFromStorage();
//         return auth;
//       },
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.darkTheme,
//         home: const AuthWrapper(),
//       ),
//     );
//   }
// }
//
// /// AUTH FLOW CONTROLLER
// class AuthWrapper extends StatefulWidget {
//   const AuthWrapper({super.key});
//
//   @override
//   State<AuthWrapper> createState() => _AuthWrapperState();
// }
//
// class _AuthWrapperState extends State<AuthWrapper> {
//
//   bool showSplash = true;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // 5 second splash timer
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) {
//         setState(() {
//           showSplash = false;
//         });
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (showSplash) {
//       return const SplashScreen();
//     }
//
//     return Consumer<AuthService>(
//       builder: (context, auth, _) {
//         return auth.loggedIn ? const HomePage() : const LoginPage();
//       },
//     );
//   }


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_page.dart';
import 'screens/auth/login_page.dart';

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      title: 'Money Matrix',

      theme: ThemeData.dark(),

      home: const AuthWrapper(),

    );

  }

}

class AuthWrapper extends StatefulWidget {

  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();

}

class _AuthWrapperState extends State<AuthWrapper> {

  bool showSplash = true;

  @override
  void initState() {

    super.initState();

    Future.delayed(const Duration(seconds: 2), () {

      if (mounted) {

        setState(() {

          showSplash = false;

        });

      }

    });

  }

  @override
  Widget build(BuildContext context) {

    if (showSplash) {

      return const SplashScreen();

    }

    return Consumer<AuthService>(

      builder: (context, auth, _) {

        if (auth.loggedIn) {

          return const HomePage();

        }

        return const LoginPage();

      },

    );

  }

}