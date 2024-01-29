import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

// Syntax to fetch Images
// final List<FileObject> results = await supabase.storage.from('bucketName').list();

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool isUploading = false;
  final SupabaseClient supabase = Supabase.instance.client;

  Future getMyFiles() async {
    final List<FileObject> result = await supabase.storage
        .from('user-images')
        .list(path: supabase.auth.currentUser!.id);
    List<Map<String, String>> myImages = [];
    for (var image in result) {
      final getUrl = supabase.storage
          .from('user-images')
          .getPublicUrl("${supabase.auth.currentUser!.id}/${image.name}");
      myImages.add({'name': image.name, 'url': getUrl});
    }
    print(myImages);
    return myImages;
  }

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
      body: FutureBuilder(
        future: getMyFiles(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return const Center(
                child: Text(
                  "No Image(s) available",
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              itemBuilder: (context, index) {
                Map imageData = snapshot.data[index];
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 200,
                      width: 300,
                      child: Image.network(
                        imageData['url'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                    ),
                  ],
                );
              },
              separatorBuilder: (context, index) {
                return const Divider(
                  thickness: 2,
                  color: Colors.black,
                );
              },
              itemCount: snapshot.data.length,
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
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
