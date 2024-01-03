import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:myoffice/auth/auth_services.dart';
import 'package:myoffice/page/background/bg_login.dart';
import 'package:myoffice/page/home/home_admin/home_admin.dart';
import 'package:myoffice/page/home/home_staff.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  String? error;
  TextEditingController emailCtl = TextEditingController();
  TextEditingController passwordCtl = TextEditingController();

  Future<void> login(String email, String password) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isUser', true);

    if(emailCtl.text.isEmpty){
      showToast("Silahkan Masukan Email", gravity: Toast.bottom, duration: Toast.lengthLong);
    } else if (passwordCtl.text.isEmpty){
      showToast("Silahkan Masukan Password", gravity: Toast.bottom, duration: Toast.lengthLong);
    }
    else {
      // try {
        loading();
        await AuthServices.signIn(emailCtl.text, passwordCtl.text);
    //   } catch (e) {
    //     print(e);
    //     setState(() {
    //       showDialog(
    //           context: context,
    //           builder: (BuildContext context) {
    //             return AlertDialog(
    //               title: Text('Pemberitahuan !!'),
    //               content: Text('Email/Password yang anda masukan salah.'),
    //               actions: [
    //                 TextButton(
    //                     onPressed: () {
    //                       Navigator.of(context).pop();
    //                       setState(() {
    //                         error = null;
    //                       });
    //                     },
    //                     child: Text('Ok'))
    //               ],
    //             );
    //           });
    //     });
    //   }
    }
  }

  bool _secureText = true;
  bool? _isChecked = false;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);
    return BgLogin(
      child: Column(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                Column(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 30),
                      child: Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: const TextSpan(children: [
                            TextSpan(
                                text: 'Selamat Datang\n',
                                style: TextStyle(
                                    fontSize: 35.0, fontWeight: FontWeight.w600)),
                            TextSpan(
                                text: 'Login ke Akun Anda',
                                style: TextStyle(
                                  fontSize: 14.0,
                                ))
                          ]),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(25.0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(35.0), topRight: Radius.circular(35.0)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.only(top: 0, bottom: 8),
                              child: const Text(
                                'Username',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
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
                                  controller: emailCtl,
                                  cursorColor: const Color(0xFF5C8374),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                  ),
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.only(top: 15, bottom: 8),
                              child: const Text(
                                'Password',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(10, 1, 0, 1),
                              decoration: const BoxDecoration(
                                color: Colors.black12,
                                borderRadius: BorderRadius.all(Radius.circular(6)),
                              ),
                              child: Theme(
                                data: ThemeData().copyWith(
                                  colorScheme: ThemeData().colorScheme
                                      .copyWith(primary: const Color(0xFF5C8374))
                                ),
                                child: TextFormField(
                                  controller: passwordCtl,
                                  cursorColor: const Color(0xFF5C8374),
                                  obscureText: _secureText,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    suffixIcon: IconButton(
                                      onPressed: showHide,
                                      icon: _secureText
                                          ? const Icon(Icons.visibility_off)
                                          : const Icon(Icons.visibility),
                                    ),
                                  ),
                                  textInputAction: TextInputAction.done,
                                ),
                              ),
                            ),
                            // Container(
                            //   margin: const EdgeInsets.only(top: 15),
                            //   child: Row(
                            //     children: [
                            //       Checkbox(
                            //           materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            //           visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                            //         checkColor: Colors.white,
                            //           activeColor: const Color(0xFF5C8374),
                            //           value: _isChecked,
                            //           onChanged: (bool? newValue){
                            //           setState(() {
                            //             _isChecked = newValue;
                            //           });
                            //       }),
                            //       Container(
                            //           padding: const EdgeInsets.only(left: 5),
                            //           child: const Text('Ingat saya',
                            //             style: TextStyle(
                            //               fontSize: 14.0,
                            //               fontWeight: FontWeight.w400,
                            //               color: Colors.black54,
                            //             ),
                            //           )),
                            //     ],
                            //   ),
                            // ),
                            const SizedBox(
                              height: 45.0,
                            ),
                            SizedBox(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height * 0.075,
                              child: ElevatedButton(
                                  onPressed: () {
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: (context) {
                                    //       return const HomeStaff();
                                    //     }));
                                    // Navigator.push(context,
                                    //     MaterialPageRoute(builder: (context) {
                                    //       return const HomeStaff();
                                    //     }));

                                    // await AuthServices.signIn(emailCtl.text, passwordCtl.text);
                                    login(emailCtl.text, passwordCtl.text);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    // padding: EdgeInsets.symmetric(horizontal: 2 * 2),
                                    backgroundColor: const Color(0xFF5C8374),
                                    // primary: Colors.green[800],
                                    textStyle: const TextStyle(fontSize: 16,
                                    fontWeight: FontWeight.w500),),
                                  child: const Text('Masuk',)),
                            ),
                            const SizedBox(
                              height: 10.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
  Widget loading() {
    return const Center(child: CircularProgressIndicator());
  }
  void showToast(String msg, {int? duration, int? gravity}) {
    Toast.show(msg, duration: duration, gravity: gravity);
  }
}
