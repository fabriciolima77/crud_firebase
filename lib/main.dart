import 'dart:core';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_firebase/userEditPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'userPage.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyBsTNK4XK9EAMjWMntF8MZQLABjjHF-s6Y",
        appId: "1:71423075446:web:e5624f29489fa16b4cab57",
        messagingSenderId: "G-88RVJT1FJB",
        projectId: "crud-firebase-92cba",
        storageBucket: "gs://crud-firebase-92cba.appspot.com",
    )
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Firebase',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Form Firebase'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final controller = TextEditingController();
  final String _orderBy = 'name';
  bool _isDescending = false;
  final _valores = ['A-Z', 'Z-A'];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Row(
        children: [
          const Text('Pessoas cadastradas'),
          DropdownButton(
              items: _valores.map((String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Text(dropDownStringItem),
                );
              }).toList(),
              icon: const Icon(Icons.sort),
              onChanged: (String? value){
                setState(() {
                  _isDescending = !_isDescending;
                });
              }
          ),
        ],
      ),
    ),
    body: StreamBuilder<List<User>>(
        stream: readUsers(),
        builder: (context, snapshot) {
          if(snapshot.hasError) {
            return const Center(
              child: Text('Erro na obtenção de dados :(',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }else if(snapshot.hasData) {
            final users = snapshot.data!;

            return ListView(
              children: users.map(buildUser).toList(),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        }
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPage()))
    ),
  );

  Widget buildUser(User user) => ListTile(
    leading: SizedBox(
      height: 50,
        width: 50,
        child: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/crud-firebase-92cba.appspot.com/o/profileImages%2F${user.name}-${user.profileImage}?alt=media',
          fit: BoxFit.fill,
          scale: 0.5,
        ),
      /*Text('${user.age}')*/
    ),
    title: Text(user.name),
    subtitle: Text(DateFormat('dd MMMM yyyy').format(user.birthday)),
    trailing: SizedBox(
      height: 30,
      width: 100,
      child: Row(
        children: [
          IconButton(
            onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
            UserEditPage(date: '${user.birthday}', id: user.id, name: user.name, age: '${user.age}',))),
            icon: const Icon(Icons.edit),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () async {
              final docUser = FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.id);

              docUser.update({
                'isActive': false,
              });

              docUser.delete();
              final ref = FirebaseStorage.instance.ref().child('profileImages/${user.name}-${user.profileImage}');
              await ref.delete();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    )
  );

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('users')
      .orderBy(_orderBy, descending: _isDescending)
      /*.where('isActive', isEqualTo: 'true')*/
      .snapshots()
      .map((snapshot) =>
        snapshot.docs.map((doc) => User.fromJson(doc.data())).toList());

      Future<User?> readUser() async {
        final docUser = FirebaseFirestore.instance.collection('users').doc();
        final snapshot = await docUser.get();
        if (snapshot.exists) {
          return User.fromJson(snapshot.data()!);
        }
        return null;
      }

  /*Future createUser({required String name}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();

    final user = User(
      id: docUser.id,
      name: name,
      age: 21,
      birthday: DateTime(2001, 7, 28),
      profileImage: '',
      isActive: true,
    );
    final json = user.toJson();
    await docUser.set(json);
  }*/
}

  class User {
    String id;
    final String name;
    final int age;
    final DateTime birthday;
    final String profileImage;
    final bool isActive;

    User({
      this.id = '',
      required this.name,
      required this.age,
      required this.birthday,
      required this.profileImage,
      required this.isActive,
    });

    Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'age': age,
      'birthday': birthday,
      'profileImage': profileImage,
      'isActive': isActive,
    };

    static User fromJson(Map<String, dynamic> json) => User(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      birthday: (json['birthday']).toDate(),
      profileImage: json['profileImage'],
      isActive: json['isActive'],
    );
}
