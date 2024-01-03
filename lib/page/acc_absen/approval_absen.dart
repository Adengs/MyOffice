import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ApprovalAbsen extends StatefulWidget {
  const ApprovalAbsen({super.key});

  @override
  State<ApprovalAbsen> createState() => _ApprovalAbsenState();
}

class _ApprovalAbsenState extends State<ApprovalAbsen> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController dateCtl1 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('EEE, d MMM y', 'id').format(now);

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
                          'Approve Kehadiran & Izin',
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
                width: double.infinity,
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
                    // Container(
                    //   margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 15.0),
                    //   child: Form(
                    //     key: _formKey,
                    //     child: Row(
                    //         children: <Widget>[
                    //           Expanded(
                    //             child: SizedBox(
                    //               height:
                    //               MediaQuery.of(context).size.height * 0.065,
                    //               child: Container(
                    //                 padding: const EdgeInsets.fromLTRB(10, 1, 0, 1),
                    //                 decoration: const BoxDecoration(
                    //                   color: Colors.black12,
                    //                   borderRadius:
                    //                   BorderRadius.all(Radius.circular(7)),
                    //                 ),
                    //                 child: Theme(
                    //                   data: ThemeData().copyWith(
                    //                     colorScheme: ThemeData()
                    //                         .colorScheme
                    //                         .copyWith(
                    //                         primary: const Color(0xFF5C8374)),
                    //                   ),
                    //                   child: TextFormField(
                    //                     style: const TextStyle(
                    //                         fontSize: 14, color: Colors.black87),
                    //                     controller: dateCtl1,
                    //                     onTap: () {
                    //                       DateTime now = DateTime.now();
                    //                       showDatePicker(
                    //                           context: context,
                    //                           initialDate: now,
                    //                           firstDate: now.add(
                    //                             const Duration(
                    //                               days: 0,
                    //                             ),
                    //                           ),
                    //                           lastDate: now.add(const Duration(
                    //                             days: 60,
                    //                           ))
                    //                       ).then((value) {
                    //                         setState(() {
                    //                           dateCtl1.text = DateFormat('dd-MM-yyyy').format(value!);
                    //                           print(value!);
                    //                           print(dateCtl1.text);
                    //                         });
                    //                       });
                    //                     },
                    //                     cursorColor: const Color(0xFF5C8374),
                    //                     readOnly: true,
                    //                     decoration: const InputDecoration(
                    //                       suffixIconConstraints: BoxConstraints(
                    //                           minHeight: 25, minWidth: 35),
                    //                       suffixIcon: Icon(Icons.arrow_drop_down,
                    //                           color: Colors.black54),
                    //                       border: InputBorder.none,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //           ),
                    //           const SizedBox(width: 25),
                    //           const Expanded(
                    //             child: Text('',
                    //                 style: TextStyle(
                    //                   color: Colors.black87,
                    //                   fontSize: 14,
                    //                   fontWeight: FontWeight.w500,
                    //                 )),
                    //           ),
                    //         ]),
                    //   ),
                    // ),
                    StreamBuilder<QuerySnapshot>(
                      stream: firestore
                            .collection("database")
                            .where("approve", isEqualTo: false)
                            // .where("approve", isEqualTo: true)
                            .where("db", isEqualTo: "ABSEN")
                            .where("status_izin", isEqualTo: "Diproses")
                            .orderBy("jam", descending: true)
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
                                                    fontSize: 14),
                                              ),
                                            ),
                                            if ((data[index].data() as Map<String, dynamic>)['status'] == 'Hadir')...[
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${(data[index].data() as Map<String, dynamic>)['status']}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    const SizedBox(height: 5.0,),
                                                    Text(
                                                      '${(data[index].data() as Map<String, dynamic>)['alasan']}',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black26),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ] else ...[
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${(data[index].data() as Map<String, dynamic>)['status']}',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                      color: Colors.red),
                                                    ),
                                                    const SizedBox(height: 5.0,),
                                                    Text(
                                                      '${(data[index].data() as Map<String, dynamic>)['alasan']}',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.black26),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                            Row(
                                              children: [
                                                Container(
                                                  margin:
                                                  const EdgeInsets.fromLTRB(
                                                      30.0, 0.0, 5.0, 0.0),
                                                  child: GestureDetector(
                                                      onTap: () {

                                                        DocumentReference docRef = firestore
                                                            .collection("database").doc(data[index].id);

                                                        if ((data[index].data() as Map<String, dynamic>)['status'] == 'Hadir'){
                                                            print("Sehat coy");
                                                            try {
                                                              showDialog(
                                                                  context: context,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      title: const Text('Konfirmasi Data'),
                                                                      content: const Text(
                                                                          'Apakah anda yakin untuk menyetujui data ini?'),
                                                                      actions: [
                                                                        TextButton(
                                                                            onPressed: () {
                                                                              Navigator.of(context)
                                                                                  .pop();
                                                                            },
                                                                            child: const Text('Tidak')),
                                                                        TextButton(
                                                                            onPressed: () async {
                                                                              await docRef.update(
                                                                                  {'approve': true,
                                                                                    'status_izin': 'Disetujui'});
                                                                              Navigator.of(context)
                                                                                  .pop();
                                                                            },
                                                                            child: const Text('Ya')),
                                                                      ],
                                                                    );
                                                                  });
                                                            } catch (e) {
                                                              print(e);
                                                            }
                                                        } else {
                                                          print("Sakit & Izin coy");
                                                          try {
                                                            showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: const Text('Konfirmasi Data'),
                                                                    content: const Text(
                                                                        'Apakah anda yakin untuk menyetujui data ini?'),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () {
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                          child: const Text('Tidak')),
                                                                      TextButton(
                                                                          onPressed: () async {
                                                                            await docRef.update(
                                                                                {'approve': true,
                                                                                  'status_izin': 'Disetujui'});
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                          child: const Text('Ya')),
                                                                    ],
                                                                  );
                                                                });
                                                          } catch (e) {
                                                            print(e);
                                                          }
                                                        }
                                                      },
                                                      child: const Icon(
                                                        Icons.check,
                                                        size: 16,
                                                        color: Colors.green,
                                                      )),
                                                ),
                                                Container(
                                                  margin:
                                                  const EdgeInsets.fromLTRB(
                                                      10.0, 0.0, 0.0, 0.0),
                                                  child: GestureDetector(
                                                      onTap: () {
                                                        DocumentReference docRef = firestore
                                                            .collection("database").doc(data[index].id);

                                                        if ((data[index].data() as Map<String, dynamic>)['status'] == 'Hadir'){
                                                          print("Sehat coy");
                                                          try {
                                                            showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: const Text('Konfirmasi Data'),
                                                                    content: const Text(
                                                                        'Apakah anda yakin untuk menolak data ini?'),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () {
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                          child: const Text('Tidak')),
                                                                      TextButton(
                                                                          onPressed: () async {
                                                                            await docRef.update(
                                                                                {'approve': false,
                                                                                  'status_izin': 'Ditolak'});
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                          child: const Text('Ya')),
                                                                    ],
                                                                  );
                                                                });
                                                          } catch (e) {
                                                            print(e);
                                                          }
                                                        } else {
                                                          print("Sakit & Izin coy");
                                                          try {
                                                            showDialog(
                                                                context: context,
                                                                builder: (BuildContext context) {
                                                                  return AlertDialog(
                                                                    title: const Text('Konfirmasi Data'),
                                                                    content: const Text(
                                                                        'Apakah anda yakin untuk menolak data ini?'),
                                                                    actions: [
                                                                      TextButton(
                                                                          onPressed: () {
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                          child: const Text('Tidak')),
                                                                      TextButton(
                                                                          onPressed: () async {
                                                                            await docRef.update(
                                                                                {'approve': false,
                                                                                  'status_izin': 'Ditolak'});
                                                                            Navigator.of(context)
                                                                                .pop();
                                                                          },
                                                                          child: const Text('Ya')),
                                                                    ],
                                                                  );
                                                                });
                                                          } catch (e) {
                                                            print(e);
                                                          }
                                                        }
                                                      },
                                                      child: const Icon(
                                                        Icons.close,
                                                        size: 16,
                                                        color: Colors.red,
                                                      )),
                                                ),

                                              ],
                                            ),
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
                      }
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}
