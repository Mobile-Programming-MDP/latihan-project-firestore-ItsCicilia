import 'package:flutter/material.dart';
import 'package:notes/models/note.dart';
import 'package:notes/screens/google_maps_screen.dart';
import 'package:notes/services/note_service.dart';
import 'package:notes/widgets/note_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cross_file/cross_file.dart';

class NoteListScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onToggleTheme;

  const NoteListScreen({
    Key? key,
    required this.isDarkMode,
    required this.onToggleTheme,
  }) : super(key: key);

  @override
  State<NoteListScreen> createState() => _NoteListScreenState();
}

class _NoteListScreenState extends State<NoteListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.onToggleTheme,
            activeColor: Colors.white,
            inactiveTrackColor: Colors.grey[300],
            activeTrackColor: Colors.deepPurple,
          ),
        ],
      ),
      body: const NoteList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return NoteDialog();
            },
          );
        },
        tooltip: 'Add Note',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class NoteList extends StatelessWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: NoteService.getNoteList(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return const Center(
              child: CircularProgressIndicator(),
            );
          default:
            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: snapshot.data!.map<Widget>((document) {
                return Card(
                  color: Theme.of(context).cardColor,
                  child: Column(
                    children: [
                      document.imageUrl != null &&
                              Uri.parse(document.imageUrl!).isAbsolute
                          ? ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image.network(
                                document.imageUrl!,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            )
                          : Container(),
                      ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return NoteDialog(note: document);
                            },
                          );
                        },
                        title: Text(document.title),
                        subtitle: Text(document.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            document.lat != null && document.lng != null
                                ? InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GoogleMapsScreen(
                                            document.lat,
                                            document.lng,
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10),
                                      child: Icon(Icons.map),
                                    ),
                                  )
                                : const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Icon(
                                      Icons.map,
                                      color: Colors.grey,
                                    ),
                                  ),
                            InkWell(
                              onTap: () {
                                showAlertDialog(context, document);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Icon(Icons.delete),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                shareNote(document);
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Icon(Icons.share),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
        }
      },
    );
  }

  Future<void> openMap(String? lat, String? lng) async {
    Uri uri =
        Uri.parse("https://www.google.com/maps/search/?api=1&query=$lat,$lng");
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  void showAlertDialog(BuildContext context, Note document) {
    // set up the buttons
    Widget cancelButton = ElevatedButton(
      child: const Text("No"),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = ElevatedButton(
      child: const Text("Yes"),
      onPressed: () {
        NoteService.deleteNote(document).whenComplete(() {
          Navigator.of(context).pop();
        });
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Text("Delete Note"),
      content: const Text("Are you sure to delete Note?"),
      actions: [
        cancelButton,
        continueButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> shareNote(Note note) async {
    final StringBuffer content = StringBuffer()
      ..writeln('Title: ${note.title}')
      ..writeln('Description: ${note.description}');

    if (note.imageUrl != null && Uri.parse(note.imageUrl!).isAbsolute) {
      content.writeln('Image: ${note.imageUrl}');
    }

    if (note.lat != null && note.lng != null) {
      final String mapUrl =
          'https://www.google.com/maps/search/?api=1&query=${note.lat},${note.lng}';
      content.writeln('Location: $mapUrl');
    }

    if (note.imageUrl != null && Uri.parse(note.imageUrl!).isAbsolute) {
      try {
        final response = await http.get(Uri.parse(note.imageUrl!));
        final documentDirectory = await getApplicationDocumentsDirectory();
        final file = File('${documentDirectory.path}/shared_image.png');
        file.writeAsBytesSync(response.bodyBytes);

        await Share.shareXFiles([XFile(file.path)],
            text: content.toString(), subject: 'Check out this note');
      } catch (e) {
        print('Error sharing note: $e');
        Share.share(content.toString(), subject: 'Check out this note');
      }
    } else {
      Share.share(content.toString(), subject: 'Check out this note');
    }
  }
}
