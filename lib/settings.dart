import "package:flutter/material.dart";
import "package:provider/provider.dart";

import 'userInfo.dart';
import 'mongo_db.dart';
import 'dialogTitle.dart';

// class SettingsWidget extends StatefulWidget {
//   const SettingsWidget({super.key});

//   @override
//   State<StatefulWidget> createState() => _SettingsWidgetState();
// }

// Move to hamburger menu
// class _SettingsWidgetState extends State<SettingsWidget> {
//   @override
//   Widget build(BuildContext context) {
//     // Make it so if user is already logged in, Account will show up. Otherwise,
//     // register will show up.
//     return SafeArea(
//       child: Consumer<UserInfo>(
//         builder: (context, value, constraints) => ListView.builder(
//           itemCount: value.settings.length,
//           itemBuilder: (context, index) {
//             return ListTile(
//               title: LayoutBuilder(
//                 builder: (context, constraints) => GestureDetector(
//                   child: Text(
//                     value.settings[index],
//                     style: const TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onTap: () { 
//                     if (value.settings[index] != "Register") {
//                       Navigator.push(
//                         context, 
//                         MaterialPageRoute(
//                           builder: (context) => SettingPages(title: value.settings[index], index: index),
//                         ),
//                       );
//                     }
//                     else {
//                       showDialog(
//                         context: context,
//                         builder: (context) => RegisterDialog()
//                       );
//                     }
//                   }
//                 )
//               ),
//             );
//           },
//         ),
//       )
//     );
//   }
// }

class SettingPages extends StatelessWidget {
  const SettingPages({super.key, required this.title, required this.index});
  final String title;
  final int index;
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        // Figure out settings to display for each setting category
        // Dependent on title
        body: const [GeneralSettings(), AccountSettings()][index],
      ),
    );
  }
}

class GeneralSettings extends StatelessWidget {
  const GeneralSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 1,
      itemBuilder: (context, index) {
        return const Text("This is a placeholder, because I don't know what to put");
      }
    );
  }
}

class AccountItems {
  late String _itemName;
  late IconData _icon;

  AccountItems({required String name, required IconData icon}) {
    _itemName = name;
    _icon = icon;
  } 

  String get itemName => _itemName;
  IconData get icon => _icon; 
}

// Will have a logout ListTile. When pressed, a dialog will ask if they are sure. 
// UserInfo.isLoggedIn will then be set to false and changeNotifer is applied.
class AccountSettings extends StatelessWidget {
  const AccountSettings({super.key});

  @override
  Widget build(BuildContext context) {
    List<AccountItems> _items = [
      AccountItems(name: "Change Username", icon: Icons.notes),
      AccountItems(name: "Logout", icon: Icons.logout),
    ];

    return ListView.builder(
      itemCount: _items.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          child: ListTile(
            title: Text(_items[index].itemName),
            leading: Icon(_items[index].icon),
          ),
          onTap: () {
            switch(_items[index].itemName) {
              case "Change Username":
                 showDialog(
                  context: context,
                  builder: (context) => const ChangeUserNameDialog(),
                );
                break;
              case "Logout":
                showDialog(
                  context: context,
                  builder: (context) => const LogOutDialog(),
                );
                break;
            }
          }
        );
      }
    );
  }
}

class ChangeUserNameDialog extends StatefulWidget {
  const ChangeUserNameDialog({super.key});

  @override
  State<StatefulWidget> createState() => _ChangeUserNameDialogState();
}

class _ChangeUserNameDialogState extends State<ChangeUserNameDialog> {

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    String? _newUsername;
    return SimpleDialog(
      title: const DialogTitle(title: "Change Username"),
      titlePadding: const EdgeInsets.all(0),
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "New Username",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      )
                    ),
                    TextFormField(
                      autocorrect: false,
                      obscureText: false,
                    // Need to check whether username already exist in database
                      validator: (value) {
                        var re = RegExp(r'^[0-9A-Za-z@#_]*$');
                        if (value == null || value.isEmpty) {
                          return "Please enter a valid username";
                        }
                        else if (!re.hasMatch(value)) {
                          return "Avoid special characters (@#_ allowed)";
                        }
                        else if (value == Provider.of<UserInfo>(context, listen: false).username) {
                          return "Do not use your existing username";
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _newUsername = value;
                      },
                    ),
                  ]
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: ElevatedButton(
                    onPressed: () {
                      final state = _formKey.currentState;
                      if (state!.validate()) {
                        setState(() {
                          state.save();
                        });
                        showDialog(
                          context: context, 
                          builder: (context) => IdentifyUserDialog(newUsername: _newUsername,),
                        );
                      }
                    },
                    child: const Text("Submit"),
                  )
                )
              ],
            ),
          ),
        ),
      ]
    );
  }
}

class IdentifyUserDialog extends StatelessWidget {
  IdentifyUserDialog({super.key, required this.newUsername});
  final newUsername;
  late String _email;
  late String _pass;
  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const DialogTitle(title: "Change Username"),
      titlePadding: const EdgeInsets.all(0),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                  child: Text(
                    "Enter your email and password to vertify your identity",
                    style: TextStyle(
                      fontSize: 14,
                    )
                  )
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        )
                      ),
                      TextFormField(
                        autocorrect: false,
                        obscureText: false,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            _email = value;
                            return null; 
                          }
                          return "Email field is empty";
                        },
                      ),
                    ],
                  )
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      )
                    ),
                    TextFormField(
                      autocorrect: false,
                      obscureText: true,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                            _pass = value;
                            return null; 
                          }
                          return "Password field is empty";
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final state = _formKey.currentState;
                      if (state!.validate()) {
                        bool userNameAvailable = await Provider.of<MongoDB>(context, listen: false).userNameAvailable(newUsername);
                        Provider.of<MongoDB>(context, listen: false).logIn(_email, _pass).then((value) async {
                          print(userNameAvailable);
                          print(value?["username"]);
                          print(Provider.of<UserInfo>(context, listen: false).username);
                          if (value != null && userNameAvailable && value["username"] == Provider.of<UserInfo>(context, listen: false).username) {
                            Provider.of<MongoDB>(context, listen: false).changeUsername(_email, newUsername).then((value) {
                              if (value && userNameAvailable) {
                                Provider.of<UserInfo>(context, listen: false).username = newUsername;
                                Navigator.of(context).pop();
                                if (DrawerController.of(context).isDrawerOpen) {
                                  Navigator.of(context).pop();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                              "Username Changed!",
                                              style: TextStyle(
                                                color: Colors.white,
                                              )),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                              else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                              "An Error has Occurred. Please try again later.",
                                              style: TextStyle(
                                                color: Colors.white,
                                              )),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            });
                          }
                          else {
                            Navigator.of(context).pop();
                            if (DrawerController.of(context).isDrawerOpen) {
                              Navigator.of(context).pop();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                          "Incorrect Information",
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        });
                      }
                    },
                    child: const Text("Submit"),
                  )
                )
              ],
            ),
          )
        ),
      ]
    );
  }
}

class LogOutDialog extends StatelessWidget {
  const LogOutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const DialogTitle(title: "Log Out"),
      titlePadding: const EdgeInsets.all(0),
      alignment: Alignment.center,
      content: const Text(
        "Are you sure you want to log out?",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () {
            Provider.of<UserInfo>(context, listen: false).logOut();
            Navigator.of(context).pop(); // Pop out of Dialog
            Navigator.of(context).pop(); // Pop out of Account Settings
            Navigator.of(context).pop();
          },
          child: const Text("Log Out"),
        )
      ]
    );
  }
}

// Need to decide on how to implement a log in option. (Button for dialog in register or separate tile)
class RegisterDialog extends StatefulWidget {
  const RegisterDialog({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterDialogState();
}

class _RegisterDialogState extends State<RegisterDialog> {
  String? _email;
  String? _user;
  String? _pass;

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      titlePadding: const EdgeInsets.all(0),
      title: const DialogTitle(title: "Register"),
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                  child: Column( 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        )
                      ),
                      TextFormField(
                        autocorrect: false,
                        obscureText: false,
                        // Need to check whether email already exist in database
                        validator: (value) {
                          var re = RegExp(r'^.+@.+$');
                          if (value == null || value.isEmpty) {
                            return 'No email provided.';
                          }
                          else if (!re.hasMatch(value)) {
                            return 'Please provide a valid email.';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _email = value;
                        }
                      )
                    ]
                  )
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 20.0),
                  child: Column( 
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Username',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        )
                      ),
                      TextFormField(
                        autocorrect: false,
                        obscureText: false,
                        // Need to check whether username already exist in database
                        validator: (value) {
                          var re = RegExp(r'^[0-9A-Za-z@#_]*$');
                          if (value == null || value.isEmpty) {
                            return "Please enter a valid username";
                          }
                          else if (!re.hasMatch(value)) {
                            return "Avoid special characters (@#_ allowed)";
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _user = value;
                        }
                      ),
                    ],
                  ),
                ),
                Column( 
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      )
                    ),
                    TextFormField(
                      autocorrect: false,
                      obscureText: true, 
                      validator: (value) {
                        var reg = RegExp(r'[_\-\!\@\*\$\?\&\%]');
                        if (value == null || value.isEmpty || value.length < 5) {
                          return 'Password is too short. (5+ characters)';
                        }
                        else if (reg.hasMatch(value)) {
                          return 'No Special characters: _, -, !, @, *, ?, &, %';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _pass = value;
                      }
                    )
                  ]
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final state = _formKey.currentState;
                      if (state!.validate()) {
                        setState(() {
                          state.save();
                        });
                        bool? success = await Provider.of<UserInfo>(context, listen: false).registerData(_email, _user, _pass, context);
                        print(success);
                        if (success == true) {
                          Navigator.of(context).pop();
                          if (DrawerController.of(context).isDrawerOpen) {
                              Navigator.of(context).pop();
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                        "Account Created!",
                                        style: TextStyle(
                                          color: Colors.white,
                                        )),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                        else if (success == false) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                "Email/Username already exist",
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 24,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              actions: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text("Dismiss"),
                                )
                              ]
                            ),
                          );
                        }
                        else {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "An Error has Occurred. Please try again later.",
                                style: TextStyle(
                                  color: Colors.red,
                                )),
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Submit!"),
                  )
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      showDialog(
                        context: context, 
                        builder: (context) => LogInDialog(),
                      );
                    },
                    child: const Text(
                      "Log in",
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              ]
            )
          )
        )
      ],
    );
  }
}

class LogInDialog extends StatelessWidget {
  LogInDialog({super.key});
  late String _email;
  late String _password;

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const DialogTitle(title: "Log In"),
      titlePadding: EdgeInsets.all(0),
      children: [
        Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Email",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      )
                    ),
                    TextFormField(
                      autocorrect: false,
                      obscureText: false,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          _email = value;
                          return null;
                        }
                        return "Email field is empty";
                      }
                    ),
                  ]
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Password",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        )
                      ),
                      TextFormField(
                        autocorrect: false,
                        obscureText: true,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            _password = value;
                            return null;
                          }
                          return "Password field is empty";
                        },
                      ),
                    ]
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final state = _formKey.currentState;
                      if (state!.validate()) {
                        await Provider.of<UserInfo>(context, listen: false).logIn(_email, _password, context).then((value) {
                          if (value == true) {
                            Navigator.of(context).pop();
                            if (DrawerController.of(context).isDrawerOpen) {
                              Navigator.of(context).pop();
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                          "Login Successful",
                                          style: TextStyle(
                                            color: Colors.white,
                                          )),
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                          else {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text(
                                  "Incorrect Information",
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 24,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Dismiss"),
                                  )
                                ]
                              ),
                            );
                          }
                        });
                      }
                    },
                    child: const Text("Submit!"),
                  )
                ),        
              ]
            )
          ),
        ),
      ]
    );
  }  
}