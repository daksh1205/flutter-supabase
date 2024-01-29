import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool isUploading = false;
  final SupabaseClient supabase = Supabase.instance.client;

  Future uploadFile() async {
    var pickedFile = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);
    if (pickedFile != null) {
      setState(() {
        isUploading = true;
      });
      try {
        File file = File(pickedFile.files.first.path!);
        String fileName = pickedFile.files.first.name;
        String uploadedUrl = await supabase.storage
            .from('user-images')
            .upload("${supabase.auth.currentUser!.id}/$fileName", file);
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text("File Uploaded Successfully !"),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        print("ERROR : $e");
        setState(() {
          isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Something went Wrong!'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Supabase Storage",
        ),
      ),
      body: Container(),
      floatingActionButton: isUploading
          ? const CircularProgressIndicator()
          : FloatingActionButton(
              onPressed: uploadFile,
              child: Icon(
                Icons.add_a_photo,
              ),
            ),
    );
  }
}
