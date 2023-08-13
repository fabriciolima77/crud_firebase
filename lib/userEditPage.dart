import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserEditPage extends StatelessWidget {
   UserEditPage({
    required this.name,
    required this.age,
    required this.date,
    required this.id,
    super.key});

  final String name;
  final String age;
  final String date;
  final String id;

  final controllerName = TextEditingController();
  final controllerAge = TextEditingController();
  final controllerDate = TextEditingController();

   @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Editar ${name.toString()}'),
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: controllerName,
          decoration: decoration(name),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: controllerAge,
          decoration: decoration(age),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 24),
        TextField(
            controller: controllerDate,
            decoration: InputDecoration(
                icon: const Icon(Icons.calendar_today),
                labelText: date
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

                  controllerDate.text = formattedDate;
              }else{
                print("Date is not selected");
              }
            }
        ),


        const SizedBox(height: 32),
        ElevatedButton(
          child: const Text('Edit'),
          onPressed: (){
            final docUser = FirebaseFirestore.instance
                .collection('users')
                .doc(id);

            docUser.update({
              'age': int.parse(controllerAge.text),
              'birthday': DateTime.parse(controllerDate.text),
              'id': id,
              'name': controllerName.text,
            });

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
}
