import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myoffice/page/home/home_admin/home_admin.dart';
import 'package:myoffice/page/home/home_staff.dart';
import 'package:myoffice/page/login/login.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    User? firebaseUser = Provider.of<User?>(context);
    // if (firebaseUser != null && firebaseUser.email == 'admin1@gmail.com') {
    //   return HomeAdmin(firebaseUser);
    // }
    // // else if (firebaseUser != null && firebaseUser.email == 'admin1@gmail.com') {
    // //   return HomeAdmin(firebaseUser);
    // // }
    // else {
    //   return HomeStaff(firebaseUser!);
    // }
    if (firebaseUser != null && firebaseUser.email == 'staff1@gmail.com') {
      return HomeStaff(firebaseUser);
    } else if (firebaseUser != null && firebaseUser.email == 'staff2@gmail.com') {
      return HomeStaff(firebaseUser);
    } else if (firebaseUser != null && firebaseUser.email == 'staff3@gmail.com') {
      return HomeStaff(firebaseUser);
    } else if (firebaseUser != null && firebaseUser.email == 'admin1@gmail.com') {
      return HomeAdmin(firebaseUser);
    }else {
      return const LoginPage();
    }
  }
}
