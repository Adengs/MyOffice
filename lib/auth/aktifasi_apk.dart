import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:myoffice/auth/wrapper.dart';
import 'package:myoffice/page/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class Aktivasi extends StatefulWidget {
  const Aktivasi({super.key});

  @override
  State<Aktivasi> createState() => _AktivasiState();
}

class _AktivasiState extends State<Aktivasi> {

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String? status, lat, long;

  @override
  void initState() {
    super.initState();
    cekAktif();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    if(status == '1'){
      return const Wrapper();
    }else if(status == '0'){
      return const Scaffold(
        body: Center(child: Text('Silahkan hubungin devloper untuk aktivasi aplikasi')),
      );
    } else {
      return const LoginPage();
    }
  }

  Future<void> cekAktif() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var collection = firestore.collection('database');
    var docSnapshot = await collection.doc('Y3dy1BhAjWyNNIyFWg0O').get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var db_status = data?['status_app'];
      var db_latitude = data?['latitude'];
      var db_longitude = data?['longitude'];

      setState(() {
        status = db_status.toString();
        lat = db_latitude.toString();
        long = db_longitude.toString();

        prefs.setString('latitude', lat!);
        prefs.setString('longitude', long!);
      });
    }
  }
}
