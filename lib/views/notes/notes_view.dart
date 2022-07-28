import 'package:flutter/material.dart';
import 'package:notes/services/crud/notes_service.dart';
import 'package:notes/utilities/dialogs/logout_dialog.dart';
import 'package:notes/views/notes/notes_list_view.dart';
import 'dart:developer' as devtools show log;

import '../../enums/menu_action.dart';
import '../../constants/routers.dart';
import '../../services/auth/auth_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({Key? key}) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  late final NotesService _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email;

  @override
  void initState() {
    _notesService = NotesService();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(createUpdateNoteRoute);
            },
            icon: const Icon(Icons.add),
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              devtools.log(value.toString());
              switch (value) {
                case MenuAction.logout:
                  final navigator = Navigator.of(context);
                  final shouldLogout = await _showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logout();

                    navigator.pushNamedAndRemoveUntil(loginRoute, (_) => false);
                  }
                  break;
              }
            },
            itemBuilder: (context) {
              return const [
                PopupMenuItem<MenuAction>(
                  value: MenuAction.logout,
                  child: Text('Logout'),
                )
              ];
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _notesService.getOrCreateUser(email: userEmail),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              {
                return StreamBuilder(
                  stream: _notesService.allNotes,
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        {
                          if (snapshot.hasData) {
                            final allNotes =
                                snapshot.data as List<DatabaseNote>;
                            return NotesListView(
                              notes: allNotes,
                              onDeleteNote: (note) async {
                                await _notesService.deleteNote(id: note.id);
                              },
                              onTap: (note) {
                                Navigator.of(context).pushNamed(
                                  createUpdateNoteRoute,
                                  arguments: note,
                                );
                              },
                            );
                          } else {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                        }
                      default:
                        {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                    }
                  },
                );
              }
            default:
              {
                return const Center(child: CircularProgressIndicator());
              }
          }
        },
      ),
    );
  }

  Future<bool> _showLogoutDialog(BuildContext context) {
    return showLogOutDialog(context);
  }
}
