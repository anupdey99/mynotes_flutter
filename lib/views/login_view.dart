import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import '../constants/routers.dart';
import '../services/auth/auth_exceptions.dart';
import '../services/auth/auth_service.dart';
import '../utilities/dialogs/error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _MyLoginView();
}

class _MyLoginView extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            decoration: const InputDecoration(hintText: "Email"),
            keyboardType: TextInputType.emailAddress,
          ),
          TextField(
            controller: _password,
            decoration: const InputDecoration(hintText: "Password"),
            keyboardType: TextInputType.text,
            enableSuggestions: false,
            autocorrect: false,
            obscureText: true,
          ),
          TextButton(
            onPressed: () {
              _login();
            },
            child: const Text("Login"),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('Not register yet? Register now!'))
        ],
      ),
    );
  }

  void _login() async {
    final email = _email.text;
    final pass = _password.text;
    try {
      final navigator = Navigator.of(context);
      final user =
          await AuthService.firebase().login(email: email, password: pass);
      devtools.log(user.toString());
      if (user.isEmailVerified) {
        navigator.pushNamedAndRemoveUntil(notesRoute, (_) => false);
      } else {
        navigator.pushNamedAndRemoveUntil(verifyEmailRoute, (_) => false);
      }
    } on UserNotFoundAuthException {
      await showErrorDialog(
        context,
        'User not found',
      );
    } on WrongPasswordAuthException {
      await showErrorDialog(
        context,
        'Wrong credentials',
      );
    } on GenericAuthException {
      await showErrorDialog(
        context,
        'Authentication error',
      );
    }
  }
}
