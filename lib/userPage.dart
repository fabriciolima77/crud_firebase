import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'main.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserPage extends StatefulWidget {
  const UserPage({
    super.key
  });

  @override
  State<UserPage> createState() => UserPageState();
}

class UserPageState extends State<UserPage> {
  final controllerName = TextEditingController();
  final controllerAge = TextEditingController();
  final controllerDate = TextEditingController();
  PlatformFile? pickedFile;
  UploadTask? uploadTask;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Cadastro de pessoas'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (pickedFile != null)
          SizedBox(
              child: Container(
                height: 400,
                width: 200,
                color: Colors.blue,
                child: Center(
                  child: Image.memory(pickedFile!.bytes!, fit: BoxFit.contain,),
                  ),
              )
          ),
        const SizedBox(height: 20),
        IconButton(
            onPressed: selectFile,
            icon: const Icon(
                Icons.add_a_photo_outlined,
                size: 40,
            )
        ),
        const SizedBox(height: 40),
        TextField(
          controller: controllerName,
          decoration: decoration('Name'),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controllerAge,
          decoration: decoration('Age'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controllerDate,
          decoration: const InputDecoration(
            icon: Icon(Icons.calendar_today),
            labelText: "Data Nascimento"
          ),
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate:DateTime(1923),
                  lastDate: DateTime(2101),
              );
              if(pickedDate != null ){
                print(pickedDate);
                String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
                print(formattedDate);

                setState(() {
                  controllerDate.text = formattedDate;
                });
              }else{
                print("Date is not selected");
              }
            }
        ),


        const SizedBox(height: 32),
        ElevatedButton(
            child: const Text('Create'),
            onPressed: (){
              final user = User(
                  name: controllerName.text,
                  age: int.parse(controllerAge.text),
                  birthday: DateTime.parse(controllerDate.text),
                  profileImage: pickedFile!.name,
                  isActive: true,
              );

              createUser(user);
              uploadFile();

              Navigator.pop(context);
            },
        ),
      ],
    ),
  );

  InputDecoration decoration (String label) => InputDecoration(
    labelText: label,
    border: const OutlineInputBorder(),
  );

  Future createUser(User user) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();
    user.id = docUser.id;

    final json = user.toJson();
    await docUser.set(json);
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image
    );
    if (result == null) return;
    setState(() {
      pickedFile = result.files.first;
    });
  }

  Future uploadFile() async {
    final result = pickedFile;

    if (result != null) {
      final fileBytes = result.bytes;
      final fileName = result.name;

      // upload file
      /*await FirebaseStorage.instance.ref('uploads/$fileName').putData(fileBytes!);*/
      final ref = FirebaseStorage.instance.ref().child('profileImages/${controllerName.text}-$fileName');
      uploadTask = ref.putData(fileBytes!);

    }
  }
}
