import 'dart:async';
import 'dart:io';
import 'package:myoffice/auth/create_pdf.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' show get;
import 'package:toast/toast.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'dart:typed_data';
// import 'dart:io';

class DetailLaporanKerja extends StatefulWidget {
  final String text;

  const DetailLaporanKerja({super.key, required this.text});

  @override
  State<DetailLaporanKerja> createState() => _DetailLaporanKerjaState();
}

class _DetailLaporanKerjaState extends State<DetailLaporanKerja> {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameCtl = TextEditingController();
  TextEditingController laporanCtl = TextEditingController();

  List? listLaporan;
  String? tanggal, nama, laporan, imageUrl;
  String? bulan;
  String? namaBulan;
  DateTime now = DateTime.now();

  Future<void> getData() async {
    var collection = firestore.collection('database');
    var docSnapshot = await collection.doc(widget.text).get();
    if (docSnapshot.exists) {
      Map<String, dynamic>? data = docSnapshot.data();
      var db_nama = data?['nama'];
      var db_tanggal = data?['tanggal'];
      var db_laporan = data?['laporan'];
      var db_urlImage = data?['image'];
      setState(() {
        nama = db_nama.toString();
        tanggal = db_tanggal.toString();
        laporan = db_laporan.toString();
        imageUrl = db_urlImage.toString();

        nameCtl.text = nama!;
        laporanCtl.text = laporan!;

        namaBulan = DateFormat('MMMM','id').format(now);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  // Future<void> createPdf() async {
  //
  //   //buat class pdf
  //   final pdf = pw.Document();
  //
  //   final headers = ['Nama', 'Tanggal', 'Status', 'Jam Absen'];
  //
  //   final netImage = await NetworkImage('${imageUrl}');
  //   var response = await get(Uri.parse(imageUrl!));
  //   var data = response.bodyBytes;
  //
  //   //Create a bitmap object.
  //   PdfBitmap image = PdfBitmap(data);
  //
  //   //buat pages
  //   pdf.addPage(pw.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (pw.Context context) {
  //         return [
  //           //judul
  //           pw.Container(
  //               width: double.infinity,
  //               child: pw.Column(
  //                 crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                 children: [
  //                   pw.Text("Data Kehadiran Karyawan Bulan ${namaBulan}\n\n",
  //                       textAlign: pw.TextAlign.center,
  //                       style: pw.TextStyle(
  //                           fontSize: 14, fontWeight: pw.FontWeight.bold)),
  //                 ],
  //               )),
  //           //table
  //           pw.Container(
  //               width: double.infinity,
  //               child: pw.Column(
  //                   crossAxisAlignment: pw.CrossAxisAlignment.center,
  //                   children: [
  //                     pw.Table(
  //                       border: pw.TableBorder.all(),
  //                       children: [
  //                         pw.TableRow(
  //                           children: [
  //                             // Insert an image into a cell
  //                             pw.Container(
  //                               width: 100,
  //                               height: 100,
  //                               child: pw.Image(netImage as pw.ImageProvider),
  //                             ),
  //                             // Add other cells as needed
  //                             // pw.Cell(text: 'Cell 1'),
  //                             // pw.Cell(text: 'Cell 2'),
  //                           ],
  //                         ),
  //                       ]
  //                     )
  //                     // pw.Table.fromTextArray(
  //                     //   headers: headers,
  //                     //   data: newList,
  //                     //   cellAlignment: pw.Alignment.center,
  //                     //   headerDecoration:
  //                     //   pw.BoxDecoration(color: PdfColors.blue100),
  //                     // ),
  //                   ])),
  //         ];
  //
  //         // Center
  //       }));
  //
  //   //simpan
  //   Uint8List bytes = await pdf.save();
  //
  //   //buat file kosong di direktori
  //   final dir = await getExternalStorageDirectory();
  //   final file =
  //   File('${dir!.path}/Data_Kehadiran_Karyawan_Tanggal_${namaBulan}.pdf');
  //
  //   //timpa file kosong
  //   await file.writeAsBytes(bytes);
  //
  //   //open pdf
  //   await OpenFile.open(file.path);
  //
  //   pw.MemoryImage _getImage() {
  //     final Uint8List bytes = File('assets/image.png').readAsBytesSync();
  //     return pw.MemoryImage(bytes);
  //   }
  //
  // }

  Future<void> createPdf() async {
    PdfDocument document = PdfDocument();
    final page = document.pages.add();
    final Size pageSize = page.getClientSize();

    page.graphics.drawString('LAPORAN KERJA STAFF', PdfStandardFont(PdfFontFamily.timesRoman, 14, style: PdfFontStyle.bold),
        brush: PdfBrushes.black,
    bounds: const Rect.fromLTRB(180, 10, 10, 10));
    page.graphics.drawString('Nama                 : ${nama}', PdfStandardFont(PdfFontFamily.timesRoman, 14),
        bounds: const Rect.fromLTRB(10, 45, 10, 10));
    page.graphics.drawString('Tanggal              : ${tanggal}', PdfStandardFont(PdfFontFamily.timesRoman, 14),
        bounds: const Rect.fromLTRB(10, 70, 10, 10));
    page.graphics.drawString('Laporan              : ${laporan}', PdfStandardFont(PdfFontFamily.timesRoman, 14),
        bounds: const Rect.fromLTWH(10, 95, 500, 50));
    // page.graphics.drawString('Laporan              : ${laporan}', PdfStandardFont(PdfFontFamily.timesRoman, 14),
    //     bounds: const Rect.fromLTRB(10, 110, 10, 10));
    page.graphics.drawString('Lampiran Foto   : ', PdfStandardFont(PdfFontFamily.timesRoman, 14),
        bounds: const Rect.fromLTRB(10, 120, 10, 10));

    var response = await get(Uri.parse(imageUrl!));
    var data = response.bodyBytes;

    //Create a bitmap object.
    PdfBitmap image = PdfBitmap(data);
    // page.graphics.drawImage(image, Rect.fromLTRB(10, 160, 10, 10));
    page.graphics.drawImage(image, Rect.fromLTWH(115, 125, 210, 128));
    // page.graphics.drawImage(image,Rect.fromLTRB(10, 160, 10, 10));

    // page.graphics.drawImage(PdfBitmap(await readImageData('${DateTime.now()}.jpg')),
    // Rect.fromLTWH(0, 100, 440, 550));

    List<int> bytes = await document.save();
    document.dispose();

    saveAndLaunchFile(bytes, '${DateTime.now()}.pdf');
  }

  Future<Uint8List> readImageData(String name) async {
    final data = await rootBundle.load('image/$name');
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(15.0, 40.0, 15.0, 5.0),
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
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.813,
                          margin:
                              const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
                          padding:
                              const EdgeInsets.fromLTRB(25.0, 20.0, 25.0, 15.0),
                          decoration: const BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  offset: Offset(0.0, 1.0), //(x,y)
                                  blurRadius: 35.0,
                                )
                              ],
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0))),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5.0),
                                Container(
                                  // padding: const EdgeInsets.only(top: 0, bottom: 8),
                                  child: const Text(
                                    'Nama',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.075,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.fromLTRB(10, 1, 0, 1),
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
                                                primary:
                                                    const Color(0xFF5C8374)),
                                      ),
                                      child: TextFormField(
                                        style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87),
                                        // controller: TextEditingController(text: "${(data as Map<String, dynamic>)['nama']}"),
                                        controller: nameCtl,
                                        onTap: () {
                                          getData();
                                        },
                                        cursorColor: const Color(0xFF5C8374),
                                        readOnly: true,
                                        decoration: const InputDecoration(
                                          // hintText: '$getText()',
                                          // hintStyle: TextStyle(fontSize: 13),
                                          suffixIconConstraints: BoxConstraints(
                                              minHeight: 25, minWidth: 35),
                                          // suffixIcon: Icon(Icons.arrow_drop_down,
                                          //     color: Colors.black54),
                                          border: InputBorder.none,
                                        ),
                                        textInputAction: TextInputAction.next,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                Container(
                                  // padding: const EdgeInsets.only(top: 0, bottom: 8),
                                  child: const Text(
                                    'Laporan',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 1, 10, 1),
                                  decoration: const BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(6)),
                                  ),
                                  child: Theme(
                                    data: ThemeData().copyWith(
                                      colorScheme: ThemeData()
                                          .colorScheme
                                          .copyWith(
                                              primary: const Color(0xFF5C8374)),
                                    ),
                                    child: TextFormField(
                                      controller: laporanCtl,
                                      minLines: 4,
                                      // any number you need (It works as the rows for the textarea)
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 4,
                                      cursorColor: const Color(0xFF5C8374),
                                      readOnly: true,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16.0),
                                const Text(
                                  'Lampiran Foto',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.250,
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                      25.0, 20.0, 25.0, 15.0),
                                  decoration: const BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  child: imageUrl != null ? Image.network(imageUrl!, fit: BoxFit.contain) : Container(),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.075,
                                      child: ElevatedButton.icon(
                                          icon: const Icon(Icons.picture_as_pdf,
                                              color: Colors.white, size: 20),
                                          onPressed: () async {
                                            createPdf();
                                            //cetak pdf
                                            // showToast('On Develop',
                                            //     gravity: Toast.bottom,
                                            //     duration: Toast.lengthLong);
                                          },
                                          style: ElevatedButton.styleFrom(
                                            // padding: EdgeInsets.symmetric(horizontal: 2 * 2),
                                            backgroundColor:
                                                const Color(0xFF5C8374),
                                            // primary: Colors.green[800],
                                            textStyle: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          label: const Text(
                                            'Cetak Pdf',
                                          )),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }
}
