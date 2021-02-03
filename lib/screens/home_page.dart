import 'package:flutter/material.dart';
import 'package:phone_book/database/db_helper/db_helper.dart';
import 'package:phone_book/model/contact.dart';
import 'package:phone_book/screens/contact_add.dart';
import 'package:search_page/search_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DbHelper _dbHelper;
  List<Contact> contactList = List<Contact>();

  void getNotes() async {
    var notesFuture = _dbHelper.getContact();
    await notesFuture.then((data) {
      setState(() {
        this.contactList = data;
      });
    });
  }

  @override
  void initState() {
    _dbHelper = DbHelper();
    getNotes();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Phone Number List"),
      ),
      body: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
                hintText: 'Search people',
                hintStyle: TextStyle(fontSize: 20),
                contentPadding: EdgeInsets.all(16.0),
                suffixIcon: Icon(
                  Icons.search,
                  size: 30,
                )),
            onTap: () => showSearch(
              context: context,
              delegate: SearchPage<Contact>(
                items: contactList,
                searchLabel: 'Search people',
                suggestion: Center(
                  child: Text('Filter people by name or phone number'),
                ),
                failure: Center(
                  child: Text('No person found :('),
                ),
                filter: (person) => [
                  person.name,
                  person.phoneNumber,
                ],
                builder: (person) => ListTile(
                  title: Text(person.name),
                  subtitle: Text(person.phoneNumber),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
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

                      return _buildDismissible(contact, context);
                    },
                  );
                }),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  Dismissible _buildDismissible(Contact contact, BuildContext context) {
    return Dismissible(
      direction: DismissDirection.endToStart,
      key: UniqueKey(),
      onDismissed: (direction) async {
        _dbHelper.removeAt(contact.id);

        Scaffold.of(context).showSnackBar(
          SnackBar(
            content: Text("${contact.name} dismissed..."),
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
      background: _buildDissmisedContainer(),
      child: _buildGestureDetector(context, contact),
    );
  }

  GestureDetector _buildGestureDetector(BuildContext context, Contact contact) {
    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ContactAdd(
                    contact: contact,
                  ))),
      child: _buildListTile(contact),
    );
  }

  Container _buildDissmisedContainer() {
    return Container(
      color: Colors.red,
      child: Padding(
        padding: const EdgeInsets.only(left: 350.0),
        child: Icon(
          Icons.delete_sharp,
          size: 25,
          color: Colors.white,
        ),
      ),
    );
  }

  ListTile _buildListTile(Contact contact) {
    return ListTile(
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
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ContactAdd(
            contact: Contact(),
          ),
        ),
      ),
      child: Icon(
        Icons.add,
        size: 30,
      ),
    );
  }
}
