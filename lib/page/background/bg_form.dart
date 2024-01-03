import 'package:flutter/material.dart';

class BgForm extends StatelessWidget {
  const BgForm({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      // appBar: AppBar(
      //   iconTheme: IconThemeData(),
      //   backgroundColor: Colors.transparent,
      //   elevation: 0,
      // ),
      body: Stack(children: [
        Container(
          decoration: const BoxDecoration(color: Colors.white),
          child: Container(
            margin: const EdgeInsets.fromLTRB(15.0, 125.0, 15.0, 15.0),
            padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 10.0),
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
          ),
        ),
        // Image.asset('assets/images/bg_login.png',
        //   fit: BoxFit.cover,
        //   width: double.infinity,
        //   height: double.infinity,
        // ),
        SafeArea(
          child: child!,
        )
      ]),
    );
  }
}
