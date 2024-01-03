import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:myoffice/page/background/bg_absen.dart';
import 'package:toast/toast.dart';

class Pulang extends StatefulWidget {
  const Pulang({super.key});

  @override
  State<Pulang> createState() => _PulangState();
}

class _PulangState extends State<Pulang> {
  String adress = "Tunggu Sebentar.......";

  Position? currentLocation;
  late bool servicePermission = false;
  late LocationPermission permission;

  String currentAdress = "";
  String? jam;
  double? jamPulang = 17.00;
  double? jamSekarang;
  
  Future<void> getTime() async {
    DateTime now = DateTime.now();
    String formatTime = DateFormat('kk:mm').format(now);
    jam = formatTime.replaceAll(':', '.');
    print('replace jam ${jam}');
    jamSekarang = double.parse(jam!);
    print('double jam ${jamSekarang}');
  }

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
    await getAdress();
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
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getLocation();
    getTime();
  }

  Future<void> showDialogPulang() async {
    try {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Center(child: Text('Informasi')),
              content: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                      'Mohon maaf absen pulang hanya bisa dilakukan setelah pukul',
                    textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                  ),),
                  SizedBox(height: 20,),
                  Text(
                      '17:00',
                    textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18.0,
                    color: Colors.black54,
                  ),),
                ],
              ),
              actions: [
                // TextButton(
                //     onPressed: () {
                //       Navigator.of(context)
                //           .pop();
                //     },
                //     child: const Text('Tidak')),
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Center(child: Text('Tutup',
                    style: TextStyle(
                      color: Color(0xFF5C8374),
                      fontWeight: FontWeight.w500,
                      fontSize: 18.0,
                    ),))),
              ],
            );
          });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    DateTime now = DateTime.now();
    String formatDate = DateFormat('dd-MM-yyyy', 'id').format(now);

    return BgAbsen(
      child: Column(
        children: [
          Row(children: [
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 10.0),
                child: Image.asset("assets/images/ic_back.png",
                    height: 45,
                    width: 45),
              ),
            ),
          ]),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width : double.infinity,
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
                        'Pulang',
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
                            children:  [
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
                                width: MediaQuery.of(context).size.width*0.7,
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
                          onPressed: (){
                            if(jamSekarang != null){
                              if(jamSekarang! <= jamPulang!){
                                showDialogPulang();
                              }
                            }
                            // Navigator.of(context).pop();
                            // Navigator.push(context,
                            //     MaterialPageRoute(builder: (context) {
                            //       return const HomeStaff();
                            //     }));
                          },
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                side: const BorderSide(color: Color(0xFF5C8374))),
                            backgroundColor: const Color(0xFF5C8374),
                            textStyle: const TextStyle(fontSize: 16,
                                fontWeight: FontWeight.w500),),
                          child: const Text('Pulang',)),
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
