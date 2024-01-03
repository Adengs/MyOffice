import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myoffice/page/laporan_kerja/laporan_kerja_admin/detail_laporan_kerja.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'dart:io';

class LaporanKerjaAdmin extends StatefulWidget {
  const LaporanKerjaAdmin({super.key});

  @override
  State<LaporanKerjaAdmin> createState() => _LaporanKerjaAdminState();
}

class _LaporanKerjaAdminState extends State<LaporanKerjaAdmin> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController dateCtl1 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? bulan;
  String? namaBulan;

  Future<void> getDataTime() async {
    DateTime now = DateTime.now();
    setState(() {
      dateCtl1.text = DateFormat('dd-MM-yyyy').format(now!);
      bulan = DateFormat('MM').format(now);
      namaBulan = DateFormat('MMMM','id').format(now);
      print("bulan : $bulan");
      print("nama bulan : $namaBulan");
    });
  }

  @override
  void initState() {
    super.initState();
    getDataTime();
  }

  Future<void> createPdf() async {
    final snapshot = await firestore
        .collection('database')
        .where('db', isEqualTo: 'LAPORAN')
        .where('bulan', isEqualTo: bulan)
        .orderBy('tanggal')
        .get();
    // Map<String, dynamic>? data = (await snapshot.docs);
    // print('data ${data}');

    List<List<dynamic>> newList =
    snapshot.docs.map((DocumentSnapshot documentSnapshot) {
      return [
        (documentSnapshot.data() as Map<String, dynamic>)['nama'].toString(),
        (documentSnapshot.data() as Map<String, dynamic>)['tanggal'].toString(),
        (documentSnapshot.data() as Map<String, dynamic>)['laporan'].toString(),
        // (documentSnapshot.data() as Map<String, dynamic>)['image'].toString(),
      ];
    }).toList();

    print('LIST : ${newList}');


    //buat class pdf
    final pdf = pw.Document();

    final headers = ['Nama', 'Tanggal', 'Laporan'];

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
                    pw.Text("Data Laporan Kerja Karyawan Bulan ${namaBulan}\n\n",
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
                      // pw.ListView.builder(itemCount: newList.length,
                      //     itemBuilder:(pw.Context context, int index){
                      //       return pw.Container(
                      //         child: pw.Column(children: [
                      //             pw.Text('${newList[index]}'),
                      //         ])
                      //       );
                      //     }),
                      pw.Table.fromTextArray(
                        // defaultColumnWidth: const pw.IntrinsicColumnWidth(),
                        columnWidths: {
                          0: const pw.FixedColumnWidth(60.0),// fixed to 100 width
                          1: const pw.FixedColumnWidth(100.0),
                          2: const pw.FlexColumnWidth(),//fixed to 100 width
                        },
                        headers: headers,
                        data: newList,
                        cellAlignment: pw.Alignment.centerLeft,
                        headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.blue100),
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
    File('${dir!.path}/Data_Laporan_Kerja_Karyawan_Tanggal_${namaBulan}.pdf');

    //timpa file kosong
    await file.writeAsBytes(bytes);

    //open pdf
    await OpenFile.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
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
                          'Laporan Kerja',
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
                      margin: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 15.0),
                      child: Form(
                        key: _formKey,
                        child: Row(children: <Widget>[
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
                          const SizedBox(width: 25),
                          // const Expanded(child: Text('')),

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
                                    fontSize: 12.0,
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
                        ]),
                      ),
                    ),
                    StreamBuilder<QuerySnapshot>(
                        stream: firestore
                            .collection("database")
                            .where("db", isEqualTo: "LAPORAN")
                            .where("tanggal", isEqualTo: dateCtl1.text)
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
                                          GestureDetector(
                                            onTap:() {
                                              print("${(data[index].data() as Map<String, dynamic>)['nama']}");

                                              DocumentReference docRef = firestore
                                                  .collection("database").doc(data[index].id);

                                              // Map<String, dynamic>? datas = docRef.;
                                              // var value = data?['nama'];

                                              String id = snapshot.data!.docs[index].reference.id;

                                              print("$id");

                                              // SharedPreferences prefs = await SharedPreferences.getInstance();
                                              // prefs.setString("nama", "${(data[index].data() as Map<String, dynamic>)['nama']}");

                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) {
                                                    return DetailLaporanKerja(text: "${id}");
                                                  }));
                                            },
                                            child: Text("${(data[index].data() as Map<String, dynamic>)['nama']}",
                                              style: const TextStyle(
                                                  fontSize: 14)),
                                          ),
                                          const SizedBox(height: 5),
                                          const Divider(color: Colors.black26),
                                          // Text("${movieTitle[index].shortDescription}>"),
                                        ],
                                      ),
                                    );
                                  }),
                            );
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
            ],
          ),
        ),
      ]),
    );
  }
}
