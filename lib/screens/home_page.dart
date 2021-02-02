import 'package:flutter/material.dart';
import 'package:phone_book/database/db_helper/db_helper.dart';
import 'package:phone_book/model/contact.dart';
import 'package:phone_book/screens/contact_add.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DbHelper _dbHelper;

  @override
  void initState() {
    _dbHelper = DbHelper();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Number List"),
      ),
      body: FutureBuilder(
          future: _dbHelper.getContact(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            if (snapshot.data.isEmpty) {
              return Center(
                child: Text("No Number"),
              );
            }
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                Contact contact = snapshot.data[index];

                return Dismissible(
                  key: UniqueKey(),
                  onDismissed: (direction) async {
                    _dbHelper.removeAt(contact.id);

                    Scaffold.of(context).showSnackBar(
                      SnackBar(
                        content: Text("${contact.name} dismissed"),
                        action: SnackBarAction(
                          label: "Geri Al",
                          onPressed: () {
                            setState(() {
                              _dbHelper.contactAdd(contact);
                            });
                          },
                        ),
                      ),
                    );
                  },
                  background: Container(color: Colors.red),
                  child: ListTile(
                    contentPadding: EdgeInsets.only(
                      left: 0.0,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      radius: 50.0,
                      backgroundImage: contact.avatar == ""
                          ? AssetImage("assets/person.png")
                          : AssetImage(contact.avatar),
                    ),
                    title: Text(contact.name),
                    subtitle: Text(contact.phoneNumber),
                  ),
                );
              },
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContactAdd(),
          ),
        ),
        child: Icon(
          Icons.add,
          size: 30,
        ),
      ),
    );
  }
}
