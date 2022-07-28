import 'package:flutter/material.dart';
import 'package:notes/utilities/dialogs/generic_dialog.dart';

Future<void> showErrorDialog(BuildContext context, String message) {
  return showGenericDialog<void>(
    context: context,
    title: 'An error occurred',
    content: message,
    optionBuilder: () => {
      'OK': null,
    },
  );
}
