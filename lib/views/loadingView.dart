import 'package:flutter/material.dart';

class loadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child:
          Image(image: AssetImage('assets/img/taxiLogoText.png'), height: 100),
    );
  }
}
