import 'dart:io';
import 'package:agenda_contatos/pages/contact_page.dart';
import 'package:agenda_contatos/helpers/contact.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelp help = ContactHelp();
  List<Contact> listContacts = [];

  @override
  void initState() {
    super.initState();

    Contact c = Contact();
    /*c.name = 'Nathan';
    c.email = 'nathan@email.com';
    c.phone = '95959595';
    */

    _getAllContacts();

    //print(help.saveContact(c));
  }

  Future<void> _abrirTelefone(String num) async {
    final Uri launchPhone = Uri(
      scheme: 'tel',
      path: num,
    );

    if (await canLaunchUrl(launchPhone)) {
      await launchUrl(launchPhone);
    } else {
      throw 'Não é possível executar essa ação';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Agenda de Contatos',
          style: TextStyle(
            fontFamily: 'relaway',
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    Text(
                      'Ordenar',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 15),
                    ),
                    Icon(
                      Icons.abc_outlined,
                      size: 25,
                    ),
                  ],
                ),
                onTap: () {
                  setState(() {
                    listContacts.sort(((a, b) => a.name!.compareTo(b.name!)));
                  });
                },
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: listContacts.length,
        itemBuilder: ((context, index) => cardContacts(context, index)),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          _showContactPage(),
        },
        child: const Icon(
          Icons.add,
          size: 25,
        ),
      ),
    );
  }

  Widget cardContacts(BuildContext context, int index) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                    image: FileImage(File(listContacts[index].img!)),
                    fit: BoxFit.cover),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(listContacts[index].name!),
                Text(listContacts[index].email!),
                Text(listContacts[index].phone!),
              ],
            )
          ],
        ),
      ),
      onTap: () {
        //_showContactPage(contact: listContacts[index]);
        _showOptions(context, index);
      },
    );
  }

  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheet(
          onClosing: () {},
          builder: (context) {
            return Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      _abrirTelefone(listContacts[index].phone!);
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Ligar',
                      style: TextStyle(
                        fontFamily: 'relaway',
                        fontSize: 16,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showContactPage(contact: listContacts[index]);
                    },
                    child: const Text('Editar'),
                  ),
                  TextButton(
                    onPressed: () {
                      print(help.deleteContact(listContacts[index].id!));
                      setState(() {
                        print(help.getAllContacts());
                        listContacts.removeAt(index);
                        Navigator.pop(context);
                      });
                    },
                    child: const Text('Excluir'),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showContactPage({Contact? contact}) async {
    //Recebendo um contato da tela contact_page
    final recContacts = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContactPage(
          contact: contact ?? contact,
        ),
      ),
    );
    //Verifica se o contato enviado foi descartado ou não durante o processo de edição
    if (recContacts != null) {
      //Verifica se o contato retornado é novo ou não
      if (contact != null) {
        print(await help.updateContact(recContacts));
      } else {
        print(await help.saveContact(recContacts));
      }
      _getAllContacts();
    }
  }

  void _getAllContacts() {
    help.getAllContacts().then(
      (list) {
        setState(
          () {
            listContacts = list as List<Contact>;
          },
        );
      },
    );
  }
}
