import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class PengajuanIzin extends StatefulWidget {
  const PengajuanIzin({super.key});

  @override
  State<PengajuanIzin> createState() => _PengajuanIzinState();
}

class _PengajuanIzinState extends State<PengajuanIzin> {
  final User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController dateCtl1 = TextEditingController();
  TextEditingController dateCtl2 = TextEditingController();
  TextEditingController alasanCtl = TextEditingController();

  DateTime? tanggal;
  DateTime? tanggalmulai;
  DateTime? tanggalselesai;
  String? tipeRencana;
  String? jumlahHari;
  String? dbStart;
  String? dbEnd;
  List listTipeRencana = ["Sakit", "Izin"];
  List listHari = ["1", "2", "3", "4", "5"];
  final _formKey = GlobalKey<FormState>();

  Future<void> izin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isUser', true);
    DateTime now = DateTime.now();
    String formatDate = DateFormat('dd-MM-yyyy', 'id').format(now);
    String formatDay = DateFormat('EEE', 'id').format(now);
    String formatMonth = DateFormat('MM', 'id').format(now);

    if(tipeRencana == null){
      showToast("Pilih tipe rencana terlebih dahulu !", gravity: Toast.bottom, duration: Toast.lengthLong);
    } else if (dateCtl1.text.isEmpty){
      showToast("Silahkan Pilih tanggal", gravity: Toast.bottom, duration: Toast.lengthLong);
    }else if (alasanCtl.text.isEmpty){
      showToast("Silahkan Isi Alasan", gravity: Toast.bottom, duration: Toast.lengthLong);
    } else {
      // try {
      // loading();
      // await AuthServices.signIn(emailCtl.text, passwordCtl.text);

      try {
        await firestore.collection('database').add(
          {
            'db': 'ABSEN',
            'status': tipeRencana!,
            // 'jam': formatTime,
            // 'jumlah_hari': 'jumlah_hari',
            'tanggal_mulai': dbStart,
            'tanggal_berakhir': dbEnd,
            'nama': user!.displayName!.toString(),
            'alasan': alasanCtl.text,
            'tanggal': formatDate,
            'hari': formatDay,
            'status_code': '1',
            'status_izin': 'Diproses',
            'jam': '07:00',
            'bulan': formatMonth,
            'approve': false,
          },
        );

        Navigator.of(context).pop();

      } catch (e) {
        print(e.toString());
      }
      setState(() {
        FocusScope.of(context).unfocus();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    initializeDateFormatting();
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
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    Column(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 0.813,
                          margin: const EdgeInsets.fromLTRB(15.0, 0.0, 15.0, 15.0),
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
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5.0),
                                const Text(
                                  'Tipe Rencana',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                  decoration: const BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7.0))),
                                  child: DropdownButton(
                                    value: tipeRencana,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                    onChanged: (value) {
                                      setState(() {
                                        tipeRencana = value.toString();
                                      });
                                    },
                                    items: listTipeRencana.map((valueItem) {
                                      return DropdownMenuItem(
                                        value: valueItem,
                                        child: Text(valueItem),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                const Text(
                                  'Jumlah Hari',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Container(
                                  padding:
                                      const EdgeInsets.fromLTRB(10.0, 0.0, 10.0, 0.0),
                                  decoration: const BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(7.0))),
                                  child: DropdownButton(
                                    value: jumlahHari,
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    style: const TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                    onChanged: (value) {
                                      setState(() {
                                        jumlahHari = value.toString();

                                        if(dateCtl1.text.isNotEmpty && jumlahHari != null){
                                          var tanggalBaru = DateTime(tanggal!.year, tanggal!.month, tanggal!.day + int.parse(jumlahHari!));
                                          dateCtl2.text = DateFormat('dd-MM-yyyy').format(tanggalBaru);
                                          dbEnd = DateFormat('dd MMM yyyy', 'id').format(tanggalBaru);
                                          print("tanggal 2 $tanggalBaru");
                                          print("dbEnd $dbEnd");
                                        }
                                      });
                                    },
                                    items: listHari.map((valueItem) {
                                      return DropdownMenuItem(
                                        value: valueItem,
                                        child: Text(valueItem),
                                      );
                                    }).toList(),
                                  ),
                                ),
                                const SizedBox(height: 20.0),
                                Container(
                                  // padding: const EdgeInsets.only(top: 0, bottom: 8),
                                  child: const Text(
                                    'Tanggal',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Row(
                                  children: [
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

                                                if(jumlahHari == null){
                                                  showToast("Pilih jumlah hari terlebih dahulu !", gravity: Toast.bottom, duration: Toast.lengthLong);
                                                }else{
                                                  showDatePicker(
                                                      context: context,
                                                      // locale: const Locale("id", "ID"),
                                                      initialDate: now,
                                                      firstDate: now.add(
                                                        const Duration(
                                                          days: 0,
                                                        ),
                                                      ),
                                                      lastDate: now.add(const Duration(
                                                        days: 60,
                                                      ))
                                                  ).then((value) {
                                                    setState(() {
                                                      tanggal = value!;
                                                      var tanggalBaru = DateTime(tanggal!.year, tanggal!.month, tanggal!.day + int.parse(jumlahHari!));

                                                      dateCtl1.text = DateFormat('dd-MM-yyyy').format(tanggal!);
                                                      dbStart = DateFormat('dd MMM yyyy', 'id').format(tanggal!);
                                                      print("tanggal 1 $tanggal");
                                                      print("dbStart $dbStart");

                                                      print(jumlahHari);

                                                      if(tanggal != null && jumlahHari != null){
                                                        dateCtl2.text = DateFormat('dd-MM-yyyy').format(tanggalBaru);
                                                        dbEnd = DateFormat('dd MMM yyyy', 'id').format(tanggalBaru);
                                                        print("tanggal 2 $tanggalBaru");
                                                        print("dbEnd $dbEnd");
                                                      }
                                                    });
                                                  });
                                                }
                                              },
                                              cursorColor: const Color(0xFF5C8374),
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                // hintText: '$getText()',
                                                // hintStyle: TextStyle(fontSize: 13),
                                                suffixIconConstraints: BoxConstraints(
                                                    minHeight: 25, minWidth: 35),
                                                suffixIcon: Icon(Icons.arrow_drop_down,
                                                    color: Colors.black54),
                                                border: InputBorder.none,
                                              ),
                                              textInputAction: TextInputAction.next,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      '-',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
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
                                              controller: dateCtl2,
                                              onTap: () {
                                              },
                                              cursorColor: const Color(0xFF5C8374),
                                              readOnly: true,
                                              decoration: const InputDecoration(
                                                // hintText: getText(),
                                                // hintStyle: TextStyle(fontSize: 13),
                                                suffixIconConstraints: BoxConstraints(
                                                    minHeight: 25, minWidth: 35),
                                                suffixIcon: Icon(Icons.arrow_drop_down,
                                                    color: Colors.black54),
                                                border: InputBorder.none,
                                              ),
                                              textInputAction: TextInputAction.next,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20.0),
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
                                      minLines: 3, // any number you need (It works as the rows for the textarea)
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 3,
                                      cursorColor: const Color(0xFF5C8374),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                      ),
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                ),
                                // const Expanded(
                                //   flex: 2,
                                //   child: SizedBox(
                                //     height: double.infinity,
                                //   ),
                                // ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: MediaQuery.of(context).size.height * 0.075,
                                      child: ElevatedButton(
                                          onPressed: (){
                                            // Navigator.pop(context);
                                            // Navigator.push(context,
                                            //     MaterialPageRoute(builder: (context) {
                                            //       return const HomeStaff();
                                            //     }));

                                            izin();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            // padding: EdgeInsets.symmetric(horizontal: 2 * 2),
                                            backgroundColor: const Color(0xFF5C8374),
                                            // primary: Colors.green[800],
                                            textStyle: const TextStyle(fontSize: 16,
                                                fontWeight: FontWeight.w500),),
                                          child: const Text('Simpan',)),
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
