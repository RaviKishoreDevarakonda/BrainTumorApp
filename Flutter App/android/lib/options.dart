import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OptionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
        title: Center(child: Text('Brain Hemorrhage Classifier', style: TextStyle(fontSize: 18))),
        backgroundColor: Colors.red.shade400,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushNamed(context, 'login');
              Fluttertoast.showToast(msg: "Logged Out Successfully");
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Choose Image/Video to Upload",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 50),
            Container(
              height: 100,
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red.shade400,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, 'home1');
                },
                child: Text('Pick Image'),
              ),
            ),
            SizedBox(height: 50),
            Container(
              height: 100,
              width: 200,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red.shade400,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, 'home2');
                },
                child: Text('Pick Video'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
