import 'package:flutter/material.dart';
class LogoImage extends StatelessWidget {
   LogoImage({Key? key,required this.path}) : super(key: key);
  String path;
  @override
  Widget build(BuildContext context) {
    return Image.asset(path,height: 120,);
  }
}
