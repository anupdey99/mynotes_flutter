import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;

import '../constants/routers.dart';
import '../services/auth/auth_exceptions.dart';
import '../services/auth/auth_service.dart';
import '../utilities/dialogs/error_dialog.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({Key? key}) : super(key: key);

  @override
  State<RegistrationView> createState() => _MyRegistrationView();
}

class _MyRegistrationView extends State<RegistrationView> {
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
        title: const Text('Register'),
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
              _register(context);
            },
            child: const Text("Register"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(loginRoute, (route) => false);
            },
            child: const Text('Already registered? Login now!'),
          )
        ],
      ),
    );
  }

  void _register(BuildContext context) async {
    final email = _email.text;
    final pass = _password.text;
    try {
      final navigator = Navigator.of(context);
      final user =
          await AuthService.firebase().createUser(email: email, password: pass);
      devtools.log(user.toString());
      AuthService.firebase().sendEmailVerification();
      navigator.pushNamed(verifyEmailRoute);
    } on WeakPasswordAuthException {
      await showErrorDialog(
        context,
        'Weak password',
      );
    } on EmailAlreadyInUseAuthException {
      await showErrorDialog(
        context,
        'Email is already in use',
      );
    } on InvalidEmailAuthException {
      await showErrorDialog(
        context,
        'This is an invalid email address',
      );
    } on GenericAuthException {
      await showErrorDialog(
        context,
        'Failed to register',
      );
    }
  }
}
