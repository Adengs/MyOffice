import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:myoffice/page/background/bg_absen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class Absen extends StatefulWidget {
  // final User? user;
  const Absen({super.key});

  @override
  State<Absen> createState() => _AbsenState();
}

class _AbsenState extends State<Absen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController alasanCtl = TextEditingController();
  // final FirebaseAuth auth = FirebaseAuth.instance;
  // late Stream<User?> _authChange = auth.authStateChanges();
  // final User? user = FirebaseAuth.instance.currentUser;
  final User? user = FirebaseAuth.instance.currentUser;
  String? check, doubleToString;
  String? status, lat, long, currentLat, currentLong;
  String adress = "Tunggu Sebentar.......";
  int? meter;

  User? user2;
  Future<void> getUserData() async {
    User? userData = await FirebaseAuth.instance.currentUser;
    setState(() {
      user2 = userData;
      print(userData?.uid);
      print(userData?.displayName);
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   getUserData();
  // }

  Position? currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;

  String currentAdress = "";

  Future<Position> getCurrentLocation() async {
    servicePermission = await Geolocator.isLocationServiceEnabled();
    if (!servicePermission) {
      print('Service disable');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return await Geolocator.getCurrentPosition();
  }

  Future<void> getLocation() async {
    currentLocation = await getCurrentLocation();
    print("LATLONG $currentLocation");
    currentLat = currentLocation!.latitude.toString();
    currentLong = currentLocation!.longitude.toString();
    await getAdress();
    await cekAktif();
    await hitungJarak();
  }

  Future<void> getAdress() async {
    try {
      List<Placemark> placemark = await placemarkFromCoordinates(
          currentLocation!.latitude, currentLocation!.longitude);
      Placemark place = placemark[0];

      currentAdress =
          "${place.street}, ${place.name}, ${place.locality}, ${place.subAdministrativeArea}, ${place.administrativeArea}, ${place.postalCode}, ${place.country}";
      //, ${place.isoCountryCode}, ${place.subLocality}, ${place.subThoroughfare}, ${place.thoroughfare}
      print("$currentAdress");
      setState(() {
        adress = currentAdress;
        // currentLat = currentLocation!.latitude.toString();
        // currentLong = currentLocation!.longitude.toString();
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    getUserData();
    // cekAktif();
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

        // prefs.setString('latitude', lat!);
        // prefs.setString('longitude', long!);
        // hitungJarak();
      });
    }
  }

  Future<void> hitungJarak() async {
    var _distanceInMeters = await Geolocator.distanceBetween(
      double.parse(lat!),
      double.parse(long!),
      currentLocation!.latitude,
      currentLocation!.longitude,
    );

    setState(() {
      print('hitung ${_distanceInMeters}');
      print('meter ${_distanceInMeters.toStringAsFixed(0)}');

      doubleToString = _distanceInMeters.toStringAsFixed(0);
      meter = int.parse(doubleToString!);

      print('conString ${doubleToString} meter ${meter}');
      // print('lat 1 ${lat}');
      // print('long 1 ${long}');
      // print('lat 2 ${currentLat}');
      // print('long 2 ${currentLong}');
    });
  }

  Future<void> showDialogJarakLebih() async {
    DateTime now = DateTime.now();
    String formatTime = DateFormat('kk:mm').format(now);
    String formatDate = DateFormat('dd-MM-yyyy', 'id').format(now);
    String formatDay = DateFormat('EEE', 'id').format(now);
    String formatMonth = DateFormat('MM', 'id').format(now);
    try {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Konfirmasi Absen'),
              content: const Text(
                  'Anda sedang berada diluar kantor, absen menunggu persetujuan atasan'),
              actions: [
                Container(
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // padding: const EdgeInsets.only(top: 0, bottom: 8),
                        child: const Text(
                          'Alasan Izin',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Container(
                        padding: const EdgeInsets.fromLTRB(10, 1, 10, 1),
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                        ),
                        child: Theme(
                          data: ThemeData().copyWith(
                            colorScheme: ThemeData()
                                .colorScheme
                                .copyWith(primary: const Color(0xFF5C8374)),
                          ),
                          child: TextFormField(
                            controller: alasanCtl,
                            minLines: 1, // any number you need (It works as the rows for the textarea)
                            keyboardType: TextInputType.multiline,
                            maxLines: 1,
                            cursorColor: const Color(0xFF5C8374),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // TextButton(
                //     onPressed: () {
                //       Navigator.of(context)
                //           .pop();
                //     },
                //     child: const Text('Tidak')),
                TextButton(
                    onPressed: () async {
                      if (alasanCtl.text.isEmpty) {
                        showToast("Silahkan Isi Alasan",
                            gravity: Toast.bottom, duration: Toast.lengthLong);
                      } else {
                        await firestore.collection('database').add(
                          {
                            'db': 'ABSEN',
                            'status': 'Hadir',
                            'jam': formatTime,
                            'nama': user!.displayName!.toString(),
                            'tanggal': formatDate,
                            'hari': formatDay,
                            'bulan': formatMonth,
                            'alasan': alasanCtl.text,
                            'status_izin': 'Diproses',
                            'approve': false,
                          },
                        );

                        SharedPreferences prefs = await SharedPreferences.getInstance();

                        prefs.setString('${user2}', formatDate);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Ok')),
              ],
            );
          });

      // prefs.setString('absen', formatDate);
      Navigator.of(context).pop();
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> showDialogAbsen() async {
    DateTime now = DateTime.now();
    String formatTime = DateFormat('kk:mm').format(now);
    String formatDate = DateFormat('dd-MM-yyyy', 'id').format(now);
    String formatDay = DateFormat('EEE', 'id').format(now);
    try {
      await firestore.collection('database').add(
        {
          'db': 'ABSEN',
          'status': 'Hadir',
          'jam': formatTime,
          'nama': user!.displayName!.toString(),
          'tanggal': formatDate,
          'hari': formatDay,
          'approve': true,
        },
      );

      // prefs.setString('absen', formatDate);
      Navigator.of(context).pop();
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    DateTime now = DateTime.now();
    String formatTime = DateFormat('kk:mm').format(now);
    String formatDate = DateFormat('dd-MM-yyyy', 'id').format(now);
    String formatDay = DateFormat('EEE', 'id').format(now);

    return BgAbsen(
      child: Column(
        children: [
          Row(children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 10.0),
                child: Image.asset("assets/images/ic_back.png",
                    height: 45, width: 45),
              ),
            ),
          ]),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(25.0, 10.0, 25.0, 25.0),
                  margin: const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35.0),
                        topRight: Radius.circular(35.0)),
                  ),
                  child: Column(children: [
                    Container(
                      width: 60,
                      height: 4,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        color: Colors.black12,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 25.0),
                      child: const Text(
                        'Absen',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF5C8374),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 25.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const ImageIcon(
                            AssetImage("assets/images/ic_map.png"),
                            color: Colors.black26,
                          ),
                          const SizedBox(width: 5),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Lokasi Anda',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Text(
                                  '${adress}',
                                  overflow: TextOverflow.visible,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.075,
                      child: ElevatedButton(
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            check = prefs.getString('${user2}');
                            if (check == formatDate) {
                              showToast(
                                  "Absen hanya bisa dilakukan sekali sehari",
                                  gravity: Toast.bottom,
                                  duration: Toast.lengthLong);
                            } else {
                              if (meter != null) {
                                if (meter! > 100) {
                                  print('MASOOOKKKK');
                                  showDialogJarakLebih();
                                } else {
                                  showDialogAbsen();
                                  prefs.setString('${user2}', formatDate);
                                }
                              }
                            }
                            setState(() {
                              FocusScope.of(context).unfocus();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                side:
                                    const BorderSide(color: Color(0xFF5C8374))),
                            backgroundColor: const Color(0xFF5C8374),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          child: const Text(
                            'Absen',
                          )),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }
}
