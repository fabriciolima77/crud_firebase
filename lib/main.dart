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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Pessoas cadastradas'),
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
    leading: CircleAvatar(
        child: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/crud-firebase-92cba.appspot.com/o/profileImages%2F${user.name}-${user.profileImage}?alt=media',
          fit: BoxFit.contain,
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
            onPressed: (){
              final docUser = FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.id);

                  docUser.delete();
            },
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
    )
  );

  Stream<List<User>> readUsers() => FirebaseFirestore.instance
      .collection('users')
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

  Future createUser({required String name}) async {
    final docUser = FirebaseFirestore.instance.collection('users').doc();

    final user = User(
      id: docUser.id,
      name: name,
      age: 21,
      birthday: DateTime(2001, 7, 28),
      profileImage: '',
    );
    final json = user.toJson();
    await docUser.set(json);
  }
}

  class User {
    String id;
    final String name;
    final int age;
    final DateTime birthday;
    final String profileImage;

    User({
      this.id = '',
      required this.name,
      required this.age,
      required this.birthday,
      required this.profileImage,
    });

    Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'age': age,
      'birthday': birthday,
      'profileImage': profileImage,
    };

    static User fromJson(Map<String, dynamic> json) => User(
      id: json['id'],
      name: json['name'],
      age: json['age'],
      birthday: (json['birthday']).toDate(),
      profileImage: json['profileImage'],
    );
}
