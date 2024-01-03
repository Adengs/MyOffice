import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myoffice/auth/auth_services.dart';
import 'package:myoffice/page/absen/absen.dart';
import 'package:myoffice/page/background/bg_home.dart';
import 'package:myoffice/page/pulang/pulang.dart';
import 'package:myoffice/page/rencana_izin/rencana_izin.dart';
import 'package:myoffice/page/laporan_kerja/laporan_kerja.dart';

import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeStaff extends StatefulWidget {
  final User? user;

  const HomeStaff(User firebaseUser, {super.key, this.user});

  @override
  State<HomeStaff> createState() => _HomeStaffState();
}

class _HomeStaffState extends State<HomeStaff> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String name = '';
  String textWib = '';
  User? user;

  Future<void> getUserData() async {
    User? userData = await FirebaseAuth.instance.currentUser;
    setState(() {
      user = userData;
      print(userData?.uid);
      print(userData?.displayName);
      if (userData!.displayName != null) {
        name = userData.displayName!;
      } else {
        name = '';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  Future<void> showDialogLogout() async {
    try {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Konfirmasi'),
              content: const Text(
                'Apakah anda yakin untuk keluar dari akun ini?',
                style: TextStyle(
                  color: Colors.black54,
                ),),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                    },
                    child: const Text('Tidak',
                      style: TextStyle(
                        color: Color(0xFF5C8374),
                      ),)),
                TextButton(
                    onPressed: () {
                      Navigator.of(context)
                          .pop();
                      AuthServices.signOut();
                    },
                    child: const Text('Ya',
                      style: TextStyle(
                        color: Color(0xFF5C8374),
                      ),)),
              ],
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE, d MMM y', 'id').format(now);

    return BgHome(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(15, 25, 15, 20),
            child: Row(children: <Widget>[
              ClipOval(
                child: Image.asset("assets/images/placeholder_image.png",
                    fit: BoxFit.cover, height: 44, width: 44),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('$name',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          )),
                      Container(
                        margin: EdgeInsets.only(top: 3),
                        child: const Text(
                          'Karyawan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Navigator.pop(context);
                  // AuthServices.signOut();
                  showDialogLogout();
                },
                child: const ImageIcon(
                  AssetImage("assets/images/ic_logout.png"),
                  color: Colors.white,
                ),
              )
            ]),
          ),
          Expanded(
            child: ListView(children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 10.0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(25.0),
                        topRight: Radius.circular(25.0))),
                // borderRadius: BorderRadius.all(Radius.circular(25.0))),
                child: Column(children: <Widget>[
                  const Text(
                    'Kehadiran Langsung',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  DigitalClock(
                    digitAnimationStyle: Curves.elasticOut,
                    is24HourTimeFormat: true,
                    // showSecondsDigit: false,
                    colon: const Text(
                      ':',
                      style: TextStyle(
                        color: Color(0xFF5C8374),
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                      ),
                    ),
                    hourMinuteDigitTextStyle: const TextStyle(
                      color: Color(0xFF5C8374),
                      fontWeight: FontWeight.w600,
                      fontSize: 40,
                    ),
                    // amPmDigitTextStyle: const TextStyle(
                    //   color: Color(0xFF5C8374),
                    //   fontWeight: FontWeight.bold,
                    //   fontSize: 20,
                    // ),
                  ),
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  const Divider(color: Colors.black26),
                  const SizedBox(height: 5),
                  const Text(
                    'Jam Kerja',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '08.00 - 17.00',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.065,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const Absen();
                              }));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  side: const BorderSide(
                                      color: Color(0xFF5C8374))),
                              backgroundColor: const Color(0xFF5C8374),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            child: const Text('Absen'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 25),
                      Expanded(
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height * 0.065,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const Pulang();
                              }));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  side: const BorderSide(
                                      color: Color(0xFF5C8374))),
                              backgroundColor: const Color(0xFF5C8374),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            child: const Text('Pulang'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
              Container(
                  margin: const EdgeInsets.only(left: 15, right: 15),
                  child: const Divider(color: Colors.black26)),
              const SizedBox(height: 5),
              SizedBox(
                width: double.infinity,
                child: Container(
                  margin: const EdgeInsets.only(left: 15.0, right: 15.0),
                  padding: const EdgeInsets.only(
                      left: 25.0, right: 25.0, top: 15.0, bottom: 25.0),
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0.0, 0.2), //(x,y)
                          blurRadius: 2.0,
                        )
                      ],
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(25.0),
                          bottomRight: Radius.circular(25.0))),
                  child: Column(children: <Widget>[
                    const Text(
                      'Rencana & Kegiatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.065,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const RencanaIzin();
                                }));
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF5C8374),
                                side: const BorderSide(
                                  width: 1.5,
                                  color: Color(0xFF5C8374),
                                  style: BorderStyle.solid,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                              ),
                              child: const Text(
                                'Rencana Izin',
                                style: TextStyle(
                                    color: Color(0xFF5C8374),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 25),
                        Expanded(
                          child: SizedBox(
                            height: MediaQuery.of(context).size.height * 0.065,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return const LaporanKerja();
                                }));
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF5C8374),
                                side: const BorderSide(
                                  width: 1.5,
                                  color: Color(0xFF5C8374),
                                  style: BorderStyle.solid,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(7.0)),
                              ),
                              child: const Text(
                                'Laporan Kerja',
                                style: TextStyle(
                                    color: Color(0xFF5C8374),
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
              Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 15.0),
                      child: Row(
                        children: const <Widget>[
                          ImageIcon(
                            AssetImage("assets/images/ic_history_att.png"),
                            color: Colors.black,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'Riwayat Kehadiran',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection('database')
                            .where('db', isEqualTo: 'ABSEN')
                            .where('nama', isEqualTo: '$name')
                            .where('approve', isEqualTo: true)
                            // .where('sort', isGreaterThan: 1)
                            // .orderBy('status')
                            .orderBy('tanggal', descending: true)
                            .limit(5)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data!.docs;
                            return ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return Container(
                                    margin: const EdgeInsets.fromLTRB(
                                        25.0, 5.0, 25.0, 0.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                '${(data[index].data() as Map<String, dynamic>)['hari']}, ${(data[index].data() as Map<String, dynamic>)['tanggal']}',
                                                style: const TextStyle(
                                                    fontSize: 14),
                                              ),
                                            ),
                                            if ((data[index].data() as Map<
                                                    String,
                                                    dynamic>)['status'] ==
                                                'Hadir') ...[
                                              Row(
                                                children: [
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.fromLTRB(
                                                            10.0, 0.0, 20.0, 0.0),
                                                    child: GestureDetector(
                                                        onTap: () {},
                                                        child: const Icon(
                                                          Icons.access_time_rounded,
                                                          size: 16,
                                                        )),
                                                  ),
                                                  Container(
                                                    margin:
                                                    const EdgeInsets.only(right: 5.0),
                                                    child: Text(
                                                      '${(data[index].data() as Map<String, dynamic>)['jam']}',
                                                      style:
                                                      const TextStyle(fontSize: 14),
                                                    ),
                                                  ),
                                                  const Text(
                                                    'WIB',
                                                    style: TextStyle(fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ] else ...[
                                              Row(
                                                children: [
                                                  // Container(
                                                  //   margin:
                                                  //       const EdgeInsets.fromLTRB(
                                                  //           10.0, 0.0, 20.0, 0.0),
                                                  //   child: GestureDetector(
                                                  //       onTap: () {},
                                                  //       child: const Icon(
                                                  //         Icons.access_time_rounded,
                                                  //         size: 16,
                                                  //         color: Colors.red,
                                                  //       )),
                                                  // ),
                                                  Container(
                                                    margin:
                                                    const EdgeInsets.only(right: 5.0),
                                                    child: Text(
                                                      '${(data[index].data() as Map<String, dynamic>)['status']}',
                                                      style:
                                                      const TextStyle(fontSize: 14, color: Colors.red),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                        // Text("List item $index"),
                                        const SizedBox(height: 5),
                                        const Divider(color: Colors.black26),
                                        // Text("${movieTitle[index].shortDescription}>"),
                                      ],
                                    ),
                                  );
                                });
                          }
                          if (snapshot.hasError) {
                            print('Error in Firestore query: ${snapshot.error}');
                            return const Text('Something went wrong');
                          }else {
                            return const Text('Loading . . .',
                                textAlign: TextAlign.center);
                          }
                        })
                  ],
                ),
              ),
            ]),
          )
        ],
      ),
    );
  }
}
