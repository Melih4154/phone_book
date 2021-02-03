import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:phone_book/database/db_helper/db_helper.dart';
import 'package:phone_book/model/contact.dart';
import 'package:phone_book/screens/home_page.dart';

class ContactAdd extends StatefulWidget {
  final Contact contact;

  const ContactAdd({Key key, this.contact}) : super(key: key);
  @override
  _ContactAddState createState() => _ContactAddState();
}

class _ContactAddState extends State<ContactAdd> {
  FocusNode focusNode;
  File _file;
  final picker = ImagePicker();
  DbHelper _dbHelper = DbHelper();
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String _name;
  String _phoneNumber;

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.contact.id == null ? "Person Add" : "Person Update"),
        actions: [
          IconButton(
            iconSize: 30,
            icon: Icon(
              Icons.send_outlined,
              color: Colors.white,
            ),
            onPressed: () => _save(),
          ),
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
                    image: widget.contact.id == null
                        ? (_file == null
                            ? AssetImage("assets/person.png")
                            : FileImage(_file))
                        : (widget.contact.avatar == ""
                            ? (_file == null
                                ? AssetImage("assets/person.png")
                                : FileImage(_file))
                            : (_file == null
                                ? AssetImage(widget.contact.avatar)
                                : FileImage(_file))),
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
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  initialValue: widget.contact.name,
                  onFieldSubmitted: (_) => focusNode.requestFocus(),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "Person Name",
                    contentPadding: EdgeInsets.only(left: 10),
                  ),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "İsim boş bırakılamaz!";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _name = value;
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                TextFormField(
                  initialValue: widget.contact.phoneNumber,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                      hintText: "Person Number",
                      contentPadding: EdgeInsets.only(left: 10)),
                  validator: (value) {
                    if (value.isEmpty) {
                      return "Numara boş bırakılamaz!";
                    }
                    return null;
                  },
                  onSaved: (value) {
                    setState(() {
                      _phoneNumber = value;
                    });
                  },
                ),
              ],
            ),
          )
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

  Future<void> _save() async {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      var contact = Contact.id(
          id: widget.contact.id,
          name: _name,
          phoneNumber: _phoneNumber,
          avatar: widget.contact.avatar == null
              ? (_file != null ? _file.path : "")
              : (_file == null ? widget.contact.avatar : _file.path));
      if (widget.contact.id != null) {
        await _dbHelper.contactUpdate(contact);
      } else {
        await _dbHelper.contactAdd(contact);
      }

      final _snackBar = _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text(widget.contact.id == null
              ? "${contact.name} Added..."
              : "${contact.name} Updated...")));

      _snackBar.closed.then((value) => Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage())));
    }
  }
}
