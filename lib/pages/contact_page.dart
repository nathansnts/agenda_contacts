import 'dart:io';

import 'package:agenda_contatos/helpers/contact.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ContactPage extends StatefulWidget {
  final Contact? contact;

  const ContactPage({super.key, this.contact});

  @override
  State<ContactPage> createState() => _ContactPage();
}

Contact? _saveContact;
// ignore: unused_element
bool _userEditted = false;

TextEditingController _nameController = TextEditingController();
TextEditingController _emailController = TextEditingController();
TextEditingController _phoneController = TextEditingController();

void _resetFields() {
  _nameController.text = '';
  _emailController.text = '';
  _phoneController.text = '';
}

final nameFocus = FocusNode();

class _ContactPage extends State<ContactPage> {
  @override
  void initState() {
    if (widget.contact == null) {
      _saveContact = Contact();
    } else {
      _saveContact = Contact.fromMap(widget.contact!.toMap());
      _nameController.text = _saveContact?.name as String;
      _emailController.text = _saveContact?.email as String;
      _phoneController.text = _saveContact?.phone as String;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Cadastrar Novo Contato',
            style: TextStyle(
              fontFamily: 'relaway',
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 20,
              ),
              GestureDetector(
                child: Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: _saveContact?.img != null
                            ? FileImage(File(_saveContact?.img as String))
                            : AssetImage(_saveContact?.img as String)
                                as ImageProvider,
                        fit: BoxFit.cover),
                  ),
                ),
                onTap: () {
                  ImagePicker()
                      .pickImage(source: ImageSource.gallery)
                      .then((value) => {
                            if (value != null)
                              {
                                setState((() {
                                  print(_saveContact!.img = value.path);
                                }))
                              }
                          });
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _nameController,
                focusNode: nameFocus,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  hintText: 'Ex: Zezinho',
                  icon: Icon(Icons.person),
                ),
                onChanged: ((text) {
                  _userEditted = true;
                  _saveContact?.name = text;
                }),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Ex: Zezinho@email.com',
                  icon: Icon(Icons.email),
                ),
                onChanged: (text) {
                  _userEditted = true;
                  _saveContact?.email = text;
                },
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Telefone',
                  hintText: 'Ex: 999-999',
                  icon: Icon(Icons.phone),
                ),
                onChanged: (text) {
                  _userEditted = true;
                  _saveContact?.phone = text;
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => {
            if (_saveContact?.name != null &&
                _saveContact?.email != null &&
                _saveContact?.phone != null)
              {
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text(
                      'Desejar salvar o contato?',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context, _saveContact);
                          _resetFields();
                        },
                        child: const Text(
                          'Sim',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Não',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              }
            else
              {
                FocusScope.of(context).requestFocus(nameFocus),
              },
          },
          child: const Icon(
            Icons.save,
            size: 25,
          ),
        ),
      ),
    );
  }

  Future<bool> _requestPop() {
    if (_userEditted) {
      showDialog<String>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text(
            'Deseja descartar as alterações?',
            style: TextStyle(
              fontSize: 16,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                _resetFields();
              },
              child: const Text(
                'Sim',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Não',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      );
      return Future.value(false);
    } else {
      _resetFields();
      return Future.value(true);
    }
  }
}
