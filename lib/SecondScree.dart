import 'package:flutter/material.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DisplayNumbersPage extends StatelessWidget {
  final Database database;
  final String phoneNumber;

  DisplayNumbersPage(this.database, this.phoneNumber);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Numbers'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Phone Number:',
              style: TextStyle(fontSize: 20.0),
            ),
            Text(
              phoneNumber,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
