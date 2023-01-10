import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

//Definição da tabela e colunas no banco de dados
const String contactTable = 'contactTable';
const String id = 'idColumn';
const String name = 'nameColumn';
const String email = 'emailColumn';
const String phone = 'phoneColumn';
const String img = 'imgColumn';

//Criação do banco de dados e excução de funções sql
class ContactHelp {
  static final ContactHelp _instance = ContactHelp.internal();

  factory ContactHelp() => _instance;

  ContactHelp.internal();

  Database? _db;

  Future<Database?> get db async {
    Future<Database> initDb() async {
      final databasesPath = await getDatabasesPath();
      final path = join(databasesPath, 'contactsnew.db');

      return await openDatabase(
        path,
        version: 2,
        onCreate: (Database db, int newerVersion) async {
          await db.execute(
            'CREATE TABLE $contactTable ($id INTEGER PRIMARY KEY, $name TEXT, $email TEXT, $phone TEXT, $img TEXT)',
          );
        },
      );
    }

    if (_db != null) {
      return _db;
    } else {
      _db = await initDb();
      return _db;
    }
  }

  //Salvando um contato
  Future<Contact> saveContact(Contact contact) async {
    Database? dbContact = await db;
    contact.id = await dbContact!.insert(contactTable, contact.toMap());
    return contact;
  }

  //Consultando um contato
  Future<Contact?> getContact(int id) async {
    Database? dbContact = await db;
    List<Map> maps = await dbContact!.query(
      contactTable,
      columns: ['$id', name, email, phone, img],
      where: '$id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Contact.fromMap(maps.first);
    } else {
      return null;
    }
  }

  //Deletando um contato
  Future<int?> deleteContact(int id) async {
    Database? dbContact = await db;
    return await dbContact
        ?.delete(contactTable, where: 'idColumn = ?', whereArgs: [id]);
  }

  //Atualizando um contato
  Future<int> updateContact(Contact contact) async {
    Database? dbContact = await db;
    return await dbContact!.update(contactTable, contact.toMap(),
        where: '$id = ?', whereArgs: [contact.id]);
  }

  //Obtendo a lista de contatos
  Future<List> getAllContacts() async {
    Database? dbContact = await db;
    List list = await dbContact!.rawQuery('SELECT * FROM $contactTable');
    List<Contact> listContact = [];
    for (Map m in list) {
      listContact.add(Contact.fromMap(m));
    }
    return listContact;
  }

  //Obtendo a quantidade total de números cadastrados
  Future<int?> getNumber() async {
    Database? dbContact = await db;
    return Sqflite.firstIntValue(
        await dbContact!.rawQuery('SELECT COUNT(*) FROM $contactTable'));
  }

  //Encerra conexão com o banco de dados
  Future closeDataBase() async {
    Database? db;
    return await db?.close();
  }
}

//Criando a classe de contatos
class Contact {
  int? id;
  String? name;
  String? email;
  String? phone;
  String? img;

  Contact();

  //Construtor para poder pegar os dados do mapa
  Contact.fromMap(Map map) {
    id = map['idColumn'];
    name = map['nameColumn'];
    email = map['emailColumn'];
    phone = map['phoneColumn'];
    img = map['imgColumn'];
  }

  //Transformando os dados do contato em um mapa
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      'idColumn': id,
      'nameColumn': name,
      'emailColumn': email,
      'phoneColumn': phone,
      'imgColumn': img
    };

    if (id != null) {
      map['idColumn'] = id;
    }

    return map;
  }

  @override
  String toString() {
    return 'Contact(id: $id, name: $name, email: $email, phone: $phone, img: $img)';
  }
}
