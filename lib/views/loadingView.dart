import 'package:flutter/material.dart';

class loadingView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image(image: AssetImage('assets/img/taxiLogo.png'), height: 100),
    );
  }
}
