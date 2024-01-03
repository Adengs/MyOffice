import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myoffice/page/background/bg_form.dart';
import 'package:myoffice/page/rencana_izin/pengajuan_izin.dart';

class RencanaIzin extends StatefulWidget {
  const RencanaIzin({super.key});

  @override
  State<RencanaIzin> createState() => _RencanaIzinState();
}

class _RencanaIzinState extends State<RencanaIzin> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  String name = '';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 10.0),
                child: Row(
                    // mainAxisAlignment: MainAxisAlignment.center,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Image.asset("assets/images/ic_back.png",
                            height: 45, width: 45),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.70,
                        child: const Text(
                          'Rencana Izin',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ]),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.813,
                margin: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 15.0),
                padding: const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 15.0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 1.0), //(x,y)
                        blurRadius: 35.0,
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(25.0))),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                      child: Row(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          // mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            const Expanded(
                              child: Text('Rencana Izin/Absen',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  )),
                            ),
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.045,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return const PengajuanIzin();
                                  }));
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      side: const BorderSide(
                                          color: Color(0xFF5C8374))),
                                  backgroundColor: const Color(0xFF5C8374),
                                  textStyle: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500),
                                ),
                                child: const Text('Izin Sekarang'),
                              ),
                            ),
                          ]),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection("database")
                            .where('nama', isEqualTo: '$name')
                            .where("status_code", isEqualTo: "1")
                            // .where("sort", isLessThan: 40)
                            // .where("status", isEqualTo: "Sakit")
                            // .orderBy('status')
                            // .orderBy('status')
                            .orderBy("tanggal_mulai", descending: true)
                            .limit(5)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            var data = snapshot.data!.docs;
                            return Expanded(
                              child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: data.length,
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          0.0, 5.0, 0.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '${(data[index].data() as Map<String, dynamic>)['nama']}',
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                              ),
                                              if ((data[index].data() as Map<
                                                          String, dynamic>)[
                                                      'status_izin'] ==
                                                  'Diproses') ...[
                                                Row(
                                                  children: [
                                                    Container(
                                                      margin:
                                                          const EdgeInsets.only(
                                                              right: 5.0),
                                                      child: Text(
                                                        '${(data[index].data() as Map<String, dynamic>)['status_izin']}',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Colors
                                                                .orange),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ] else if ((data[index].data() as Map<
                                                  String, dynamic>)[
                                              'status_izin'] ==
                                                  'Disetujui') ...[
                                                Row(
                                                  children: [
                                                    Container(
                                                      margin:
                                                      const EdgeInsets.only(
                                                          right: 5.0),
                                                      child: Text(
                                                        '${(data[index].data() as Map<String, dynamic>)['status_izin']}',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            color: Colors
                                                                .green),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ] else ...[
                                                Row(
                                                  children: [
                                                    Container(
                                                      margin:
                                                      const EdgeInsets.only(
                                                          right: 5.0),
                                                      child: Text(
                                                        '${(data[index].data() as Map<String, dynamic>)['status_izin']}',
                                                        style: const TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                            FontWeight.w500,
                                                            color: Colors
                                                                .red),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                          const SizedBox(height: 8.0),
                                          Text('Tanggal : ${(data[index].data() as Map<String, dynamic>)['tanggal_mulai']} - ${(data[index].data() as Map<String, dynamic>)['tanggal_berakhir']}', style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 12
                                          )),
                                          const SizedBox(height: 5.0),
                                          Text('Alasan : ${(data[index].data() as Map<String, dynamic>)['alasan']}', style: const TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12
                                          )),
                                          const SizedBox(height: 5),
                                          const Divider(color: Colors.black26),
                                          // Text("${movieTitle[index].shortDescription}>"),
                                        ],
                                      ),
                                    );
                                  }),
                            );
                          } else {
                            return const Text('Loading . . .',
                                textAlign: TextAlign.center);
                          }
                        })
                  ],
                ),
                // child: Container(
                //   height: MediaQuery.of(context).size.height,
                //   width: MediaQuery.of(context).size.width,
                //   child: Column(
                //       mainAxisSize: MainAxisSize.max, children: [Text('data')]),
                // ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
