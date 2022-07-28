import 'package:flutter/material.dart';

import '../constants/routers.dart';
import '../services/auth/auth_service.dart';

class EmailVerificationView extends StatelessWidget {
  const EmailVerificationView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Email verification'),
      ),
      body: Column(
        children: [
          const Text("We have send a verification email"),
          const Text("If you have not get any email, try again"),
          TextButton(
            onPressed: () async {
              await AuthService.firebase().sendEmailVerification();
            },
            child: const Text('Send verification email'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              await AuthService.firebase().logout();
              navigator.pushNamedAndRemoveUntil(registerRoute, (_) => false);
            },
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
