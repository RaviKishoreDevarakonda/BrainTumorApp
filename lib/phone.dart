import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:test_app/usermodel.dart';


class MyPhone extends StatefulWidget {
  const MyPhone({super.key});

  static String verify = "";
  @override
  State<MyPhone> createState() => _MyPhoneState();
}

class _MyPhoneState extends State<MyPhone> {
  @override
  TextEditingController countrycode = TextEditingController();
  TextEditingController phonenumber=TextEditingController();
  var phone = "";
  @override
  User? user=FirebaseAuth.instance.currentUser;
  UserModel loggedInUser=UserModel();
  @override
  void initState() {
    // TODO: implement initState
    countrycode.text = "+91";

      super.initState();
      FirebaseFirestore.instance
          .collection("users")
          .doc(user!.uid)
          .get()
          .then((value) {
        this.loggedInUser = UserModel.fromMap(value.data());
        phonenumber.text="${loggedInUser.phonenumber}";
        phone="${loggedInUser.phonenumber}";
        setState(() {});
      });
    }
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
            margin: EdgeInsets.only(left: 25, right: 25),
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/OTP_Image1.png', width: 250, height: 250),
                  SizedBox(height: 25),
                  Text(
                    'Phone Verification',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'We need to register your phone before getting started!',
                    style: TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Container(
                    height: 55,
                    decoration: BoxDecoration(
                        border: Border.all(width: 1, color: Colors.grey),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 40,
                          child: TextField(
                            controller: countrycode,
                            decoration:
                                InputDecoration(border: InputBorder.none),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text("|",
                            style: TextStyle(fontSize: 33, color: Colors.grey)),
                        SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: phonenumber,
                            keyboardType: TextInputType.phone,
                            onChanged: (value) {
                              phone = value;
                            },
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: "Phone Number"),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseAuth.instance.verifyPhoneNumber(
                            phoneNumber: '${countrycode.text + phone}',
                            verificationCompleted:
                                (PhoneAuthCredential credential) {},
                            verificationFailed: (FirebaseAuthException e) {},
                            codeSent:
                                (String verificationId, int? resendToken) {
                              MyPhone.verify = verificationId;
                              Navigator.pushNamed(context, "otp");
                            },
                            codeAutoRetrievalTimeout:
                                (String verificationId) {},
                          );

                          // Navigator.pushNamed(context, "otp");
                        },
                        child: Text('Send the Code'),
                        style: ElevatedButton.styleFrom(
                            primary: Colors.red.shade400,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10))),
                      ))
                ],
              ),
            )));
  }
}
