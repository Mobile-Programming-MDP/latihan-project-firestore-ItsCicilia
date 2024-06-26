import 'dart:io'; // Pastikan Anda telah mengimpor paket dart:io
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes/models/note.dart';
import 'package:notes/services/location_service.dart';
import 'package:notes/services/note_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NoteDialog extends StatefulWidget {
  final Note? note;

  NoteDialog({super.key, this.note});

  @override
  State<NoteDialog> createState() => _NoteDialogState();
}

class _NoteDialogState extends State<NoteDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _imageFile;
  Position? _position;

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _descriptionController.text = widget.note!.description;
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600, 
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _getLocation() async {
    final location = await LocationService().getCurrentLocation();
    setState(() {
      _position = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.note == null ? 'Add Notes' : 'Update Notes'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, 
        children: [
          const Text(
            'Title: ',
            textAlign: TextAlign.start,
          ),
          TextField(
            controller: _titleController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text(
              'Description: ',
            ),
          ),
          TextField(
            controller: _descriptionController,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Text('Image: '),
          ),
          _imageFile != null
              ? kIsWeb
                  ? Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: 200, 
                      ),
                      child: Image.network(
                        _imageFile!.path,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: 200, 
                      ),
                      child: Image.file(
                        File(_imageFile!.path),
                        fit: BoxFit.cover,
                      ),
                    )
              : (widget.note?.imageUrl != null &&
                      Uri.parse(widget.note!.imageUrl!).isAbsolute
                  ? Container(
                      width: double.infinity,
                      constraints: BoxConstraints(
                        maxHeight: 200, 
                      ),
                      child: Image.network(
                        widget.note!.imageUrl!,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container()),
          Row(
            children: [
              TextButton(
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Text("Pick Image from Gallery"),
              ),
              TextButton(
                onPressed: () => _pickImage(ImageSource.camera),
                child: const Text("Take Photo"),
              ),
            ],
          ),
          TextButton(
            onPressed: _getLocation,
            child: const Text("Get Location"),
          ),
          Text(
            _position?.latitude != null && _position?.longitude != null
                ? 'Current Position : ${_position!.latitude.toString()}, ${_position!.longitude.toString()}'
                : 'Current Position : ${widget.note?.lat}, ${widget.note?.lng}',
            textAlign: TextAlign.start,
          )
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ),
        ElevatedButton(
          onPressed: () async {
            String? imageUrl;
            if (_imageFile != null) {
              imageUrl = await NoteService.uploadImage(_imageFile!);
            } else {
              imageUrl = widget.note?.imageUrl;
            }

            Note note = Note(
              id: widget.note?.id,
              title: _titleController.text,
              description: _descriptionController.text,
              imageUrl: imageUrl,
              lat: _position?.latitude.toString() ?? widget.note?.lat,
              lng: _position?.longitude.toString() ?? widget.note?.lng,
              createdAt: widget.note?.createdAt,
            );

            if (widget.note == null) {
              await NoteService.addNote(note);
            } else {
              await NoteService.updateNote(note);
            }
            Navigator.of(context).pop();
          },
          child: Text(widget.note == null ? 'Add' : 'Update'),
        ),
      ],
    );
  }
}
