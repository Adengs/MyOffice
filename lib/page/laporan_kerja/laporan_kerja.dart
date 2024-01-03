import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:device_info_plus/device_info_plus.dart';

class LaporanKerja extends StatefulWidget {
  const LaporanKerja({super.key});

  @override
  State<LaporanKerja> createState() => _LaporanKerjaState();
}

class _LaporanKerjaState extends State<LaporanKerja> {
  final User? user = FirebaseAuth.instance.currentUser;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  TextEditingController dateCtl1 = TextEditingController();
  TextEditingController laporanCtl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? image;
  String? imageUrl;
  String? check;
  final ImagePicker imagePicker = ImagePicker();

  // Future getImage() async{
  //   final ImagePicker picker = ImagePicker();
  //   // Pick an image.
  //   final XFile? imagePicked = await picker.pickImage(source: ImageSource.gallery);
  //   // Capture a photo.
  //   final XFile? photoPicked = await picker.pickImage(source: ImageSource.camera);
  //   image = File(imagePicked!.path);
  //   setState(() {
  //
  //   });
  // }

  Future<void> showPictureDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context){
        return SimpleDialog(
          children: [
            SimpleDialogOption(
              onPressed: (){
                getFromCamera();
                Navigator.of(context).pop();
              },
              child: const Text('Kamera'),
            ),
            SimpleDialogOption(
              onPressed: (){
                getFromGallery();
                Navigator.of(context).pop();
              },
              child: const Text('Galeri'),
            )
          ],
        );
      }
    );
  }

  getFromCamera() async {
    //,maxWidth: 1800, maxHeight: 1800
    await imagePicker.pickImage(source: ImageSource.camera, imageQuality: 50)
    .then((value) {
      if(value != null){
        cropImage(File(value.path));
      }
    });
    // if(pickedFile != null){
    //   setState(() {
    //     image = File(pickedFile.path);
    //   });
    // }
  }
  getFromGallery() async {
    //,maxWidth: 1800, maxHeight: 1800
    await imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 50)
        .then((value) {
          if (value != null) {
            cropImage(File(value.path));
          }
        });
    // if(pickedFile != null){
    //   setState(() {
    //     image = File(pickedFile.path);
    //   });
    // }
  }

  Future<void> cropImage(File imageFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: CropAspectRatio(ratioX: 16, ratioY: 9),
      compressQuality: 100, // 100 means no compression
      maxWidth: 700,
      maxHeight: 700,
      compressFormat: ImageCompressFormat.jpg,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: const Color(0xFF5C8374),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: 'Potong Gambar',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    if(croppedFile != null){
      imageCache.clear();
      setState(() {
        image = File(croppedFile.path);
      });
    }
  }

  Future<void> laporan_kerja() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isUser', true);
    DateTime now = DateTime.now();
    String formatDate = DateFormat('dd-MM-yyyy', 'id').format(now);
    String formatDay = DateFormat('EEE', 'id').format(now);
    String formatMonth = DateFormat('MM', 'id').format(now);

    if (laporanCtl.text.isEmpty){
      showToast("Silahkan isi laporan", gravity: Toast.bottom, duration: Toast.lengthLong);
    } else if(image == null){
      showToast("Wajib melampirkan foto", gravity: Toast.bottom, duration: Toast.lengthLong);
    }
    else {
        try {
          // final ref = FirebaseStorage.instance.ref().child('${DateTime.now()}jpg');
          Reference reference = FirebaseStorage.instance.ref(image!.toString()).child('userImages').child(DateTime.now().toString() + '.jpg');
          // UploadTask uploadTask = reference.putFile(image!);
          // await reference.putFile(image!);
          final TaskSnapshot snapshot = await reference.putFile(image!);
          imageUrl = await snapshot.ref.getDownloadURL();
          // imageUrl = await reference.getDownloadURL();
          // await ref.putFile(image!);
          // imageUrl = await ref.getDownloadURL();
          await firestore.collection('database').add(
            {
              'db': 'LAPORAN',
              'nama': user!.displayName!.toString(),
              'laporan': laporanCtl.text,
              'image': imageUrl,
              'tanggal': formatDate,
              'bulan': formatMonth,
            },
          );

          prefs.setString('laporan', formatDate);
          Navigator.of(context).pop();

        } catch (e) {
          print(e.toString());
        }

      setState(() {
        FocusScope.of(context).unfocus();
      });
    }
  }

  Future<void> permission() async {
    final plugin = DeviceInfoPlugin();
    final android = await plugin.androidInfo;

    final storageStatus = android.version.sdkInt < 33
        ? await Permission.storage.request()
        : PermissionStatus.granted;

    if (storageStatus == PermissionStatus.granted) {
      print("granted");
      // showToast('diizinkan', gravity: Toast.bottom, duration: Toast.lengthLong);
      showPictureDialog();
    }
    if (storageStatus == PermissionStatus.denied) {
      print("denied");
      showToast('Permission ditolak',
          gravity: Toast.bottom, duration: Toast.lengthLong);
    }
    if (storageStatus == PermissionStatus.permanentlyDenied) {
      openAppSettings();
    }

    // Map<Permission, PermissionStatus>
    // status =  android.version.sdkInt < 33
    //     ? await [
    //   Permission.storage,
    //   Permission.camera,
    // ].request() : PermissionStatus.granted;
    // if (status[Permission.storage]!
    //     .isGranted &&
    //     status[Permission.camera]!
    //         .isGranted) {
    //   showPictureDialog();
    // } else {
    //   showToast('Permission ditolak',
    //       gravity: Toast.bottom,
    //       duration: Toast.lengthLong);
    // }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    DateTime now = DateTime.now();
    String formatDate = DateFormat('dd-MM-yyyy', 'id').format(now);
    dateCtl1.text = DateFormat('dd-MM-yyyy').format(now);
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
                                SizedBox(
                                  height:
                                  MediaQuery.of(context).size.height * 0.075,
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
                                          // DateTime now = DateTime.now();
                                          //   showDatePicker(
                                          //       context: context,
                                          //       // locale: const Locale("id", "ID"),
                                          //       initialDate: now,
                                          //       firstDate: now.add(
                                          //         const Duration(
                                          //           days: 0,
                                          //         ),
                                          //       ),
                                          //       lastDate: now.add(const Duration(
                                          //         days: 60,
                                          //       ))
                                          //   ).then((value) {
                                          //     setState(() {
                                          //       dateCtl1.text = DateFormat('dd-MM-yyyy').format(value!);
                                          //     });
                                          //   });

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
                                const SizedBox(height: 20.0),
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
                                      controller: laporanCtl,
                                      minLines: 3, // any number you need (It works as the rows for the textarea)
                                      keyboardType: TextInputType.multiline,
                                      maxLines: 3,
                                      maxLength: 68,
                                      cursorColor: const Color(0xFF5C8374),
                                      decoration: const InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                      ),
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 0.0),
                                Row(
                                  children:  [
                                    const Expanded(
                                      child: Text(
                                        'Lampiran Foto',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        permission();
                                        // Map<Permission, PermissionStatus>
                                        //     status = await [
                                        //   Permission.storage,
                                        //   Permission.camera,
                                        // ].request();
                                        // if (status[Permission.storage]!
                                        //         .isGranted &&
                                        //     status[Permission.camera]!
                                        //         .isGranted) {
                                        //   showPictureDialog();
                                        // } else {
                                        //   showToast('Permission ditolak',
                                        //       gravity: Toast.bottom,
                                        //       duration: Toast.lengthLong);
                                        // }
                                      },
                                      child: const Text(
                                        'Ambil Foto',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5C8374),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 0.0),
                                Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.250,
                                  width: double.infinity,
                                  padding: const EdgeInsets.fromLTRB(
                                      25.0, 20.0, 25.0, 15.0),
                                  decoration: const BoxDecoration(
                                      color: Colors.black12,
                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: Colors.black12,
                                      //     offset: Offset(0.0, 1.0), //(x,y)
                                      //     blurRadius: 35.0,
                                      //   )
                                      // ],
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0))),
                                  child: image != null ? Image.file(File(image!.path), fit: BoxFit.contain) : Container(),
                                ),
                                Expanded(
                                  child: Align(
                                    alignment: Alignment.bottomCenter,
                                    child: SizedBox(
                                      width: double.infinity,
                                      height: MediaQuery.of(context).size.height * 0.075,
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            SharedPreferences prefs = await SharedPreferences.getInstance();

                                            check = prefs.getString('laporan');
                                            // if(check == formatDate){
                                            //   showToast("Laporan hanya bisa dilakukan sekali sehari", gravity: Toast.bottom, duration: Toast.lengthLong);
                                            // }else {
                                              laporan_kerja();
                                            // }

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
