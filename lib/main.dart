import 'package:flutter/material.dart';
import 'package:notes/services/auth/auth_service.dart';
import 'package:notes/views/email_verification_view.dart';
import 'package:notes/views/notes/notes_view.dart';
import 'package:notes/views/registration_view.dart';
import 'dart:developer' as devtools show log;

import 'constants/routers.dart';
import 'views/login_view.dart';
import 'views/notes/create_update_note_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      routes: {
        loginRoute: (context) => const LoginView(),
        registerRoute: (context) => const RegistrationView(),
        notesRoute: (context) => const NotesView(),
        verifyEmailRoute: (context) => const EmailVerificationView(),
        createUpdateNoteRoute: (context) => const CreateUpdateNoteView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            {
              final user = AuthService.firebase().currentUser;
              if (user != null) {
                final isEmailVerified = user.isEmailVerified;
                if (isEmailVerified) {
                  devtools.log('Verified user');
                  return const NotesView();
                } else {
                  devtools.log('Not verified');
                  //return const NotesView();
                  return const EmailVerificationView();
                }
              } else {
                return const LoginView();
              }
            }
          default:
            {
              return const CircularProgressIndicator();
            }
        }
      },
    );
  }
}
