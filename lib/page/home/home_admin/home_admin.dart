import 'dart:typed_data';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myoffice/auth/auth_services.dart';
import 'package:myoffice/auth/create_pdf.dart';
import 'package:myoffice/page/acc_absen/approval_absen.dart';
import 'package:myoffice/page/background/bg_home.dart';
import 'package:myoffice/page/laporan_kerja/laporan_kerja_admin/laporan_kerja_admin.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:toast/toast.dart';
// import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HomeAdmin extends StatefulWidget {
  final User? user;

  const HomeAdmin(User firebaseUser, {super.key, this.user});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController dateCtl1 = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  User? user;
  String name = '';
  String? bulan;
  String? namaBulan;

  Future<void> getUserData() async {
    User? userData = await FirebaseAuth.instance.currentUser;
    DateTime now = DateTime.now();
    setState(() {
      user = userData;
      print(userData?.uid);
      print(userData?.displayName);
      if (userData!.displayName != null) {
        name = userData.displayName!;
        dateCtl1.text = DateFormat('dd-MM-yyyy').format(now!);
        bulan = DateFormat('MM').format(now);
        namaBulan = DateFormat('MMMM','id').format(now);
        print("bulan : $bulan");
        print("nama bulan : $namaBulan");
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
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Tidak',
                      style: TextStyle(
                        color: Color(0xFF5C8374),
                      ),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      AuthServices.signOut();
                    },
                    child: const Text(
                      'Ya',
                      style: TextStyle(
                        color: Color(0xFF5C8374),
                      ),
                    )),
              ],
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }

  // Future<void> createPdf() async {
  //   PdfDocument document = PdfDocument();
  //   document.pages.add();
  //
  //   List<int> bytes = await document.save();
  //   document.dispose();
  //
  //   saveAndLaunchFile(bytes, '${DateTime.now()}.pdf');
  // }

  Future<void> createPdf() async {
    final snapshot = await firestore
        .collection('database')
        .where('db', isEqualTo: 'ABSEN')
        .where('approve', isEqualTo: true)
        .where('bulan', isEqualTo: bulan)
        .orderBy('tanggal')
        .get();
    List<List<dynamic>> newList =
        snapshot.docs.map((DocumentSnapshot documentSnapshot) {
      return [
        (documentSnapshot.data() as Map<String, dynamic>)['nama'].toString(),
        (documentSnapshot.data() as Map<String, dynamic>)['tanggal'].toString(),
        (documentSnapshot.data() as Map<String, dynamic>)['status'].toString(),
        (documentSnapshot.data() as Map<String, dynamic>)['jam'].toString(),
      ];
    }).toList();

    //buat class pdf
    final pdf = pw.Document();

    final headers = ['Nama', 'Tanggal', 'Status', 'Jam Absen'];

    //buat pages
    pdf.addPage(pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            //judul
            pw.Container(
                width: double.infinity,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text("Data Kehadiran Karyawan Bulan ${namaBulan}\n\n",
                        textAlign: pw.TextAlign.center,
                        style: pw.TextStyle(
                            fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  ],
                )),
            //table
            pw.Container(
                width: double.infinity,
                child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Table.fromTextArray(
                        headers: headers,
                        data: newList,
                        cellAlignment: pw.Alignment.center,
                        headerDecoration:
                            pw.BoxDecoration(color: PdfColors.blue100),
                      ),
                    ])),
          ];

          // Center
        }));

    //simpan
    Uint8List bytes = await pdf.save();

    //buat file kosong di direktori
    final dir = await getExternalStorageDirectory();
    final file =
        File('${dir!.path}/Data_Kehadiran_Karyawan_Tanggal_${namaBulan}.pdf');

    //timpa file kosong
    await file.writeAsBytes(bytes);

    //open pdf
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
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
                      Text('${name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8,
                          )),
                      Container(
                        margin: const EdgeInsets.only(top: 3),
                        child: const Text(
                          'CEO',
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
                  //
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
                padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 25.0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        offset: Offset(0.0, 0.2), //(x,y)
                        blurRadius: 2.0,
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(25.0))),
                // borderRadius: BorderRadius.all(Radius.circular(25.0))),
                child: Column(children: <Widget>[
                  const Text(
                    'Jam',
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
                                return const ApprovalAbsen();
                              }));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  side: const BorderSide(
                                      color: Color(0xFF5C8374))),
                              backgroundColor: const Color(0xFF5C8374),
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            child: const Text('Absen & Izin'),
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
                                return const LaporanKerjaAdmin();
                              }));
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  side: const BorderSide(
                                      color: Color(0xFF5C8374))),
                              backgroundColor: const Color(0xFF5C8374),
                              textStyle: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                            child: const Text('Laporan Kerja'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
              const SizedBox(height: 10.0),
              Container(
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(25.0, 15.0, 25.0, 10.0),
                      child: Row(
                        children: const <Widget>[
                          ImageIcon(
                            AssetImage("assets/images/ic_history_att.png"),
                            color: Colors.black,
                          ),
                          SizedBox(width: 5),
                          Text(
                            'List Kehadiran Karyawan',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 15.0),
                      child: Form(
                        key: _formKey,
                        child: Row(children: <Widget>[
                          Expanded(
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.065,
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.picture_as_pdf,
                                    color: Colors.white),
                                label: const Text(
                                  'Cetak PDF',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    // decoration: TextDecoration.underline,
                                  ),
                                ),
                                onPressed: () {
                                  createPdf();
                                  // showToast('On Develop',
                                  //     gravity: Toast.bottom,
                                  //     duration: Toast.lengthLong);
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF5C8374),
                                  backgroundColor: const Color(0xFF5C8374),
                                  side: const BorderSide(
                                    width: 1.5,
                                    color: Colors.white,
                                    // color: Color(0xFF5C8374),
                                    style: BorderStyle.solid,
                                  ),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.0)),
                                ),
                                //   child: const Text(
                                //     'Download Pdf',
                                //     style: TextStyle(
                                //       color: Color(0xFF5C8374),
                                //   fontWeight: FontWeight.w600,
                                //   decoration: TextDecoration.underline,
                                // ),
                                //   ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 25),
                          Expanded(
                            child: SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.065,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(10, 1, 0, 1),
                                decoration: const BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(7)),
                                ),
                                child: Theme(
                                  data: ThemeData().copyWith(
                                    colorScheme: ThemeData()
                                        .colorScheme
                                        .copyWith(
                                            primary: const Color(0xFF5C8374)),
                                  ),
                                  child: TextFormField(
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                    controller: dateCtl1,
                                    onTap: () {
                                      DateTime now = DateTime.now();
                                      showDatePicker(
                                          context: context,
                                          initialDate: now,
                                          firstDate: DateTime(2023),
                                          // firstDate: now.add(
                                          //   const Duration(
                                          //     days: 0,
                                          //   ),
                                          // ),
                                          lastDate: now.add(const Duration(
                                            days: 60,
                                          ))).then((value) {
                                        setState(() {
                                          dateCtl1.text =
                                              DateFormat('dd-MM-yyyy')
                                                  .format(value!);
                                          bulan =
                                              DateFormat('MM').format(value!);
                                          namaBulan =
                                              DateFormat('MMMM', 'id').format(value!);
                                          print(value!);
                                          print(dateCtl1.text);
                                          print("bulan : $bulan");
                                          print("bulan : $namaBulan");
                                        });
                                      });
                                    },
                                    cursorColor: const Color(0xFF5C8374),
                                    readOnly: true,
                                    decoration: const InputDecoration(
                                      suffixIconConstraints: BoxConstraints(
                                          minHeight: 25, minWidth: 35),
                                      suffixIcon: Icon(Icons.arrow_drop_down,
                                          color: Colors.black54),
                                      border: InputBorder.none,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection("database")
                            .where("approve", isEqualTo: true)
                            // .where("approve", isEqualTo: true)
                            .where("db", isEqualTo: "ABSEN")
                            .where("tanggal", isEqualTo: dateCtl1.text)
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
                                        25.0, 5.0, 25.0, 0.0),
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
                                            if ((data[index].data() as Map<
                                                    String,
                                                    dynamic>)['status'] ==
                                                'Hadir') ...[
                                              Row(
                                                children: [
                                                  Container(
                                                    margin: const EdgeInsets
                                                            .fromLTRB(
                                                        10.0, 0.0, 20.0, 0.0),
                                                    child: GestureDetector(
                                                        onTap: () {},
                                                        child: const Icon(
                                                          Icons
                                                              .access_time_rounded,
                                                          size: 16,
                                                        )),
                                                  ),
                                                  Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            right: 5.0),
                                                    child: Text(
                                                      '${(data[index].data() as Map<String, dynamic>)['jam']}',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                  ),
                                                  const Text(
                                                    'WIB',
                                                    style:
                                                        TextStyle(fontSize: 14),
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
                                                        const EdgeInsets.only(
                                                            right: 5.0),
                                                    child: Text(
                                                      '${(data[index].data() as Map<String, dynamic>)['status']}',
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.red),
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
                            print(
                                'Error in Firestore query: ${snapshot.error}');
                            return const Text('Something went wrong');
                          } else {
                            return const Text('Loading . . .',
                                textAlign: TextAlign.center);
                          }
                        })
                  ],
                ),
              ),

              // Container(
              //   margin: const EdgeInsets.fromLTRB(25.0, 5.0, 25.0, 15.0),
              //   child: SizedBox(
              //     height:
              //     MediaQuery.of(context).size.height * 0.065,
              //     child: Container(
              //       padding: const EdgeInsets.fromLTRB(10, 1, 0, 1),
              //       decoration: const BoxDecoration(
              //         color: Colors.black12,
              //         borderRadius:
              //         BorderRadius.all(Radius.circular(7)),
              //       ),
              //       child: Theme(
              //         data: ThemeData().copyWith(
              //           colorScheme: ThemeData()
              //               .colorScheme
              //               .copyWith(
              //               primary: const Color(0xFF5C8374)),
              //         ),
              //         child: TextFormField(
              //           style: const TextStyle(
              //               fontSize: 14, color: Colors.black87),
              //           // controller: dateCtl2,
              //           onTap: () {
              //           },
              //           cursorColor: const Color(0xFF5C8374),
              //           readOnly: true,
              //           decoration: const InputDecoration(
              //             // hintText: getText(),
              //             // hintStyle: TextStyle(fontSize: 13),
              //             suffixIconConstraints: BoxConstraints(
              //                 minHeight: 25, minWidth: 35),
              //             suffixIcon: Icon(Icons.arrow_drop_down,
              //                 color: Colors.black54),
              //             border: InputBorder.none,
              //           ),
              //           textInputAction: TextInputAction.next,
              //         ),
              //       ),
              //     ),
              //   ),
              // ),
            ]),
          )
        ],
      ),
    );
  }

  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }
}
