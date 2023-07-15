import 'package:email_otp/email_otp.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:test_app/phone.dart';
import 'package:test_app/usermodel.dart';
import 'package:email_otp/email_otp.dart';

class MyEmail extends StatefulWidget {
  const MyEmail({super.key});
  static String verify = "";
  @override
  State<MyEmail> createState() => _MyEmailState();
}

class _MyEmailState extends State<MyEmail> {
  final TextEditingController emailController= TextEditingController();
  final TextEditingController OTPController= TextEditingController();
  EmailOTP myauth= EmailOTP();
  var OTP="";
  var email = "";
  @override
  User? user=FirebaseAuth.instance.currentUser;
  UserModel loggedInUser=UserModel();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      this.loggedInUser = UserModel.fromMap(value.data());
      emailController.text="${loggedInUser.email}";
      email="${loggedInUser.email}";
      setState(() {});
    });
  }
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        margin: EdgeInsets.only(left: 25,right: 25),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/emailverify.png',width: 250,height: 250,),
              SizedBox(height: 25,),
              Text(
                'Email Verification',
                style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30,),
              Container(
                height: 55,
                decoration: BoxDecoration(
                  border: Border.all(width: 1,color: Colors.grey),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value){
                          email=value;
                        },
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail),
                          suffixIcon: TextButton(
                            child: Text("Send OTP"),
                            onPressed: () async{
                              myauth.setConfig(
                                appEmail: "devaravikishore@gmail.com",
                                appName: "Brain Hemorrhage Classifier",
                                userEmail: emailController.text,
                                otpLength: 4,
                                otpType: OTPType.digitsOnly);
                              if(await myauth.sendOTP()==true)
                              {
                                  Fluttertoast.showToast(msg: "OTP sent to Email");
                            }else {
                                Fluttertoast.showToast(msg: "OTP send Failed");
                              }
                            },
                          ),
                          border: InputBorder.none, hintText: "Email"
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(height: 25,),
              Text(
                'Enter Verification',
                style: TextStyle(fontSize: 22,fontWeight: FontWeight.bold),
              ),
              Pinput(
                length: 4,
                showCursor: true,
                onChanged: (value) {
                  OTP = value;
                },
              ),
              /*Container(
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(width: 1,color: Colors.grey),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: OTPController,
                        keyboardType: TextInputType.number,
                        onChanged: (value){
                          OTP=value;
                        },
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.vpn_key),
                            border: InputBorder.none, hintText: "Enter OTP"
                        ),
                      ),
                    )
                  ],
                ),
              ),*/
              SizedBox(height: 25,),
              SizedBox(
                height: 45,
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if(await myauth.verifyOTP(otp:OTP)==true)
                      {
                        Fluttertoast.showToast(msg: "OTP Verified");
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyPhone()),
                        );
                      }else
                        {
                          Fluttertoast.showToast(msg: "Invalid OTP");
                        }
                  },
                  child: Text("Verify OTP"),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    )
                  ),
                ),
              )
            ],
          ),
        ),
      ),


    );
  }
}
