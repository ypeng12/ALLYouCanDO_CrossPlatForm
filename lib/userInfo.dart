import "package:flutter/material.dart";
import 'package:flutter_keychain/flutter_keychain.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'mongo_db.dart';

/*
  DB Schemas:
  - User Schema: 
    - UID_user : String (Primary Key)
    - Email : String
    - Username : String
    - Password : String (some type of Encryption)
    - Profile : PostgreSQL Image datatype
    - Preferences : JSON (Preferences is a stretch goal)

  - Task Schema:
    - UID_request : String (Primary Key)
    - Requester : String (Foreign Key of User Schema UID_user)
    - Task : Unique Type (Might create own type or String) Domain: [Technical, Labor, Delivery, Other]
    - Price : Float
    - Time : DateTime
    - Location : String
    - Status : Unique Type (Might create own type or String) Domain: [Available, In-Progress, Completed]
    - Supplier : String (Foreign Key of User Schema UID_user)
*/

const uuidReal = Uuid();
// Used to immediately get user information at launch from database (database not implemented yet)
class UserInfo extends ChangeNotifier {
  bool _isLoggedIn = false;
  late String? _username = null; 
  late String? _uuid = null;
  late List<String> _settings;

  UserInfo() {
    init();
  }

  // TODO: Create FlutterKeychain for profile image (stored in DB)
  void init() async {
    await FlutterKeychain.get(key: "loggedIn").then((value) async {
      if (value == null || value == "false") {
        _isLoggedIn = false;
      }
      else {
        _isLoggedIn = true; // Change this back to true, set to false for development purposes
        await FlutterKeychain.get(key: "username").then((value) {
          _username = value;
        });
        await FlutterKeychain.get(key: "UID_user").then((value) {
          _uuid = value;
        });
      }
    });
    _settings = _isLoggedIn ? ["General", "Account"] : ["General", "Register"];
    notifyListeners();
  }

  List<String> get settings => _settings;
  String? get username => _username;

  set username(newUsername) {
    _username = newUsername;
    FlutterKeychain.put(key: "username", value: newUsername);
    notifyListeners();
  }

  Future<bool?> registerData(String? email, String? username, String? password, BuildContext context) async {
    // password may not be necessary for preferences, however, will be needed for database
    if (email != null && username != null && password != null) {
      bool? exist = await Provider.of<MongoDB>(context, listen: false).userExist(email, username);
      if (exist == false) {
        String uid = uuidReal.v4();
        print(uid);
        Provider.of<MongoDB>(context, listen: false).newUser(uid, email, username, password);
        _isLoggedIn = true;
        _settings = _isLoggedIn ? ["General", "Account"] : ["General", "Register"];

        await FlutterKeychain.put(key: "loggedIn", value: "true");
        await FlutterKeychain.put(key: "username", value: username);
        await FlutterKeychain.put(key: "UID_user", value: uid);
        _username = username;
        _uuid = uid;
        notifyListeners();
        return true;
      }
      else if (exist == true) {
        return false;
      }
    }
    return null;
  }

  Future<bool> logIn(String email, String password, BuildContext context) async {
    Map<String,dynamic>? userInfo = await Provider.of<MongoDB>(context, listen: false).logIn(email, password);
    if (userInfo != null) {
      await FlutterKeychain.put(key: "loggedIn", value: "true");
      _isLoggedIn = true;
      _settings = _isLoggedIn ? ["General", "Account"] : ["General", "Register"];
      await FlutterKeychain.put(key: "username", value: userInfo["username"]);
      _username = userInfo["username"];
      await FlutterKeychain.put(key: "UID_user", value: userInfo["UID_user"]);
      _uuid = userInfo["UID_user"];

      notifyListeners();
      return true;
    }
    return false;
  }

  void logOut() {
    _isLoggedIn = false;
    _username = null;
    _uuid = null;
    _settings = _isLoggedIn ? ["General", "Account"] : ["General", "Register"];
    notifyListeners();
    FlutterKeychain.clear();
  }

  get uuid => _uuid;
}