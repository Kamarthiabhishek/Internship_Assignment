import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'SecondScree.dart';

void main() async {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  WidgetsFlutterBinding.ensureInitialized();
  final databasePath = await getDatabasesPath();
  final database = await openDatabase(
    join(databasePath, 'numbers.db'),
    version: 1,
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE numbers(id INTEGER PRIMARY KEY, number INTEGER)',
      );
    },
  );
  runApp(MyApp(
    database: database,
  ));
}

class MyApp extends StatelessWidget {
  final Database database;
  const MyApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Internship_Assigment",
      home: HomePage(
        database: database,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Database database;
  const HomePage({super.key, required this.database});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _phoneNumberController = TextEditingController();
  bool isButtonEnabled = false;
  bool isInternetAvailable = true;
  String internetMessage = "";
  String phoneNumberMessage = "";

  @override
  void initState() {
    super.initState();
    _phoneNumberController.addListener(_checkInputLength);
    checkInternetConnectivity();
  }

  @override
  void dispose() {
    _phoneNumberController.removeListener(_checkInputLength);
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _checkInputLength() {
    setState(() {
      isButtonEnabled = _phoneNumberController.text.length == 10;
      phoneNumberMessage =
          isButtonEnabled ? "" : "Phone number should be 10 digits";
    });
  }

  Future<void> checkInternetConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    setState(() {
      isInternetAvailable = connectivityResult != ConnectivityResult.none;
      internetMessage =
          isInternetAvailable ? " " : "Check Internet COnnectivity";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 300,
          width: MediaQuery.of(context).size.width / 1.2,
          decoration: BoxDecoration(
              color: Colors.amber, borderRadius: BorderRadius.circular(15)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextFormField(
                  controller: _phoneNumberController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10)
                  ],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      hintText: "Enter number"),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              InkWell(
                onTap: isButtonEnabled && isInternetAvailable
                    ? () async {
                        _showConfirmationDialog(context);
                      }
                    : null,
                child: Container(
                  height: 55,
                  width: MediaQuery.of(context).size.width / 2,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: isButtonEnabled && isInternetAvailable
                          ? Colors.black
                          : Colors.amber.shade500),
                  child: Center(
                    child: Text(
                      "Submit",
                      style: TextStyle(
                          color: isButtonEnabled && isInternetAvailable
                              ? Colors.amber
                              : Colors.grey),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                phoneNumberMessage,
                style: TextStyle(color: Colors.red),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                internetMessage,
                style: TextStyle(color: Colors.red),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showConfirmationDialog(BuildContext context) async {
    final enteredPhoneNumber = _phoneNumberController.text;
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: Text(
              'Is the entered phone number correct?\n\nPhone Number: $enteredPhoneNumber'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () async {
                final number = int.tryParse(enteredPhoneNumber);
                if (number != null) {
                  await widget.database.insert(
                    'numbers',
                    {'number': number},
                    conflictAlgorithm: ConflictAlgorithm.replace,
                  );
                  _phoneNumberController.clear();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Number added to the database.'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter a valid number.'),
                    ),
                  );
                }
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        DisplayNumbersPage(widget.database, enteredPhoneNumber),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
