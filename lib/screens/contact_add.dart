import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_book/database/db_helper/db_helper.dart';
import 'package:phone_book/model/contact.dart';
import 'package:phone_book/screens/home_page.dart';

class ContactAdd extends StatefulWidget {
  @override
  _ContactAddState createState() => _ContactAddState();
}

class _ContactAddState extends State<ContactAdd> {
  FocusNode focusNode;
  File _file;
  final picker = ImagePicker();
  TextEditingController _nameController;
  TextEditingController _numberController;
  DbHelper _dbHelper = DbHelper();

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
    _nameController = TextEditingController();
    _numberController = TextEditingController();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Person Add"),
        actions: [
          IconButton(
              iconSize: 30,
              icon: Icon(
                Icons.send_outlined,
                color: Colors.white,
              ),
              onPressed: () async {
                var contact = Contact(
                    name: _nameController.text,
                    phoneNumber: _numberController.text,
                    avatar: _file == null ? "" : _file.path);
                await _dbHelper.contactAdd(contact);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => HomePage()));
              })
        ],
      ),
      body: ListView(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.width / 1.5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: _file == null
                        ? AssetImage("assets/person.png")
                        : FileImage(
                            _file,
                          ),
                  ),
                ),
              ),
              IconButton(
                iconSize: 55,
                color: Colors.grey,
                icon: Icon(Icons.add_a_photo),
                onPressed: () => _buildShowDialog(context),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            autofocus: true,
            onSubmitted: (_) => focusNode.requestFocus(),
            decoration: InputDecoration(
              hintText: "Person Name",
              contentPadding: EdgeInsets.only(left: 10),
            ),
            controller: _nameController,
          ),
          SizedBox(
            height: 10,
          ),
          TextField(
            focusNode: focusNode,
            decoration: InputDecoration(
                hintText: "Person Number",
                contentPadding: EdgeInsets.only(left: 10)),
            controller: _numberController,
          ),
        ],
      ),
    );
  }

  _buildShowDialog(BuildContext context) {
    return showDialog(
      context: context,
      child: SimpleDialog(
        title: Text(
          "Fotoğraf Seç",
        ),
        children: [
          _buildSimpleDialogOption("Fotoğraf Çek", () => _takeToPhoto()),
          _buildSimpleDialogOption("Galeriden Seç", () => _getGallery()),
          _buildSimpleDialogOption("İptal", () => Navigator.pop(context)),
        ],
      ),
    );
  }

  _buildSimpleDialogOption(String text, func()) {
    return SimpleDialogOption(
      child: Text(text),
      onPressed: () => func(),
    );
  }

  _takeToPhoto() async {
    Navigator.pop(context);
    final pickedFile =
        await picker.getImage(source: ImageSource.camera, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _file = File(pickedFile.path);
      } else {
        return Text("Resim Seçiniz...");
      }
    });
  }

  _getGallery() async {
    Navigator.pop(context);
    final pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 80);
    setState(() {
      if (pickedFile != null) {
        _file = File(pickedFile.path);
      } else {
        return Text("Resim Seçiniz...");
      }
    });
  }
}
