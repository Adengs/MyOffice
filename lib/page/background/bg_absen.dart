import 'package:flutter/material.dart';

class BgAbsen extends StatelessWidget {
  const BgAbsen({super.key, this.child});
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
      body: Stack(
          children: [
            // Container(
            //   decoration: const BoxDecoration(
            //       color: Color(0xFF5C8374)
            //   ),
            // ),
            Image.asset('assets/images/bg_absen.png',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
            SafeArea(
              child: child!,
            )
          ]
      ),
    );
  }
}
